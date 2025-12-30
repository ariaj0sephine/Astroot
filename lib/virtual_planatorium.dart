import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:ui' as ui; // For text labels (fixes TextPainter)

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
  final double fovAz = 120.0;
  StreamSubscription<Position>? _positionStream;
  Timer? _skyTimer;
  bool isNightMode = false;

  // Full star list (your data—complete, fixed closing bracket)
  final List<Map<String, dynamic>> stars = [
    {'name': 'Alpheratz', 'ra': 8.72, 'dec': 29.42, 'mag': 2.06},
    {'name': 'Caph', 'ra': 9.12, 'dec': 59.14, 'mag': 2.27},
    {'name': 'Algenib', 'ra': 13.24, 'dec': 15.19, 'mag': 2.83},
    {'name': 'Ankaa', 'ra': 26.28, 'dec': -42.36, 'mag': 2.39},
    {'name': 'Kap Phe', 'ra': 26.20, 'dec': -43.68, 'mag': 3.94},
    {'name': 'Bet Hyi', 'ra': 25.75, 'dec': -77.25, 'mag': 2.80},
    {'name': 'Zet Tuc', 'ra': 20.07, 'dec': -64.87, 'mag': 4.23},
    {'name': 'Bet1Tuc', 'ra': 31.55, 'dec': -62.98, 'mag': 4.37},
    {'name': 'Bet2Tuc', 'ra': 31.56, 'dec': -62.98, 'mag': 4.54},
    {'name': 'Lam1Phe', 'ra': 31.42, 'dec': -48.72, 'mag': 4.77},
    {'name': '14Lam Cas', 'ra': 31.77, 'dec': 54.52, 'mag': 4.73},
    {'name': '15Kap Cas', 'ra': 4.95, 'dec': 62.92, 'mag': 4.16},
    {'name': '17Zet Cas', 'ra': 5.53, 'dec': 53.83, 'mag': 3.66},
    {'name': '29Pi And', 'ra': 5.48, 'dec': 33.68, 'mag': 4.36},
    {'name': '31Del And', 'ra': 5.99, 'dec': 30.79, 'mag': 3.27},
    {'name': '24Eta Cas', 'ra': 7.43, 'dec': 57.95, 'mag': 3.44},
    {'name': '22Omi Cas', 'ra': 6.74, 'dec': 48.07, 'mag': 4.54},
    {'name': 'η Cassiopeiae', 'ra': 7.43, 'dec': 57.95, 'mag': 3.44},
    {'name': 'η Phoenicis', 'ra': 5.35, 'dec': -57.81, 'mag': 4.36},
    {'name': '27Gam Cas', 'ra': 42.38, 'dec': 60.50, 'mag': 2.47},
    {'name': '43Bet And', 'ra': 65.82, 'dec': 35.62, 'mag': 2.06},
    {'name': '31Eta Cet', 'ra': 65.93, 'dec': -10.18, 'mag': 3.45},
    {'name': 'Zet Phe', 'ra': 65.38, 'dec': -55.75, 'mag': 3.92},
    {'name': 'Bet Phe', 'ra': 64.08, 'dec': -46.12, 'mag': 3.31},
    {'name': '37Mu And', 'ra': 67.37, 'dec': 38.78, 'mag': 3.87},
    {'name': 'Alp Scl', 'ra': 65.60, 'dec': -29.45, 'mag': 4.31},
    {'name': '42Phi And', 'ra': 69.05, 'dec': 47.52, 'mag': 4.25},
    {'name': '71Eps Psc', 'ra': 62.77, 'dec': 7.90, 'mag': 4.28},
    {'name': '84Chi Psc', 'ra': 67.87, 'dec': 21.03, 'mag': 4.66},
    {'name': '83Tau Psc', 'ra': 67.93, 'dec': 30.08, 'mag': 4.51},
    {'name': '85Phi Psc', 'ra': 68.75, 'dec': 24.57, 'mag': 4.65},
    {'name': '86Zet Psc', 'ra': 68.73, 'dec': 7.57, 'mag': 5.24},
    {'name': 'Ups Phe', 'ra': 67.82, 'dec': -41.22, 'mag': 5.21},
    {'name': 'Nu Phe', 'ra': 71.18, 'dec': -45.88, 'mag': 4.96},
    {'name': 'Kap Tuc', 'ra': 71.77, 'dec': -68.87, 'mag': 4.86},
    {'name': '37 Cet', 'ra': 70.40, 'dec': -7.82, 'mag': 5.13},
    {'name': '69Sig Psc', 'ra': 62.82, 'dec': 31.80, 'mag': 5.50},
    {'name': 'Lam2Tuc', 'ra': 65.05, 'dec': -69.62, 'mag': 5.45},
    {'name': 'Iot Tuc', 'ra': 67.30, 'dec': -61.77, 'mag': 5.37},
    {'name': '74Psi1Psc', 'ra': 65.82, 'dec': 21.47, 'mag': 5.34},
    {'name': '32 Cas', 'ra': 70.68, 'dec': 65.73, 'mag': 5.57},
    {'name': '33The Cas', 'ra': 70.10, 'dec': 55.10, 'mag': 4.33},
    {'name': '41 And', 'ra': 68.02, 'dec': 43.57, 'mag': 5.03},
    {'name': '39 And', 'ra': 62.90, 'dec': 41.70, 'mag': 5.98},
    {'name': '44 And', 'ra': 70.30, 'dec': 42.07, 'mag': 5.65},
    {'name': '45 And', 'ra': 70.85, 'dec': 37.72, 'mag': 5.81},
    {'name': '87 Psc', 'ra': 70.77, 'dec': 16.13, 'mag': 5.98},
    {'name': '79Psi2Psc', 'ra': 67.97, 'dec': 20.73, 'mag': 5.55},
    {'name': '30Mu Cas', 'ra': 68.40, 'dec': 54.85, 'mag': 5.17},
    {'name': '32 Cet', 'ra': 70.20, 'dec': -8.90, 'mag': 6.40},
    {'name': '38 Cet', 'ra': 70.82, 'dec': -0.43, 'mag': 5.70},
    {'name': '39 Cet', 'ra': 70.60, 'dec': -2.50, 'mag': 5.41},
    {'name': '33 Cet', 'ra': 70.60, 'dec': 2.43, 'mag': 5.95},
    {'name': '34 Cet', 'ra': 71.73, 'dec': -2.25, 'mag': 5.94},
    {'name': 'Del Cas', 'ra': 37.83, 'dec': 60.12, 'mag': 2.68},
    {'name': 'Alp Eri', 'ra': 37.73, 'dec': -57.20, 'mag': 0.46},
    {'name': '52Tau Cet', 'ra': 66.00, 'dec': -15.90, 'mag': 3.50},
    {'name': '110Omi Psc', 'ra': 68.75, 'dec': 9.49, 'mag': 4.26},
    {'name': 'Alp Hyi', 'ra': 59.77, 'dec': -61.57, 'mag': 2.86},
    {'name': '2Alp Tri', 'ra': 71.08, 'dec': 29.73, 'mag': 3.41},
    {'name': '5Gam1Ari', 'ra': 71.53, 'dec': 19.75, 'mag': 4.83},
    {'name': '5Gam2Ari', 'ra': 71.53, 'dec': 19.62, 'mag': 4.75},
    {'name': '53Chi Cet', 'ra': 70.59, 'dec': -10.69, 'mag': 4.67},
    {'name': '113Alp Psc', 'ra': 75.03, 'dec': 2.82, 'mag': 5.23},
    {'name': '13Alp Ari', 'ra': 79.27, 'dec': 23.75, 'mag': 2.00},
    {'name': '4Bet Tri', 'ra': 78.87, 'dec': 34.23, 'mag': 3.00},
    {'name': '68Omi Cet', 'ra': 32.85, 'dec': -2.64, 'mag': 3.04},
    {'name': 'Phi Eri', 'ra': 25.10, 'dec': -51.51, 'mag': 3.56},
    {'name': '8Del Tri', 'ra': 41.05, 'dec': 34.46, 'mag': 4.87},
    {'name': '60 And', 'ra': 31.22, 'dec': 44.22, 'mag': 4.83},
    {'name': '65Xi 1Cet', 'ra': 30.00, 'dec': 8.80, 'mag': 4.37},
    {'name': 'Iot Cas', 'ra': 47.07, 'dec': 67.41, 'mag': 4.52},
    {'name': '72Rho Cet', 'ra': 25.95, 'dec': -12.44, 'mag': 4.89},
    {'name': 'Ome For', 'ra': 31.85, 'dec': -28.50, 'mag': 4.90},
    {'name': '73Xi 2Cet', 'ra': 28.16, 'dec': 8.60, 'mag': 4.28},
    {'name': 'Del Hyi', 'ra': 26.49, 'dec': -68.66, 'mag': 4.09},
    {'name': 'Kap Eri', 'ra': 26.98, 'dec': -47.24, 'mag': 4.25},
    {'name': '15 Tri', 'ra': 35.78, 'dec': 34.69, 'mag': 5.35},
    {'name': '86Gam Cet', 'ra': 51.30, 'dec': 3.24, 'mag': 3.47},
    {'name': '15Eta Per', 'ra': 75.70, 'dec': 55.90, 'mag': 3.76},
    {'name': '3Eta Eri', 'ra': 89.40, 'dec': -8.90, 'mag': 3.89},
    {'name': '41 Ari', 'ra': 89.98, 'dec': 27.63, 'mag': 3.63},
    {'name': '18Tau Per', 'ra': 87.25, 'dec': 52.75, 'mag': 3.95},
    {'name': '20 Per', 'ra': 87.10, 'dec': 38.40, 'mag': 5.33},
    {'name': '16 Per', 'ra': 75.60, 'dec': 38.19, 'mag': 4.23},
    {'name': '21 Per', 'ra': 88.95, 'dec': 31.95, 'mag': 5.11},
    {'name': '48Eps Ari', 'ra': 44.60, 'dec': 21.42, 'mag': 4.63},
    {'name': 'The1Eri', 'ra': 43.60, 'dec': -40.28, 'mag': 3.24},
    {'name': 'The2Eri', 'ra': 43.60, 'dec': -40.27, 'mag': 4.35},
    {'name': '5 Eri', 'ra': 61.70, 'dec': -2.93, 'mag': 5.56},
    {'name': '22Pi Per', 'ra': 59.80, 'dec': 39.78, 'mag': 4.70},
    {'name': 'λ Ceti', 'ra': 59.80, 'dec': 8.89, 'mag': 4.70},
    {'name': 'β Hor', 'ra': 58.80, 'dec': -64.07, 'mag': 4.99},
    {'name': 'α Ceti', 'ra': 61.40, 'dec': 4.06, 'mag': 2.53},
    {'name': '23Gam Per', 'ra': 74.80, 'dec': 53.51, 'mag': 2.93},
    {'name': '27Kap Per', 'ra': 74.50, 'dec': 44.44, 'mag': 3.80},
    {'name': 'β Persei', 'ra': 77.00, 'dec': 40.85, 'mag': 2.12},
    {'name': 'ι Persei', 'ra': 74.10, 'dec': 49.61, 'mag': 4.05},
    {'name': 'κ Persei', 'ra': 74.50, 'dec': 44.44, 'mag': 3.80},
    {'name': '29 Per', 'ra': 77.60, 'dec': 50.35, 'mag': 5.15},
    {'name': '31 Per', 'ra': 77.10, 'dec': 50.13, 'mag': 5.03},
    {'name': 'δ Arietis', 'ra': 74.60, 'dec': 19.59, 'mag': 4.35},
    {'name': 'ζ Arietis', 'ra': 77.20, 'dec': 21.03, 'mag': 4.89},
    {'name': '13Zet Eri', 'ra': 77.80, 'dec': -8.82, 'mag': 4.80},
    {'name': 'Alp For', 'ra': 77.10, 'dec': -28.99, 'mag': 3.87},
    {'name': '95 Cet', 'ra': 77.40, 'dec': -0.83, 'mag': 5.38},
    {'name': '16Tau4Eri', 'ra': 47.37, 'dec': -21.76, 'mag': 3.69},
    {'name': '18Eps Eri', 'ra': 50.77, 'dec': -9.50, 'mag': 3.73},
  ]; // Fixed: Closing bracket here

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

  final Map<String, List<List<double>>> constLines = {
    'Ori': [[91.893, 14.7685], [88.5958, 20.2762], [90.9799, 20.1385], [92.985, 14.2088], [90.5958, 9.6473], [88.7929, 7.4071], [81.2828, 6.3497], [73.7239, 10.1508]],
    'UMa': [[-176.1435, 57.0326], [165.932, 61.751], [165.4603, 56.3824], [178.4577, 53.6948], [-176.1435, 57.0326], [-166.4927, 55.9598], [-159.0186, 54.9254], [-153.1148, 49.3133]],
    'Cas': [[28.5989, 63.6701], [21.454, 60.2353], [14.1772, 60.7167], [10.1268, 56.5373], [2.2945, 59.1498]],
    'Tau': [[84.4112, 21.1425], [68.9802, 16.5093], [67.1656, 15.8709], [64.9483, 15.6276], [65.7337, 17.5425], [67.1542, 19.1804], [81.573, 28.6075]],
    'Aur': [[89.8822, 44.9474], [79.1723, 45.998], [76.6287, 41.2345], [74.2484, 33.1661], [81.573, 28.6075], [89.9303, 37.2126], [89.8822, 44.9474], [89.8818, 54.2847], [79.1723, 45.998], [75.4922, 43.8233], [75.6195, 41.0758]],
  };

  @override
  void initState() {
    super.initState();
    _getLocation();
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
    if (!serviceEnabled) {
      _showError('Turn on location for accurate sky view!');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (mounted) setState(() {
      _updateSkyTime();
    });
  }

  void _startLocationStream() {
    const LocationSettings settings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);
    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
      if (mounted) {
        setState(() => currentPosition = pos);
        _updateSkyTime();
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
    final lat = currentPosition?.latitude ?? 37.42;
    final yearStart = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(yearStart).inDays + 1;
    final hour = now.hour;
    final decl = 23.44 * math.cos(deg2rad(360 * (dayOfYear - 81) / 365));
    final sunsetHour = 12 + (math.asin(math.tan(deg2rad(lat)) * math.tan(deg2rad(decl))) * 180 / math.pi) / 15;
    isNightMode = hour > sunsetHour || hour < (sunsetHour - 12 + 6);
    if (mounted) setState(() {});
  }

  void _showError(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/milky_way.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: _infoPanel(),
          ),
          _skyLabel("North", 0),
          _skyLabel("East", 90),
          _skyLabel("South", 180),
          _skyLabel("West", 270),
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.5,
            maxScale: 10.0,
            child: CustomPaint(
              size: Size.infinite,
              painter: SkyDomePainter(stars, constLines, heading, currentPosition?.latitude ?? 0, _lst ?? 0, majors, fovAz),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPanel() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lat: ${currentPosition?.latitude.toStringAsFixed(2) ?? "--"}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text('Lon: ${currentPosition?.longitude.toStringAsFixed(2) ?? "--"}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text('Heading: ${heading.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(isNightMode ? '🌙 Night View' : '☀️ Day View', style: TextStyle(color: isNightMode ? Colors.cyan : Colors.orange, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _skyLabel(String text, double targetAngle) {
    final diff = ((targetAngle - heading + 540) % 360) - 180;
    if (diff.abs() > 45) return const SizedBox.shrink();
    final screenWidth = MediaQuery.of(context).size.width;
    final x = (screenWidth / 2) + (diff / 45) * (screenWidth / 2);
    return Positioned(
      top: 80,
      left: x - 30,
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
  final List<Map<String, dynamic>> stars;
  final Map<String, List<List<double>>> constLines;
  final double heading;
  final double lat;
  final double lst;
  final List<Map<String, dynamic>> majors;
  final double fovAz;

  SkyDomePainter(this.stars, this.constLines, this.heading, this.lat, this.lst, this.majors, this.fovAz);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final halfFov = fovAz / 2.0;

    final linePaint = Paint()
      ..color = Colors.cyan.withAlpha(153)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);

    final horizonPaint = Paint()
      ..color = Colors.grey.withAlpha(77)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr); // Fixed: ui.

    canvas.drawLine(Offset(0, h * 0.8), Offset(w, h * 0.8), horizonPaint);

    for (final star in stars) {
      final ra = star['ra'] as double;
      final dec = star['dec'] as double;
      final mag = star['mag'] as double;
      final coords = getAltAz(ra, dec, lat, lst);
      if (coords.isEmpty) continue;
      final alt = coords['alt']!;
      final az = coords['az']!;
      double relAz = ((az - heading + 360) % 360);
      if (relAz > 180) relAz -= 360;
      if (relAz.abs() > halfFov) continue;
      final x = w / 2 + (relAz / halfFov) * (w / 2);
      final yFlat = h * (90 - alt) / 90.0;
      final curveFactor = 1 + (90 - alt) / 90 * 0.4;
      final y = (yFlat * curveFactor).clamp(50.0, h * 0.8 - 20);
      final radius = (5 - mag).clamp(1.0, 4.0);
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }

    for (final entry in constLines.entries) {
      final points = <Offset>[];
      for (final p in entry.value) {
        final ra = p[0];
        final dec = p[1];
        final coords = getAltAz(ra, dec, lat, lst);
        if (coords.isEmpty) continue;
        final alt = coords['alt']!;
        final az = coords['az']!;
        double relAz = ((az - heading + 360) % 360);
        if (relAz > 180) relAz -= 360;
        if (relAz.abs() > halfFov + 20) continue;
        final x = w / 2 + (relAz / halfFov) * (w / 2);
        final yFlat = h * (90 - alt) / 90.0;
        final curveFactor = 1 + (90 - alt) / 90 * 0.4;
        final y = (yFlat * curveFactor).clamp(50.0, h * 0.8 - 20);
        points.add(Offset(x, y));
      }
      if (points.length > 1) {
        final path = Path();
        path.addPolygon(points, false);
        canvas.drawPath(path, linePaint);
      }
    }

    for (final major in majors) {
      final ra = major['ra'] as double;
      final dec = major['dec'] as double;
      final coords = getAltAz(ra, dec, lat, lst);
      if (coords.isEmpty) continue;
      final alt = coords['alt']!;
      if (alt < 25) continue;
      final az = coords['az']!;
      double relAz = ((az - heading + 360) % 360);
      if (relAz > 180) relAz -= 360;
      if (relAz.abs() > halfFov) continue;
      final x = w / 2 + (relAz / halfFov) * (w / 2);
      final yFlat = h * (90 - alt) / 90.0;
      final curveFactor = 1 + (90 - alt) / 90 * 0.4;
      final y = (yFlat * curveFactor).clamp(60.0, h * 0.8 - 30);
      textPainter.text = TextSpan(
        text: major['name'],
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [ui.Shadow(blurRadius: 2, color: Colors.black)],
        ),
      );
      textPainter.maxLines = 1;
      textPainter.layout(maxWidth: 120);
      double labelX = x - textPainter.width / 2;
      double labelY = y - textPainter.height / 2 - 15;
      if (labelX < 10) labelX = 10;
      if (labelX + textPainter.width > w - 10) labelX = w - textPainter.width - 10;
      textPainter.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}