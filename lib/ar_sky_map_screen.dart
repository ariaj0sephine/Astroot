import 'dart:async';  // Added for StreamSubscription
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_2/ar_flutter_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:ar_flutter_plugin_2/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_2/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_2/managers/ar_session_manager.dart';

class ARSkyMapScreen extends StatefulWidget {
  const ARSkyMapScreen({super.key});

  @override
  State<ARSkyMapScreen> createState() => _ARSkyMapScreenState();
}

class _ARSkyMapScreenState extends State<ARSkyMapScreen> {
  Position? currentPosition;
  double heading = 0;
  StreamSubscription<Position>? _positionStream;  // For continuous GPS updates
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;

  @override
  void initState() {
    super.initState();
    _getLocation();          // Get first location immediately
    _listenToCompass();      // Start compass
    _startLocationStream();  // Start continuous GPS updates
  }

  // -------- INITIAL LOCATION (one-time when screen opens) --------
  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) setState(() {});
  }

  // -------- CONTINUOUS LOCATION STREAM (updates as you move or wait outdoors) --------
  void _startLocationStream() {
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,  // Update every 5 meters moved (saves battery)
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: settings).listen(
          (Position pos) {
        if (mounted) {
          setState(() => currentPosition = pos);
        }
      },
      onError: (e) => print('Location stream error: $e'),
    );
  }

  // -------- COMPASS --------
  void _listenToCompass() {
    magnetometerEventStream().listen((event) {
      final angle = (math.atan2(event.y, event.x) * 180 / math.pi + 360) % 360;
      if (mounted) setState(() => heading = angle);
    });
  }

  // -------- AR INIT --------
  void _onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arSessionManager!.onInitialize(
      showPlanes: false,
      showFeaturePoints: false,
      handleTaps: false,
    );
  }

  // -------- UI --------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Lighter dark overlay – clear camera in day, nice night feel
          Container(color: Colors.black.withOpacity(0.4)),

          // AR camera view
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.none,
            // No floor detection – perfect for sky
          ),

          // Top-left info panel (now updates in real time outdoors)
          Positioned(
            top: 40,
            left: 20,
            child: _infoPanel(),
          ),

          // Direction labels
          _skyLabel("North", 0),
          _skyLabel("East", 90),
          _skyLabel("South", 180),
          _skyLabel("West", 270),

          // Major stars & constellations – spaced to avoid overlap
          _skyLabel("Polaris ★", 0),                    // North Star
          _skyLabel("Sirius ★\n(brightest)", 140),
          _skyLabel("Orion Belt", 180),
          _skyLabel("Betelgeuse\n(red shoulder)", 165),
          _skyLabel("Rigel\n(blue foot)", 195),
          _skyLabel("Big Dipper", 30),
          _skyLabel("Cassiopeia", 330),
          _skyLabel("Pleiades", 90),
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
          Text(
            'Lat: ${currentPosition?.latitude.toStringAsFixed(2) ?? "--"}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Lon: ${currentPosition?.longitude.toStringAsFixed(2) ?? "--"}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            'Heading: ${heading.toStringAsFixed(0)}°',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Glowing label with vertical spread to prevent overlap
  Widget _skyLabel(String text, double targetAngle) {
    final diff = ((targetAngle - heading + 540) % 360) - 180;
    if (diff.abs() > 45) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final x = (screenWidth / 2) + (diff / 45) * (screenWidth / 2);

    return Positioned(
      top: 80 + (diff.abs() * 4).clamp(0, 300).toDouble(),  // Vertical spread – no overlap
      left: x - 80,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 10, color: Colors.black),
            Shadow(blurRadius: 20, color: Colors.cyan.withOpacity(0.6)),
            Shadow(blurRadius: 30, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();  // Stop GPS stream to save battery
    arSessionManager?.dispose();
    super.dispose();
  }
}