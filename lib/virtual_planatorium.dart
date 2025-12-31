import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

double deg2rad(double deg) => deg * math.pi / 180.0;

double jdFromDateTime(DateTime dt) {
  int year = dt.year;
  int month = dt.month;
  if (month <= 2) {
    year--;
    month += 12;
  }
  int a = (year / 100).floor();
  int b = 2 - a + (a / 4).floor();
  double jd = (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + dt.day + b - 1524.5;
  jd += (dt.hour + dt.minute / 60.0 + dt.second / 3600.0) / 24.0;
  return jd;
}

double gmstFromJd(double jd) {
  double d = jd - 2451545.0;
  double t = d / 36525.0;
  double theta = 280.46061837 + 360.98564736629 * d + 0.000387933 * t * t - t * t * t / 38710000.0;
  return theta % 360.0;
}

Map<String, double> getAltAz(double ra, double dec, double lat, double lst) {
  double ha = (lst - ra + 360) % 360;
  double haR = deg2rad(ha);
  double decR = deg2rad(dec);
  double latR = deg2rad(lat);
  double sinAlt = math.sin(decR) * math.sin(latR) + math.cos(decR) * math.cos(latR) * math.cos(haR);
  double alt = math.asin(sinAlt.clamp(-1.0, 1.0)) * 180 / math.pi;
  if (alt < 0) return {};
  double den = math.cos(deg2rad(alt)) * math.cos(latR);
  if (den == 0) return {};
  double cosAz = (math.sin(decR) - math.sin(deg2rad(alt)) * math.sin(latR)) / den;
  double az = math.acos(cosAz.clamp(-1.0, 1.0)) * 180 / math.pi;
  if (math.cos(haR) < 0) az = 360 - az;
  return {'alt': alt, 'az': az};
}

class VirtualPlanetariumScreen extends StatefulWidget {
  const VirtualPlanetariumScreen({super.key});

  @override
  State<VirtualPlanetariumScreen> createState() => _VirtualPlanetariumScreenState();
}

class _VirtualPlanetariumScreenState extends State<VirtualPlanetariumScreen> {
  Position? currentPosition;
  double heading = 0.0;
  double _smoothedHeading = 0.0;
  DateTime? _now;
  double? _lst;
  final double fovAz = 160.0;
  StreamSubscription<Position>? _positionStream;
  Timer? _skyTimer;
  bool isNightMode = false;

  // Major bright stars with labels
  final List<Map<String, dynamic>> majors = [
    {'name': 'Sirius', 'ra': 101.29, 'dec': -16.72},
    {'name': 'Betelgeuse', 'ra': 88.79, 'dec': 7.41},
    {'name': 'Rigel', 'ra': 78.63, 'dec': -8.20},
    {'name': 'Procyon', 'ra': 114.83, 'dec': 5.22},
    {'name': 'Capella', 'ra': 79.17, 'dec': 45.99},
    {'name': 'Vega', 'ra': 279.23, 'dec': 38.78},
    {'name': 'Arcturus', 'ra': 213.92, 'dec': 19.18},
    {'name': 'Polaris', 'ra': 37.95, 'dec': 89.26},
  ];

  // Constellation lines — perfect for December 30 evening sky
  final Map<String, List<List<double>>> constLines = {
    'Ori': [
      [88.79, 7.41], [91.89, 14.77], [88.79, 7.41], [84.05, -1.20], [84.72, -1.94],
      [85.19, -2.40], [84.05, -1.20], [78.63, -8.20], [88.79, 7.41], [83.00, -5.92]
    ],
    'Gem': [
      [116.33, 31.89], [113.65, 27.26], [116.33, 31.89], [100.98, 22.52], [116.33, 31.89], [105.83, 16.40]
    ],
    'Tau': [
      [81.57, 28.61], [68.98, 16.51], [81.57, 28.61], [67.17, 15.87], [64.95, 15.63]
    ],
    'UMa': [
      [165.93, 61.75], [159.02, 54.93], [165.93, 61.75], [153.11, 49.31], [178.46, 53.69], [176.14, 57.03]
    ],
    'Lyr': [
      [279.23, 38.78], [278.32, 38.92], [279.23, 38.78], [280.02, 38.78], [279.23, 38.78], [282.52, 33.36], [284.08, 34.75]
    ],
    'Cyg': [
      [308.79, 40.15], [301.53, 36.82], [308.79, 40.15], [293.15, 45.98], [299.42, 35.08], [304.21, 45.28]
    ],
    'Sco': [
      [247.35, -26.43], [245.98, -25.59], [247.35, -26.43], [252.17, -37.10], [250.97, -37.29]
    ],
    'Leo': [
      [152.09, 11.97], [148.15, 23.72], [152.09, 11.97], [167.60, 14.57]
    ],
    'Cas': [[28.60, 63.67], [21.45, 60.24], [14.18, 60.72], [10.13, 56.54], [2.29, 59.15]],
    'Aur': [[89.88, 44.95], [79.17, 46.00], [76.63, 41.23], [74.25, 33.17], [81.57, 28.61], [89.93, 37.21]],
    'Peg': [[8.72, 29.42], [13.24, 15.19], [0.14, 15.20], [346.20, 28.08], [8.72, 29.42]],
    'CMa': [[101.29, -16.72], [100.98, -22.52], [101.29, -16.72], [105.43, -28.97]],
    'Boo': [[213.92, 19.18], [210.95, 32.35], [213.92, 19.18], [218.00, 27.71]],
  };

  @override
  void initState() {
    super.initState();
    // Fake location for instant indoor testing (NYC — Orion visible in December)
    currentPosition = Position(
      longitude: -74.0,
      latitude: 40.7,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
    _getLocation(); // Try real GPS
    _startLocationStream();
    _listenToCompass();
    _now = DateTime.now().toUtc();
    _updateSkyTime();
    _checkNightMode();
    _skyTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _now = DateTime.now().toUtc();
        _updateSkyTime();
        _checkNightMode();
        setState(() {});
      }
    });
  }

  void _updateSkyTime() {
    if (currentPosition != null && _now != null) {
      double jd = jdFromDateTime(_now!);
      double gmst = gmstFromJd(jd);
      _lst = (gmst + currentPosition!.longitude) % 360.0;
      if (mounted) setState(() {});
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        currentPosition = pos;
        _updateSkyTime();
      });
    }
  }

  void _startLocationStream() {
    const LocationSettings settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
      if (mounted) {
        setState(() {
          currentPosition = pos;
          _updateSkyTime();
        });
      }
    });
  }

  void _listenToCompass() {
    magnetometerEventStream().listen((event) {
      final angle = (math.atan2(event.y, event.x) * 180 / math.pi + 360) % 360;
      if (mounted) {
        _smoothedHeading = angle * 0.1 + _smoothedHeading * 0.9;
        setState(() => heading = _smoothedHeading);
      }
    });
  }

  void _checkNightMode() {
    final now = DateTime.now().toLocal();
    final lat = currentPosition?.latitude ?? 40.7;
    final yearStart = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(yearStart).inDays + 1;
    final hour = now.hour;
    final decl = 23.44 * math.cos(deg2rad(360 * (dayOfYear - 81) / 365));
    final sunsetHour = 12 + (math.asin(math.tan(deg2rad(lat)) * math.tan(deg2rad(decl))) * 180 / math.pi) / 15;
    isNightMode = hour > sunsetHour || hour < (sunsetHour - 12 + 6);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 360° starry background — tilts with phone
          PanoramaViewer(
            child: Image.asset('assets/images/night_sky.jpg', fit: BoxFit.cover),
            sensitivity: 1.0,
            animSpeed: 0.0,
            sensorControl: SensorControl.orientation,
          ),
          // Info panel top-left
          Positioned(
            top: 40,
            left: 20,
            child: _infoPanel(),
          ),
          // Directional labels
          _skyLabel("North", 0),
          _skyLabel("East", 90),
          _skyLabel("South", 180),
          _skyLabel("West", 270),
          // Constellation lines & star labels — perfect dome curve
          Positioned.fill(
            child: CustomPaint(
              painter: SkyDomePainter(constLines, heading, currentPosition?.latitude ?? 40.7, _lst ?? 0, majors, fovAz),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.9),
        border: Border.all(color: Colors.white, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Lat: ${currentPosition?.latitude.toStringAsFixed(2) ?? "40.70"}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text('Lon: ${currentPosition?.longitude.toStringAsFixed(2) ?? "-74.00"}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text('Heading: ${heading.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(isNightMode ? '🌙 Night View' : '☀️ Day View', style: TextStyle(color: isNightMode ? Colors.cyan : Colors.orange, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _skyLabel(String text, double targetAngle) {
    final diff = ((targetAngle - heading + 540) % 360) - 180;
    if (diff.abs() > 35) return const SizedBox.shrink();
    final screenWidth = MediaQuery.of(context).size.width;
    final x = (screenWidth / 2) + (diff / 45) * (screenWidth / 2);
    return Positioned(
      top: 80,
      left: x - 40,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 6, color: Colors.black)])),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _skyTimer?.cancel();
    super.dispose();
  }
}

class SkyDomePainter extends CustomPainter {
  final Map<String, List<List<double>>> constLines;
  final double heading;
  final double lat;
  final double lst;
  final List<Map<String, dynamic>> majors;
  final double fovAz;

  SkyDomePainter(this.constLines, this.heading, this.lat, this.lst, this.majors, this.fovAz);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final halfFov = fovAz / 2.0;

    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final horizonPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.5;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Horizon line
    canvas.drawLine(Offset(0, h * 0.8), Offset(w, h * 0.8), horizonPaint);

    // Constellation lines — beautiful inward dome curve
    for (final entry in constLines.entries) {
      final points = <Offset>[];
      for (final p in entry.value) {
        final ra = p[0];
        final dec = p[1];
        final coords = getAltAz(ra, dec, lat, lst);
        if (coords.isEmpty) continue;
        final alt = coords['alt']!;
        if (alt < 10) continue; // Only show above horizon
        final az = coords['az']!;
        double relAz = ((az - heading + 360) % 360);
        if (relAz > 180) relAz -= 360;
        if (relAz.abs() > halfFov + 20) continue;

        final x = w / 2 + (relAz / halfFov) * (w / 2);
        final yFlat = h * (90 - alt) / 90.0;
        final curveFactor = 1 + (90 - alt) / 90 * 1.4; // This creates the perfect "inside dome" curve
        final y = (yFlat * curveFactor).clamp(50.0, h * 0.8 - 20);
        points.add(Offset(x, y));
      }
      if (points.length > 1) {
        final path = Path()..addPolygon(points, false);
        canvas.drawPath(path, linePaint);
      }
    }

    // Major star labels — bold with glow
    for (final major in majors) {
      final ra = major['ra'] as double;
      final dec = major['dec'] as double;
      final coords = getAltAz(ra, dec, lat, lst);
      if (coords.isEmpty) continue;
      final alt = coords['alt']!;
      if (alt < 20) continue;
      final az = coords['az']!;
      double relAz = ((az - heading + 360) % 360);
      if (relAz > 180) relAz -= 360;
      if (relAz.abs() > halfFov) continue;

      final x = w / 2 + (relAz / halfFov) * (w / 2);
      final yFlat = h * (90 - alt) / 90.0;
      final curveFactor = 1 + (90 - alt) / 90 * 1.4;
      final y = (yFlat * curveFactor).clamp(60.0, h * 0.8 - 30);

      textPainter.text = TextSpan(
        text: major['name'],
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 8, color: Colors.black)]),
      );
      textPainter.layout(maxWidth: 160);
      final labelX = x - textPainter.width / 2;
      final labelY = y - textPainter.height / 2 - 20;
      textPainter.paint(canvas, Offset(labelX.clamp(10, w - textPainter.width - 10), labelY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}