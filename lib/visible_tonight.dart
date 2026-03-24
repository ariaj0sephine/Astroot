// lib/screens/visible_tonight.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Elevated VisibleTonightScreen (Constellation map removed)
//  · Animated moon phase crescent (CustomPainter)
//  · Sunrise/sunset arc with rising sun icon + sky gradient
//  · Star/planet entries with sequential twinkle bursts
//  · Pull-to-refresh starry burst animation
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VisibleTonightScreen extends StatefulWidget {
  const VisibleTonightScreen({super.key});

  @override
  State<VisibleTonightScreen> createState() => _VisibleTonightScreenState();
}

class _VisibleTonightScreenState extends State<VisibleTonightScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──
  final TextEditingController _latController =
  TextEditingController(text: '11.0510');
  final TextEditingController _lonController =
  TextEditingController(text: '76.0711');

  DateTime _selectedDateTime = DateTime.now();
  Map<String, dynamic> _sunMoonData = {};
  List<Map<String, dynamic>> _starsData = [];
  List<Map<String, dynamic>> _planetsData = [];
  String _errorMessage = '';
  String _cityName = 'Unknown';
  bool _isLoadingLocation = true;
  bool _isFetchingData = false;

  // ── Animation controllers ──
  late AnimationController _moonCtrl;       // moon phase rotation
  late AnimationController _sunArcCtrl;     // sun arc sweep
  late AnimationController _refreshCtrl;    // pull-to-refresh burst

  // Per-item twinkle controllers (created after data loads)
  final List<AnimationController> _twinkleCtrl = [];

  final _rng = math.Random();

  // ── Star data ──
  final List<Map<String, dynamic>> _brightStars = [
    {'name': 'Sirius',      'ra': 6.7525,  'dec': -16.7161, 'mag': -1.46},
    {'name': 'Canopus',     'ra': 6.3992,  'dec': -52.6956, 'mag': -0.72},
    {'name': 'Arcturus',    'ra': 14.2608, 'dec': 19.1822,  'mag': -0.04},
    {'name': 'Vega',        'ra': 18.6156, 'dec': 38.7828,  'mag':  0.03},
    {'name': 'Capella',     'ra': 5.2781,  'dec': 45.9972,  'mag':  0.08},
    {'name': 'Rigel',       'ra': 5.2422,  'dec': -8.2016,  'mag':  0.12},
    {'name': 'Procyon',     'ra': 7.6550,  'dec':  5.2250,  'mag':  0.38},
    {'name': 'Betelgeuse',  'ra': 5.9195,  'dec':  7.4070,  'mag':  0.50},
    {'name': 'Altair',      'ra': 19.8464, 'dec':  8.8672,  'mag':  0.77},
  ];

  final List<Map<String, dynamic>> _brightPlanets = [
    {'name': 'Venus',   'ra': 23.0, 'dec': -5.0,  'mag': -4.0},
    {'name': 'Jupiter', 'ra':  3.5, 'dec': 18.0,  'mag': -2.5},
    {'name': 'Saturn',  'ra': 11.0, 'dec':  5.0,  'mag':  0.5},
    {'name': 'Mercury', 'ra': 22.5, 'dec': -10.0, 'mag': -0.5},
    {'name': 'Mars',    'ra':  1.0, 'dec':  5.0,  'mag':  0.5},
  ];

  @override
  void initState() {
    super.initState();

    _moonCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _sunArcCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _refreshCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _initialize();
  }

  @override
  void dispose() {
    _moonCtrl.dispose();
    _sunArcCtrl.dispose();
    _refreshCtrl.dispose();
    for (final c in _twinkleCtrl) { c.dispose(); }
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    await _fetchData();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = '';
    });

    double lat = 11.0510, lon = 76.0711;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) await Geolocator.openLocationSettings();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      lat = position.latitude;
      lon = position.longitude;
      _latController.text = lat.toStringAsFixed(4);
      _lonController.text = lon.toStringAsFixed(4);

      try {
        final response = await http.get(Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10'));
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          _cityName = data['address']['city'] ??
              data['address']['town'] ??
              'Unknown';
        }
      } catch (_) {
        List<Placemark> placemarks =
        await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          _cityName = placemarks.first.locality ?? 'Unknown';
        }
      }
    } catch (_) {
      _errorMessage = 'Using default location (Malappuram)';
      _cityName = 'Malappuram';
    }

    if (_cityName == 'Unknown') _cityName = 'Malappuram';
    setState(() => _isLoadingLocation = false);
  }

  // ── Astronomy math ──
  double _calculateJD(DateTime dt) {
    int year = dt.year, month = dt.month, day = dt.day;
    double ut = dt.hour + dt.minute / 60.0;
    if (month <= 2) { year -= 1; month += 12; }
    int a = (year / 100).floor();
    int b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day + b - 1524.5 + ut / 24.0;
  }

  double _calculateGMST(double jd) {
    double d = jd - 2451545.0;
    return ((280.46061837 + 360.98564736629 * d) % 360) / 15.0;
  }

  Map<String, double> _raDecToAltAz(
      double ra, double dec, double lat, double lon, DateTime dt) {
    double jd = _calculateJD(dt);
    double gmst = _calculateGMST(jd);
    double lst = gmst + lon / 15.0;
    double ha = ((lst - ra) * 15.0) % 360;
    if (ha > 180) ha -= 360;
    if (ha < -180) ha += 360;

    double sinAlt = math.sin(dec * math.pi / 180) *
        math.sin(lat * math.pi / 180) +
        math.cos(dec * math.pi / 180) *
            math.cos(lat * math.pi / 180) *
            math.cos(ha * math.pi / 180);
    double alt = math.asin(sinAlt) * 180 / math.pi;

    double cosAz =
        (math.sin(dec * math.pi / 180) - math.sin(lat * math.pi / 180) * sinAlt) /
            (math.cos(lat * math.pi / 180) * math.cos(alt * math.pi / 180));
    double sinAz = math.cos(dec * math.pi / 180) *
        math.sin(ha * math.pi / 180) /
        math.cos(alt * math.pi / 180);
    double az = (math.atan2(sinAz, cosAz) * 180 / math.pi + 360) % 360;

    return {'alt': alt, 'az': az};
  }

  // Compute moon phase 0..1 (0 = new, 0.5 = full)
  double _getMoonPhase(DateTime dt) {
    double jd = _calculateJD(dt);
    double phase = ((jd - 2451549.5) / 29.53058853) % 1.0;
    return phase < 0 ? phase + 1 : phase;
  }

  Future<void> _fetchData() async {
    for (final c in _twinkleCtrl) { c.dispose(); }
    _twinkleCtrl.clear();
    setState(() {
      _isFetchingData = true;
      _starsData = [];
      _planetsData = [];
      _errorMessage = '';
    });

    double lat = double.tryParse(_latController.text) ?? 11.0510;
    double lon = double.tryParse(_lonController.text) ?? 76.0711;
    String apiDate = DateFormat('yyyy-MM-dd').format(_selectedDateTime);

    try {
      final response = await http.get(Uri.parse(
          'https://api.sunrise-sunset.org/json?lat=$lat&lng=$lon&date=$apiDate&formatted=0'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'OK') {
          var results = data['results'];
          String toLocal(String utcStr) {
            if (utcStr == 'N/A') return 'N/A';
            DateTime utc = DateTime.parse(utcStr);
            return DateFormat('hh:mm a').format(utc.add(const Duration(hours: 5, minutes: 30)));
          }
          _sunMoonData = {
            'sunrise': toLocal(results['sunrise'] ?? 'N/A'),
            'sunset': toLocal(results['sunset'] ?? 'N/A'),
            'moon_phase': 'Waning Crescent',
            'moon_illumination': '8',
          };
        }
      }
    } catch (_) {
      _sunMoonData = {
        'sunrise': '06:42 AM',
        'sunset': '06:33 PM',
        'moon_phase': 'Waning Crescent',
        'moon_illumination': '8',
      };
    }

    // Filter visible stars/planets
    final List<Map<String, dynamic>> visibleStars = [];
    for (var star in _brightStars) {
      final pos = _raDecToAltAz(star['ra'], star['dec'], lat, lon, _selectedDateTime);
      if ((pos['alt'] ?? 0) > 20 && (star['mag'] as double) < 2) {
        visibleStars.add({...star, 'alt': pos['alt'], 'az': pos['az']});
      }
    }
    for (var planet in _brightPlanets) {
      final pos = _raDecToAltAz(planet['ra'], planet['dec'], lat, lon, _selectedDateTime);
      if ((pos['alt'] ?? 0) > 20 && (planet['mag'] as double) < 2) {
        _planetsData.add({...planet, 'alt': pos['alt'], 'az': pos['az']});
      }
    }

    _starsData = visibleStars;

    // Create twinkle controllers for each item
    final totalItems = _starsData.length + _planetsData.length;
    for (int i = 0; i < totalItems; i++) {
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + _rng.nextInt(300)),
      );
      _twinkleCtrl.add(c);
      Future.delayed(Duration(milliseconds: 400 + i * 90), () {
        if (mounted) c.forward();
      });
    }

    setState(() => _isFetchingData = false);

    // Kick off post-load animations
    _sunArcCtrl.forward(from: 0);
  }

  Future<void> _onRefresh() async {
    _refreshCtrl.forward(from: 0);
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation || _isFetchingData) {
      return _buildLoadingScreen();
    }

    final moonPhase = _getMoonPhase(_selectedDateTime);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Refresh burst overlay ──
          AnimatedBuilder(
            animation: _refreshCtrl,
            builder: (_, __) {
              if (_refreshCtrl.value == 0 || _refreshCtrl.value >= 0.98) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: CustomPaint(
                  painter: _RefreshBurstPainter(
                    progress: _refreshCtrl.value,
                    rng: _rng,
                  ),
                ),
              );
            },
          ),

          RefreshIndicator(
            onRefresh: _onRefresh,
            color: const Color(0xFF9D8CFF),
            backgroundColor: const Color(0xFF1E244B),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  _buildHeader(),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Sunrise / Sunset ──
                        _sectionLabel('Sunrise & Sunset'),
                        const SizedBox(height: 12),
                        _buildSunCard(),

                        const SizedBox(height: 24),

                        // ── Moon Phase ──
                        _sectionLabel('Moon Phase'),
                        const SizedBox(height: 12),
                        _buildMoonCard(moonPhase),

                        const SizedBox(height: 24),

                        // ── Planets ──
                        _sectionLabel('Bright Planets Visible'),
                        const SizedBox(height: 12),
                        _buildPlanetsCard(),

                        const SizedBox(height: 24),

                        // ── Stars ──
                        _sectionLabel('Bright Stars Visible'),
                        const SizedBox(height: 12),
                        _buildStarsCard(),

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(_errorMessage,
                                style: const TextStyle(color: Color(0xFFFF6B6B))),
                          ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Loading screen
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: AnimatedBuilder(
              animation: _moonCtrl,
              builder: (_, __) => CustomPaint(
                painter: _MoonPhasePainter(
                  phase: _moonCtrl.value * 0.5,
                  glowIntensity: 0.6 + _moonCtrl.value * 0.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Scanning the skies...',
            style: TextStyle(color: Color(0xFF8890B8), fontSize: 14, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Header with location + date
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          children: [
            const Text(
              'VISIBLE TONIGHT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2.5,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3, end: 0),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF9D8CFF), size: 18),
                    const SizedBox(width: 6),
                    Text(_cityName,
                        style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    picker.DatePicker.showDateTimePicker(
                      context,
                      currentTime: _selectedDateTime,
                      onConfirm: (date) {
                        setState(() => _selectedDateTime = date);
                        _fetchData();
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E244B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF3D4580), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF9D8CFF), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM, HH:mm').format(_selectedDateTime),
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Sunrise / Sunset card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSunCard() {
    return AnimatedBuilder(
      animation: _sunArcCtrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(const Color(0xFF0D1033), const Color(0xFF1A2650),
                  _sunArcCtrl.value)!,
              Color.lerp(const Color(0xFF1A1040), const Color(0xFF2A1E5C),
                  _sunArcCtrl.value)!,
            ],
          ),
          border: Border.all(color: const Color(0xFF2D3570), width: 1),
        ),
        child: Column(
          children: [
            // Sun arc visualizer
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _SunArcPainter(progress: _sunArcCtrl.value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _sunInfoTile(
                      Icons.wb_sunny_outlined,
                      'SUNRISE',
                      _sunMoonData['sunrise'] ?? 'N/A',
                      const Color(0xFFFFB347),
                    ),
                  ),
                  Container(width: 1, height: 40, color: const Color(0xFF2D3570)),
                  Expanded(
                    child: _sunInfoTile(
                      Icons.wb_twilight_outlined,
                      'SUNSET',
                      _sunMoonData['sunset'] ?? 'N/A',
                      const Color(0xFFFF7043),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fade(duration: 600.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _sunInfoTile(IconData icon, String label, String time, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 10,
                letterSpacing: 1.2)),
        const SizedBox(height: 2),
        Text(time,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Moon phase card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMoonCard(double phase) {
    final phaseName = _moonPhaseName(phase);
    final illumination = (math.sin(phase * math.pi) * 100).round();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A0E28), Color(0xFF141830)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF1E2550), width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Animated moon
          AnimatedBuilder(
            animation: _moonCtrl,
            builder: (_, __) => SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: _MoonPhasePainter(
                  phase: phase,
                  glowIntensity: 0.6 + _moonCtrl.value * 0.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phaseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$illumination% illuminated',
                  style: const TextStyle(color: Color(0xFF8890B8), fontSize: 13),
                ),
                const SizedBox(height: 10),
                // Illumination bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: illumination / 100,
                    backgroundColor: const Color(0xFF1E2550),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.lerp(const Color(0xFF6070D0), const Color(0xFFFFFFE0),
                          illumination / 100)!,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 600.ms, delay: 100.ms).slideY(begin: 0.15, end: 0);
  }

  String _moonPhaseName(double phase) {
    if (phase < 0.03 || phase > 0.97) return 'New Moon';
    if (phase < 0.22) return 'Waxing Crescent';
    if (phase < 0.28) return 'First Quarter';
    if (phase < 0.47) return 'Waxing Gibbous';
    if (phase < 0.53) return 'Full Moon';
    if (phase < 0.72) return 'Waning Gibbous';
    if (phase < 0.78) return 'Last Quarter';
    return 'Waning Crescent';
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Planets card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPlanetsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1330).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2550), width: 1),
      ),
      child: _planetsData.isEmpty
          ? const Padding(
        padding: EdgeInsets.all(18),
        child: Text('No bright planets above the horizon right now',
            style: TextStyle(color: Color(0xFF6070A0), fontSize: 14)),
      )
          : Column(
        children: _planetsData.asMap().entries.map((entry) {
          final i = entry.key;
          final ctrl = i < _twinkleCtrl.length ? _twinkleCtrl[i] : null;
          return _buildCelestialTile(
            entry.value['name'],
            '${(entry.value['alt'] as double? ?? 0).toStringAsFixed(1)}° alt',
            Icons.public_outlined,
            const Color(0xFF60A0FF),
            i,
            ctrl,
            isPlanet: true,
          );
        }).toList(),
      ),
    ).animate().fade(duration: 600.ms, delay: 200.ms).slideY(begin: 0.15, end: 0);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Stars card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStarsCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1330).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2550), width: 1),
      ),
      child: _starsData.isEmpty
          ? const Padding(
        padding: EdgeInsets.all(18),
        child: Text('No bright stars above the horizon right now',
            style: TextStyle(color: Color(0xFF6070A0), fontSize: 14)),
      )
          : Column(
        children: _starsData.asMap().entries.map((entry) {
          final i = entry.key + _planetsData.length;
          final ctrl = i < _twinkleCtrl.length ? _twinkleCtrl[i] : null;
          return _buildCelestialTile(
            entry.value['name'],
            'mag ${(entry.value['mag'] as double).toStringAsFixed(2)}',
            Icons.star_outline_rounded,
            const Color(0xFFFFE080),
            i,
            ctrl,
            isPlanet: false,
          );
        }).toList(),
      ),
    ).animate().fade(duration: 600.ms, delay: 300.ms).slideY(begin: 0.15, end: 0);
  }

  Widget _buildCelestialTile(
      String name,
      String subtitle,
      IconData icon,
      Color color,
      int index,
      AnimationController? twinkleCtrl, {
        required bool isPlanet,
      }) {
    return AnimatedBuilder(
      animation: twinkleCtrl ?? const AlwaysStoppedAnimation(1.0),
      builder: (_, __) {
        final t = twinkleCtrl?.value ?? 1.0;
        final burst = math.sin(t * math.pi);
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Colors.white.withOpacity(0.04), width: 1),
            ),
          ),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Stack(
              alignment: Alignment.center,
              children: [
                // Twinkle burst ring
                if (burst > 0.05)
                  Container(
                    width: 36 + burst * 14,
                    height: 36 + burst * 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(burst * 0.18),
                    ),
                  ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(burst * 0.45),
                        blurRadius: 12 + burst * 8,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            title: Text(name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            subtitle: Text(subtitle,
                style: TextStyle(
                    color: color.withOpacity(0.7), fontSize: 12)),
            trailing: isPlanet
                ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Text(
                'Planet',
                style: TextStyle(color: color, fontSize: 10),
              ),
            )
                : null,
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF8890B8),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Moon Phase Painter
//  phase 0 = new moon, 0.25 = first quarter, 0.5 = full, 0.75 = last quarter
// ─────────────────────────────────────────────────────────────────────────────
class _MoonPhasePainter extends CustomPainter {
  final double phase;       // 0..1
  final double glowIntensity;

  const _MoonPhasePainter({required this.phase, this.glowIntensity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 4;

    // Outer glow
    final glowPaint = Paint()
      ..color = const Color(0xFFD0D8FF).withOpacity(glowIntensity * 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(Offset(cx, cy), r + 8, glowPaint);

    // Dark disk (unlit side)
    final darkPaint = Paint()..color = const Color(0xFF0A0E22);
    canvas.drawCircle(Offset(cx, cy), r, darkPaint);

    // Lit crescent using clip path
    canvas.save();
    canvas.clipPath(Path()
      ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));

    final litPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE8ECFF),
          const Color(0xFFB0B8E8),
          const Color(0xFF7080C0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    // Draw lit half based on phase
    // 0 = new (none lit), 0.5 = full (all lit)
    // We use an ellipse to fake the terminator curve
    final double phaseAngle = phase * 2 * math.pi;
    // x offset of ellipse: cos(phase*2pi) → -1 (new) .. +1 (full) .. -1 (new)
    final double termX = math.cos(phaseAngle) * r;

    if (phase >= 0.5) {
      // Right half always lit + left crescent growing
      canvas.drawRect(
          Rect.fromLTRB(cx - r, cy - r, cx + r, cy + r), litPaint);
      // Subtract dark ellipse from left for waxing
      final darkOver = Paint()
        ..color = const Color(0xFF0A0E22)
        ..blendMode = BlendMode.srcOver;
      final path = Path()
        ..addOval(Rect.fromLTRB(cx + termX - r * 0.1, cy - r,
            cx + r * 2 + termX - r * 0.1, cy + r));
      canvas.drawPath(path, darkOver);
    } else {
      // Left half lit + right crescent shrinking
      canvas.drawRect(
          Rect.fromLTRB(cx - r, cy - r, cx, cy + r), litPaint);
      final darkOver = Paint()
        ..color = const Color(0xFF0A0E22)
        ..blendMode = BlendMode.srcOver;
      final path = Path()
        ..addOval(Rect.fromLTRB(
            cx - r * 2 + termX + r * 0.1, cy - r, cx + termX + r * 0.1, cy + r));
      canvas.drawPath(path, darkOver);
    }

    canvas.restore();

    // Rim glow
    final rimPaint = Paint()
      ..color = const Color(0xFFB0C0FF).withOpacity(0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), r, rimPaint);

    // Surface craters (subtle dots)
    final craterPaint = Paint()
      ..color = const Color(0xFF7080B0).withOpacity(0.15);
    for (final crater in [
      [0.3, 0.4, 3.0],
      [0.6, 0.3, 2.0],
      [0.4, 0.65, 2.5],
      [0.55, 0.55, 1.5],
    ]) {
      canvas.drawCircle(
          Offset(cx - r + crater[0] * r * 2, cy - r + crater[1] * r * 2),
          crater[2],
          craterPaint);
    }
  }

  @override
  bool shouldRepaint(_MoonPhasePainter old) =>
      old.phase != phase || old.glowIntensity != glowIntensity;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Sun Arc Painter — parabolic arc with animated sun position
// ─────────────────────────────────────────────────────────────────────────────
class _SunArcPainter extends CustomPainter {
  final double progress; // 0..1

  const _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient that changes with progress (night → day → night)
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(const Color(0xFF050818), const Color(0xFF1A3A6A), progress)!,
          Color.lerp(const Color(0xFF0A0E22), const Color(0xFF0D2040), progress)!,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Horizon line
    final horizonPaint = Paint()
      ..color = const Color(0xFF1E3060).withOpacity(0.6)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, h * 0.82), Offset(w, h * 0.82), horizonPaint);

    // Arc path
    final arcPath = Path();
    const steps = 80;
    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final x = t * w;
      // Parabolic arc: highest at t=0.5
      final y = h * 0.82 - (4 * t * (1 - t)) * h * 0.62;
      if (i == 0) arcPath.moveTo(x, y);
      else arcPath.lineTo(x, y);
    }

    final arcPaint = Paint()
      ..color = const Color(0xFFFFAA40).withOpacity(0.25 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(arcPath, arcPaint);

    // Dashed version at full opacity below
    final dashedPaint = Paint()
      ..color = const Color(0xFFFFAA40).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(arcPath, dashedPaint);

    // Sun position along arc
    final sunT = progress.clamp(0.0, 1.0);
    final sunX = sunT * w;
    final sunY = h * 0.82 - (4 * sunT * (1 - sunT)) * h * 0.62;

    // Sun glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFCC44).withOpacity(0.30 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(Offset(sunX, sunY), 20, glowPaint);

    // Sun body
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFEE88),
          const Color(0xFFFFAA22),
        ],
      ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 10));
    canvas.drawCircle(Offset(sunX, sunY), 10, sunPaint);

    // Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFFCC44).withOpacity(0.6 * progress)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(sunX + 13 * math.cos(angle), sunY + 13 * math.sin(angle)),
        Offset(sunX + 18 * math.cos(angle), sunY + 18 * math.sin(angle)),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SunArcPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pull-to-refresh burst painter
// ─────────────────────────────────────────────────────────────────────────────
class _RefreshBurstPainter extends CustomPainter {
  final double progress;
  final math.Random rng;

  const _RefreshBurstPainter({required this.progress, required this.rng});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.08; // top of screen where refresh happens

    final alpha = progress < 0.5 ? progress * 2 : (1 - progress) * 2;

    // 20 radial burst particles
    final localRng = math.Random(99);
    for (int i = 0; i < 24; i++) {
      final angle = localRng.nextDouble() * math.pi * 2;
      final speed = localRng.nextDouble() * 0.35 + 0.15;
      final r = size.height * 0.55 * progress * speed;
      final px = cx + r * math.cos(angle);
      final py = cy + r * math.sin(angle);

      final starSize = localRng.nextDouble() * 2.5 + 0.8;
      final col = [
        const Color(0xFFFFFFFF),
        const Color(0xFFD0C8FF),
        const Color(0xFF8890FF),
        const Color(0xFFFFE080),
      ][i % 4];

      final paint = Paint()
        ..color = col.withOpacity(alpha * (1 - progress * 0.6))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(px, py), starSize, paint);
    }

    // Center flash
    final flashPaint = Paint()
      ..color = Colors.white.withOpacity(alpha * 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(cx, cy), 40 * progress, flashPaint);
  }

  @override
  bool shouldRepaint(_RefreshBurstPainter old) => old.progress != progress;
}