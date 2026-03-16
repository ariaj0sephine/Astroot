import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class CameraTab extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const CameraTab({super.key, this.onBackPressed});

  @override
  State<CameraTab> createState() => _CameraTabState();
}

class _CameraTabState extends State<CameraTab> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    final selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
    );
    await _controller!.initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ==================== GALLERY (EASY TESTING) ====================
  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected! Sharpening stars now...'),
            backgroundColor: Color(0xFF64B5FF),
          ),
        );

        final processedBytes = await _processSkyPhoto(image.path);
        if (mounted && processedBytes != null) {
          _showProcessedPreview(processedBytes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  // ==================== LIVE CAMERA SNAP ====================
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile photo = await _controller!.takePicture();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo snapped! Sharpening stars now...'),
            backgroundColor: Color(0xFF64B5FF),
          ),
        );

        final processedBytes = await _processSkyPhoto(photo.path);
        if (mounted && processedBytes != null) {
          _showProcessedPreview(processedBytes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera error – try again!')),
        );
      }
    }
  }

  // ==================== SIMPLE STAR SHARPENING (your "OpenCV") ====================
  Future<Uint8List?> _processSkyPhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) return null;

      image = img.copyResize(image, width: 300);           // Fast for mobile
      image = img.grayscale(image);                        // Makes stars stand out
      image = img.contrast(image, contrast: 200);          // Stars pop more
      image = img.adjustColor(image, brightness: 0.3);     // Brighten night sky

      return Uint8List.fromList(img.encodePng(image));
    } catch (e) {
      print('Processing error: $e');
      return null;
    }
  }

  // ==================== FIXED PREVIEW POPUP (this was the bug) ====================
  void _showProcessedPreview(Uint8List processedBytes) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0E1A).withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF333976), width: 1),
        ),
        title: const Text('Stars Detected & Sharpened! 🌌', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edges highlighted – ready for AI!', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                processedBytes,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showRealNyckelIdentification(processedBytes);
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF64B5FF)),
            child: const Text('Identify Star!'),
          ),
        ],
      ),
    );
  }

  // ==================== NYCKEL AI + FIREBASE SAVE (rest of code is same as yours) ====================
  String? _cachedToken;
  DateTime? _tokenExpiry;

  Future<String> _getNyckelToken() async {
    if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;
    }

    const String clientId = '4b2ltnwglud894kton5ia5yfjkpcne3k';
    const String clientSecret = '97b0fb3igvfs6s2vkwyc3bjzcm19xks6qsz1tjddjm2fp69qiurqfqgyobos9ukv';

    final response = await http.post(
      Uri.parse('https://www.nyckel.com/connect/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret',
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      _cachedToken = json['access_token'];
      _tokenExpiry = DateTime.now().add(const Duration(hours: 1));
      return _cachedToken!;
    } else {
      throw 'Token error';
    }
  }

  Future<void> _showRealNyckelIdentification(Uint8List processedBytes) async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: Color(0xFF0A0E1A),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF64B5FF)),
            SizedBox(height: 20),
            Text('Identifying with Nyckel AI...', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );

    try {
      final token = await _getNyckelToken();
      const String nyckelUrl = 'https://www.nyckel.com/v1/functions/constellations/invoke';

      final request = http.MultipartRequest('POST', Uri.parse(nyckelUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes('image', processedBytes, filename: 'star.jpg'));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (mounted) Navigator.pop(context);

      if (jsonResponse['labelName'] != null) {
        final String name = jsonResponse['labelName'];
        final double confidence = (jsonResponse['confidence'] ?? 0.0) * 100;

        final Map<String, String> facts = {
          'Taurus': 'The Bull constellation! Home to Aldebaran and the Pleiades.',
          'Cancer': 'The Crab – contains the beautiful Beehive Cluster.',
          'Vulpecula': 'The Little Fox – home to the bright Dumbbell Nebula.',
          'Scorpius': 'The Scorpion with red heart Antares.',
          'Orion': 'The Hunter – most famous constellation!',
          'Sirius': 'Brightest star in the sky – Dog Star.',
          'Jupiter': 'Largest planet – looks like a bright star.',
          'Venus': 'Evening/Morning Star – shines like a diamond.',
          'Polaris': 'The North Star – always points north.',
          'Orion Nebula': 'Star factory – looks fuzzy in Orion’s sword.',
        };

        final String fact = facts[name] ?? 'Amazing celestial object!';

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1F2E).withOpacity(0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Nyckel Says: $name (${confidence.toStringAsFixed(0)}%) 🌟',
                  style: const TextStyle(color: Colors.white, fontSize: 22)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Fun Fact:', style: TextStyle(color: Color(0xFF64B5FF), fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(fact, style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(processedBytes, height: 220, fit: BoxFit.cover),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _saveToDatabase(processedBytes, {'name': name, 'fact': fact});
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Amazing! Back to Camera', style: TextStyle(color: Color(0xFF64B5FF))),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nyckel not sure – try clearer photo')));
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI error: $e')));
      }
    }
  }

  Future<void> _saveToDatabase(Uint8List bytes, Map<String, String> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log in to save! (demo mode)')));
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('observations')
        .add({
      'star_name': data['name'],
      'fact': data['fact'],
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Observation saved! Check Firebase')));
    }
  }

  // ==================== UI (your exact design + twinkling stars) ====================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && _controller != null) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),
              const IgnorePointer(child: TwinklingStars()),
              SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gallery button
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                            child: IconButton(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                            ),
                          ),
                          // Camera button with glow animation
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!, width: 2),
                            ),
                            child: IconButton(
                              onPressed: _takePicture,
                              icon: Icon(Icons.camera_alt, color: Colors.grey[600], size: 35),
                            ),
                          ).animate(onPlay: (c) => c.repeat(reverse: true)).boxShadow(
                            begin: const BoxShadow(color: Colors.transparent),
                            end: BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 20, spreadRadius: 5),
                            duration: 2.seconds,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF64B5FF)),
                SizedBox(height: 20),
                Text('Opening camera...', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Twinkling stars effect (unchanged – looks beautiful)
class TwinklingStars extends StatefulWidget {
  const TwinklingStars({super.key});
  @override
  State<TwinklingStars> createState() => _TwinklingStarsState();
}

class _TwinklingStarsState extends State<TwinklingStars> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _generateStars();
  }

  void _generateStars() {
    final random = math.Random();
    for (int i = 0; i < 40; i++) {
      _stars.add(Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        blinkOffset: random.nextDouble() * math.pi * 2,
        blinkSpeed: random.nextDouble() * 2 + 1,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(painter: StarPainter(stars: _stars, animationValue: _controller.value), size: Size.infinite),
    );
  }
}

class Star {
  final double x, y, size, blinkOffset, blinkSpeed;
  Star({required this.x, required this.y, required this.size, required this.blinkOffset, required this.blinkSpeed});
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;
  StarPainter({required this.stars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var star in stars) {
      final opacity = (math.sin(animationValue * math.pi * 2 * star.blinkSpeed + star.blinkOffset) + 1) / 2;
      paint.color = Colors.white.withOpacity(opacity * 0.7);
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}