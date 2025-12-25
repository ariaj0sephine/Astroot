import 'package:flutter/material.dart';

class EditAboutPage extends StatefulWidget {
  final String currentAbout;

  const EditAboutPage({super.key, required this.currentAbout});

  @override
  State<EditAboutPage> createState() => _EditAboutPageState();
}

class _EditAboutPageState extends State<EditAboutPage> {
  String selectedAbout = '';

  final List<String> options = [
    'Best All-Around',
    'Stargazing Lover',
    'Telescope Enthusiast',
    'Curious Explorer',
  ];

  @override
  void initState() {
    super.initState();
    selectedAbout = widget.currentAbout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001A72),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedAbout = 'Just..Do it';
              });
            },
            child: const Text(
              'Clear all',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Currently set to',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              selectedAbout,
              style: const TextStyle(color: Colors.purple, fontSize: 18),
            ),
            const SizedBox(height: 32),
            const Text(
              'Select About',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 16),
            ...options.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedAbout = option;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: selectedAbout == option
                        ? Border.all(color: Colors.purple, width: 2)
                        : null,
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedAbout);
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
    );
  }
}