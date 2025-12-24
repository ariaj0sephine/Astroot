import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  // For encoding bytes

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

  // Pick from Gallery (for easy testing with sample star photos)
  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected from gallery! Sharpening stars with simple filters...'),
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
          SnackBar(
            content: Text('Gallery pick failed—make sure you have photos saved. Error: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Handles camera snaps (reuses the same processing & flow)
  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile photo = await _controller!.takePicture();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo snapped! Sharpening stars with simple filters...'),
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
          const SnackBar(content: Text('Snap failed—try again!')),
        );
      }
    }
  }

  Future<Uint8List?> _processSkyPhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      final bytes = await file.readAsBytes();
      var originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;

      // Process: Resize for speed, grayscale for edge detection, boost contrast for stars, slight sharpen
      originalImage = img.copyResize(originalImage, width: 300);  // Shrink to 300px wide—faster processing, good for mobile
      var grayImage = img.grayscale(originalImage);  // Convert to black/white—helps spot bright stars vs. dark sky
      var contrastImage = img.contrast(grayImage, contrast: 200);  // Crank contrast to 200%—makes faint stars pop without overdoing it
      var sharpenedImage = img.adjustColor(contrastImage, brightness: 0.3);  // +30% brightness boost—lights up dim night-sky details

      // Encode as PNG bytes (lossless, keeps star edges crisp for later AI)
      return Uint8List.fromList(img.encodePng(sharpenedImage));
    } catch (e) {
      print('Processing error: $e');  // Logs to console for debugging (check in VS Code terminal)
      return null;
    }
  }

  void _showProcessedPreview(Uint8List processedBytes) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0E1A),  // Dark space theme—easy on eyes for night use
        title: const Text('Stars Detected & Sharpened! 🌌', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edges highlighted—perfect for AI star identification!', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                processedBytes,
                height: 250,
                fit: BoxFit.contain,  // Keeps aspect ratio—no squished stars
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

  String? _cachedToken;  // Holds the token for ~1 hour (add this at top of _CameraTabState class, outside functions)
  DateTime? _tokenExpiry;  // Tracks when it expires

  Future<String> _getNyckelToken() async {
    if (_cachedToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedToken!;  // Reuse if still fresh—fast!
    }

    // YOUR CREDENTIALS — paste here once (Client Secret stays private!)
    const String clientId = '4b2ltnwglud894kton5ia5yfjkpcne3k';      // Paste your Client ID (public)
    const String clientSecret = '97b0fb3igvfs6s2vkwyc3bjzcm19xks6qsz1tjddjm2fp69qiurqfqgyobos9ukv';  // Paste your Client Secret (keep secret!)

    try {
      var tokenResponse = await http.post(
        Uri.parse('https://www.nyckel.com/connect/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret',
      );

      if (tokenResponse.statusCode == 200) {
        var json = jsonDecode(tokenResponse.body);
        _cachedToken = json['access_token'];
        _tokenExpiry = DateTime.now().add(const Duration(hours: 1));  // Nyckel tokens last 1 hour
        return _cachedToken!;
      } else {
        throw 'Token error: ${tokenResponse.body}';
      }
    } catch (e) {
      throw 'Token fetch failed: $e';
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
      // Get fresh/ cached token
      String token = await _getNyckelToken();

      // YOUR FUNCTION URL — paste your full Invocation URL here!
      const String nyckelUrl = 'https://www.nyckel.com/v1/functions/constellations/invoke';
      var request = http.MultipartRequest('POST', Uri.parse(nyckelUrl));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes('image', processedBytes, filename: 'star.jpg'));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (mounted) Navigator.pop(context);  // Close loading

      if (jsonResponse['labelName'] != null) {
        String identifiedName = jsonResponse['labelName'];
        double confidence = (jsonResponse['confidence'] ?? 0.0) * 100;

        // Your fact list (add all your trained labels here!)
        final Map<String, String> facts = {
          'Orion': 'Famous hunter constellation—easy to spot with three belt stars and bright Betelgeuse!',
          'Sirius': 'Brightest star in the night sky – known as the Dog Star!',
          'Jupiter': 'Largest planet – visible as a bright "star" with moons!',
          'Venus': 'Brightest planet – often called the Evening or Morning Star!',
          'Orion Nebula': 'Stunning star factory – visible as fuzzy patch in Orion!',
          'Polaris': 'The North Star – helps navigation for centuries!',
          // Add more for your trained classes!
        };

        String fact = facts[identifiedName] ?? 'Amazing find! This is a celestial object.';

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1A1F2E),
              title: Text('Nyckel Says: $identifiedName (${confidence.toStringAsFixed(0)}% sure) 🌟',
                  style: const TextStyle(color: Colors.white, fontSize: 22)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Fun Fact:', style: TextStyle(color: Color(0xFF64B5FF), fontSize: 18)),
                  const SizedBox(height: 10),
                  Text(fact, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/background.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _saveToDatabase(processedBytes, {'name': identifiedName, 'fact': fact});
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
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nyckel unsure—try a clearer photo!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI issue: $e — check credentials/internet')),
        );
      }
    }
  }

  Future<void> _saveToDatabase(Uint8List processedBytes, Map<String, String> identifiedStar) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // Quick debug message (shows UID snippet—helps spot login issues during tests)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user != null
                ? 'Starting save for user: ${user.uid.substring(0, 10)}...'  // Trims long UID for clean toast
                : 'No user logged in – save skipped (demo mode)'),
            backgroundColor: const Color(0xFF64B5FF),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (user == null) {
        // Graceful skip—no crash, just notify
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log in to save observations! (Using demo for now)')),
          );
        }
        return;  // Exit early—keeps flow smooth
      }

      // OPTIONAL: Upload to Storage (uncomment if you want cloud photos later—free tier handles ~5GB/month)
      // final timestamp = DateTime.now().millisecondsSinceEpoch;
      // final storageRef = FirebaseStorage.instance
      //     .ref()
      //     .child('observations/${user.uid}/$timestamp.png');
      //
      // final uploadTask = storageRef.putData(processedBytes);
      // await uploadTask.whenComplete(() => null);
      // final photoUrl = await storageRef.getDownloadURL();

      // Core save: Add to Firestore (free, no billing—up to 20K writes/day)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('observations')
          .add({
        // 'photo_url': photoUrl,  // Uncomment after enabling Storage upload
        'star_name': identifiedStar['name'],
        'fact': identifiedStar['fact'],
        'timestamp': FieldValue.serverTimestamp(),  // Auto-syncs to server time—accurate across devices
      });

      // Victory message—celebrates the save
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Observation saved to your collection! 🌟 Check Firebase console to see it.'),
            backgroundColor: Color(0xFF64B5FF),
          ),
        );
      }
    } catch (e) {
      // Friendly error—hints at common fixes
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save hiccup: $e (Try checking WiFi or Firebase rules)'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Full save error: $e');  // Console log for your debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && _controller != null) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Live camera preview (only shows if camera is ready)
              CameraPreview(_controller!),
              // UI Overlay: Buttons at bottom
              SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),  // Pushes buttons to bottom
                    // UPDATED: Custom button row matching your design—square gallery on left, large circular camera on right
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // LEFT: Gallery Button (square, black bg, white icon—like your image's photo icon)
                          Container(
                            width: 60,  // Square size—matches typical icon buttons
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,  // Black background as in your image
                              borderRadius: BorderRadius.circular(8),  // Slight rounding for modern feel (0 for sharp square)
                            ),
                            child: IconButton(
                              onPressed: _pickFromGallery,
                              icon: const Icon(
                                Icons.photo_library,  // Photo gallery icon (mountains + sun in your image)
                                color: Colors.white,
                                size: 30,  // Medium size—fits square without crowding
                              ),
                              tooltip: 'Pick from Gallery',  // Long-press hint for accessibility
                            ),
                          ),
                          // RIGHT: Camera Snap Button (large white circle with subtle gray ring—like your image)
                          Container(
                            width: 80,  // Larger circle for emphasis (main action)
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,  // White fill as in your image
                              shape: BoxShape.circle,  // Perfect circle
                              border: Border.all(
                                color: Colors.grey[300]!,  // Light gray outer ring for depth (matches subtle outline)
                                width: 2,  // Thin border—doesn't overpower
                              ),
                            ),
                            child: IconButton(
                              onPressed: _takePicture,
                              icon: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[600],  // Darker gray icon for contrast on white
                                size: 35,  // Slightly larger—feels prominent
                              ),
                              tooltip: 'Take Live Snap',
                            ),
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
        // Loading screen while camera initializes
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),  // Dark theme match
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