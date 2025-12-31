import 'package:flutter/material.dart';

class EditNamePage extends StatefulWidget {
  final String currentName;

  const EditNamePage({super.key, required this.currentName});

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  late TextEditingController _controller;

  static const LinearGradient _cosmicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF00132D),
      Color(0xFF00142E),
      Color(0xFF001E45),
      Color(0xFF002657),
    ],
    stops: [0.0, 0.15, 0.54, 1.0],
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Name',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: _cosmicGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(28.0), // Balanced side & bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // Pushes content down from the app bar
              const Text(
                'Your name',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter your name here...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_controller.text.length}/15',
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _controller.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}