import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final XFile photo = await _controller!.takePicture();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo snapped! Ready for AI identification'),
            backgroundColor: Color(0xFF64B5FF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not take photo')),
        );
      }
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
              // Camera preview—now no ignore needed (no custom back to block)
              CameraPreview(_controller!),
              // Simplified overlay: Just bottom shutter (full height via Column)
              SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,  // Bottom-only now
                  children: [
                    const Spacer(),  // Pushes shutter to bottom
                    // Bottom shutter (unchanged)
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: FloatingActionButton(
                        backgroundColor: const Color(0xFF64B5FF),
                        onPressed: _takePicture,
                        child: const Icon(Icons.camera_alt, size: 35, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(  // Loading unchanged
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF64B5FF)),
              SizedBox(height: 20),
              Text('Opening camera...', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        );
      },
    );
  }
}