import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // starts on Camera tab

  static const List<Widget> _screens = [
    HomeTab(),
    CameraTab(),
    CalendarTab(),
    ProfileTab(),
  ];

  // Your cosmic gradient (same everywhere)
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00132D), // darkest shade – perfect blend
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ASTROOT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: _cosmicGradient)),
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 84, // a little taller so icons have breathing room
        child: NavigationBar(
          backgroundColor: Colors.black.withOpacity(0.4), // subtle dark glass effect
          indicatorColor: const Color(0xFF56D3A3),
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide, // no labels
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 30),
              selectedIcon: Icon(Icons.home, size: 30),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined, size: 30),
              selectedIcon: Icon(Icons.camera_alt, size: 30),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, size: 30),
              selectedIcon: Icon(Icons.calendar_today, size: 30),
              label: '',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined, size: 30),
              selectedIcon: Icon(Icons.account_circle, size: 30),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── Tabs (unchanged, just clean) ───────────────────────
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Container(color: const Color(0xFF00145).withOpacity(0.15)),
      ),
      const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Home Tab: Sky Map & Events\n(Tap to explore stars!)',
            style: TextStyle(fontSize: 20, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}

class CameraTab extends StatelessWidget {
  const CameraTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Camera Tab: Point & Identify\n(Add camera here next week!)',
      style: TextStyle(fontSize: 20, color: Colors.white),
      textAlign: TextAlign.center,
    ),
  );
}

class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Text(
      'Calendar Tab: Facts & Read Aloud\n(Dive into astronomy!)',
      style: TextStyle(fontSize: 20, color: Colors.white),
      textAlign: TextAlign.center,
    ),
  );
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Profile Tab\nManage Account & Saved Stars',
          style: TextStyle(fontSize: 20, color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: null,
          child: Text('Sign In (Coming Soon)', style: TextStyle(color: Colors.black)),
        ),
      ],
    ),
  );
}