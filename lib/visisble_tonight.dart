import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class VisibleTonightScreen extends StatefulWidget {
  const VisibleTonightScreen({super.key});

  @override
  State<VisibleTonightScreen> createState() => _VisibleTonightScreenState();
}

class _VisibleTonightScreenState extends State<VisibleTonightScreen> {
  final TextEditingController _latController = TextEditingController(text: '8.8932');
  final TextEditingController _lonController = TextEditingController(text: '76.6141');
  DateTime _selectedDateTime = DateTime.now();
  Map<String, dynamic> _sunMoonData = {};
  List<Map<String, dynamic>> _starsData = [];
  List<Map<String, dynamic>> _planetsData = [];
  String _errorMessage = '';
  String _cityName = 'Unknown';
  bool _isLoadingLocation = true;
  bool _isFetchingData = false;

  // Hardcoded bright stars (your list, slightly trimmed for speed)
  final List<Map<String, dynamic>> _brightStars = [
    {'name': 'Sirius', 'ra': 6.7525, 'dec': -16.7161, 'mag': -1.46},
    {'name': 'Canopus', 'ra': 6.3992, 'dec': -52.6956, 'mag': -0.72},
    {'name': 'Arcturus', 'ra': 14.2608, 'dec': 19.1822, 'mag': -0.04},
    {'name': 'Vega', 'ra': 18.6156, 'dec': 38.7828, 'mag': 0.03},
    {'name': 'Capella', 'ra': 5.2781, 'dec': 45.9972, 'mag': 0.08},
    {'name': 'Rigel', 'ra': 5.2422, 'dec': -8.2016, 'mag': 0.12},
    {'name': 'Procyon', 'ra': 7.6550, 'dec': 5.2250, 'mag': 0.38},
    {'name': 'Betelgeuse', 'ra': 5.9195, 'dec': 7.4070, 'mag': 0.50},
    {'name': 'Altair', 'ra': 19.8464, 'dec': 8.8672, 'mag': 0.77},
  ];

  // Hardcoded bright planets with approximate RA/DEC/mag for demo (positions rough for Feb 2026)
  final List<Map<String, dynamic>> _brightPlanets = [
    {'name': 'Venus', 'ra': 23.0, 'dec': -5.0, 'mag': -4.0},
    {'name': 'Jupiter', 'ra': 3.5, 'dec': 18.0, 'mag': -2.5},
    {'name': 'Saturn', 'ra': 11.0, 'dec': 5.0, 'mag': 0.5},
    {'name': 'Mercury', 'ra': 22.5, 'dec': -10.0, 'mag': -0.5},
    {'name': 'Mars', 'ra': 1.0, 'dec': 5.0, 'mag': 0.5},
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation();
    await _fetchData();
  }

  // LOCATION
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = '';
    });
    double lat = 8.8932;
    double lon = 76.6141;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw 'Location services disabled';
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permission denied';
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      lat = position.latitude;
      lon = position.longitude;
      _latController.text = lat.toStringAsFixed(4);
      _lonController.text = lon.toStringAsFixed(4);

      // Get city name using Nominatim API as fallback if geocoding fails
      try {
        final response = await http.get(Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10'));
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          _cityName = data['address']['city'] ?? data['address']['town'] ?? data['address']['village'] ?? 'Unknown';
        }
      } catch (e) {
        // Fallback to geocoding package
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          _cityName = placemarks.first.locality ?? placemarks.first.administrativeArea ?? 'Unknown';
        }
      }
    } catch (e) {
      _errorMessage = 'Using default Kollam (8.8932, 76.6141)';
      _cityName = 'Kollam';
    }
    if (_cityName.trim().isEmpty || _cityName == 'Unknown') {
      _cityName = 'Thiruvananthapuram'; // Additional fallback based on common location
    }
    setState(() {
      _isLoadingLocation = false;
    });
  }

  // ASTRONOMY MATH (your functions - small safety added)
  double _calculateJD(DateTime dt) {
    int year = dt.year;
    int month = dt.month;
    int day = dt.day;
    double ut = dt.hour + dt.minute / 60.0;
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    int a = (year / 100).floor();
    int b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5 +
        ut / 24.0;
  }

  double _calculateGMST(double jd) {
    double d = jd - 2451545.0;
    double gmst = (280.46061837 + 360.98564736629 * d) % 360;
    return gmst / 15.0;
  }

  Map<String, double> _raDecToAltAz(double ra, double dec, double lat, double lon, DateTime dt) {
    double jd = _calculateJD(dt);
    double gmst = _calculateGMST(jd);
    double lst = gmst + lon / 15.0;
    double ha = (lst - ra) * 15.0;
    ha = ha % 360;
    if (ha > 180) ha -= 360;
    if (ha < -180) ha += 360;
    double sinAlt = math.sin(dec * math.pi / 180) * math.sin(lat * math.pi / 180) +
        math.cos(dec * math.pi / 180) * math.cos(lat * math.pi / 180) * math.cos(ha * math.pi / 180);
    double alt = math.asin(sinAlt) * 180 / math.pi;
    double cosAz = (math.sin(dec * math.pi / 180) - math.sin(lat * math.pi / 180) * sinAlt) /
        (math.cos(lat * math.pi / 180) * math.cos(alt * math.pi / 180));
    double sinAz = math.cos(dec * math.pi / 180) * math.sin(ha * math.pi / 180) /
        math.cos(alt * math.pi / 180);
    double az = math.atan2(sinAz, cosAz) * 180 / math.pi;
    az = (az + 360) % 360;
    return {'alt': alt, 'az': az};
  }

  // FETCH DATA – dynamic sun with sunrise-sunset.org (free, no key), fallback for moon
  Future<void> _fetchData() async {
    setState(() {
      _isFetchingData = true;
      _starsData = [];
      _planetsData = [];
      _errorMessage = ''; // Clear old errors
    });

    double lat = double.tryParse(_latController.text) ?? 8.8932;
    double lon = double.tryParse(_lonController.text) ?? 76.6141;

    // Format date for API (YYYY-MM-DD)
    String apiDate = DateFormat('yyyy-MM-dd').format(_selectedDateTime);

    // sunrise-sunset.org API URL – free, no key needed
    final String sunUrl =
        'https://api.sunrise-sunset.org/json?lat=$lat&lng=$lon&date=$apiDate&formatted=0';

    try {
      final response = await http.get(Uri.parse(sunUrl));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['status'] == 'OK') {
          var results = data['results'];

          // Times are in UTC ISO format, e.g. "2026-02-14T01:11:00+00:00"
          String sunriseUtc = results['sunrise'] ?? 'N/A';
          String sunsetUtc = results['sunset'] ?? 'N/A';

          // Convert UTC to IST (UTC + 5:30 hours)
          String sunriseLocal = 'N/A';
          String sunsetLocal = 'N/A';

          if (sunriseUtc != 'N/A') {
            DateTime utcTime = DateTime.parse(sunriseUtc);
            DateTime istTime = utcTime.add(Duration(hours: 5, minutes: 30));
            sunriseLocal = DateFormat('hh:mm a').format(istTime); // e.g., "06:41 AM"
          }

          if (sunsetUtc != 'N/A') {
            DateTime utcTime = DateTime.parse(sunsetUtc);
            DateTime istTime = utcTime.add(Duration(hours: 5, minutes: 30));
            sunsetLocal = DateFormat('hh:mm a').format(istTime); // e.g., "18:33 PM"
          }

          _sunMoonData = {
            'sunrise': sunriseLocal,
            'sunset': sunsetLocal,
            'moon_phase': 'Waning Crescent',  // hardcoded for now
            'moon_illumination': '8',
          };
        } else {
          throw 'API returned non-OK status';
        }
      } else {
        _errorMessage = 'Sun API error: ${response.statusCode} – using fallback';
        _sunMoonData = {
          'sunrise': '06:42 AM',
          'sunset': '18:33 PM',
          'moon_phase': 'Waning Crescent',
          'moon_illumination': '8',
        };
      }
    } catch (e) {
      _errorMessage = 'No internet or sun API issue – using fallback data';
      _sunMoonData = {
        'sunrise': '06:42 AM',
        'sunset': '18:33 PM',
        'moon_phase': 'Waning Crescent',
        'moon_illumination': '8',
      };
    }

    // Stars calculation (unchanged, dynamic via math)
    for (var star in _brightStars) {
      final pos = _raDecToAltAz(star['ra'], star['dec'], lat, lon, _selectedDateTime);
      double alt = pos['alt'] ?? 0.0;
      if (alt > 20 && (star['mag'] as double) < 2) {
        _starsData.add({
          'name': star['name'],
        });
      }
    }
    _starsData.sort((a, b) => (a['mag'] ?? 999).compareTo(b['mag'] ?? 999)); // If mag missing, sort safe

    // Planets calculation (unchanged)
    for (var planet in _brightPlanets) {
      final pos = _raDecToAltAz(planet['ra'], planet['dec'], lat, lon, _selectedDateTime);
      double alt = pos['alt'] ?? 0.0;
      if (alt > 20 && (planet['mag'] as double) < 2) {
        _planetsData.add({
          'name': planet['name'],
        });
      }
    }
    _planetsData.sort((a, b) => (a['mag'] ?? 999).compareTo(b['mag'] ?? 999));

    setState(() {
      _isFetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // No app bar for full gradient
      body: _isLoadingLocation || _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00132D),
              Color(0xFF00142E),
              Color(0xFF001E45),
              Color(0xFF002657),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: const Text(
                            'Visible Tonight',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: Location with icon
                            Expanded(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.location_on,
                                    color: Colors.white),
                                title: Text(
                                  _cityName,
                                  style:
                                  const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 60),
                            // Right: Timestamp with icon
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    DateFormat('dd-MM-yyyy HH:mm')
                                        .format(_selectedDateTime),
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                  trailing: const Icon(
                                      Icons.calendar_today,
                                      color: Colors.white),
                                  onTap: () {
                                    picker.DatePicker.showDateTimePicker(
                                      context,
                                      currentTime: _selectedDateTime,
                                      onConfirm: (date) {
                                        setState(() {
                                          _selectedDateTime = date;
                                        });
                                        _fetchData();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Sun: Sunrise & Sunset - Events-style card
                        const Text('Sunset & Sunrise',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(51, 57, 118, 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.wb_sunny,
                                    color: Colors.white),
                                title: Text(
                                  'Sunrise: ${_sunMoonData['sunrise'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.wb_twilight,
                                    color: Colors.white),
                                title: Text(
                                  'Sunset: ${_sunMoonData['sunset'] ?? 'N/A'}',
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Moon Phase - Events-style card
                        const Text('Moon Phase',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(51, 57, 118, 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.nights_stay,
                                color: Colors.white),
                            title: Text(
                              '${_sunMoonData['moon_phase'] ?? 'Unknown'} (${_sunMoonData['moon_illumination'] ?? 'N/A'}%)',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bright Planets Visible - Events-style card
                        const Text('Bright Planets Visible',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(51, 57, 118, 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: _planetsData.isEmpty
                                ? [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No bright planets visible right now',
                                  style: TextStyle(
                                      color: Colors.white70),
                                ),
                              )
                            ]
                                : _planetsData.map((p) => ListTile(
                              leading: const Icon(Icons.public,
                                  color: Colors.white),
                              title: Text(
                                '${p['name']}',
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bright Stars Visible - Events-style card
                        const Text('Bright Stars Visible',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(51, 57, 118, 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: _starsData.isEmpty
                                ? [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'No bright stars visible right now',
                                  style: TextStyle(
                                      color: Colors.white70),
                                ),
                              )
                            ]
                                : _starsData.map((s) => ListTile(
                              leading: const Icon(Icons.star,
                                  color: Colors.white),
                              title: Text(
                                '${s['name']}',
                                style: const TextStyle(
                                    color: Colors.white),
                              ),
                            )).toList(),
                          ),
                        ),

                        // Error message (if any)
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}