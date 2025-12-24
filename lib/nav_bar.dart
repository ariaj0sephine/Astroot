import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'profile_page.dart';  // ← Add this line only (tells Flutter where to find it)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // starts on Home tab (as you wanted)

  static final List<Widget> _screens = [
    const RealHomeTab(),   // ← Our beautiful Figma homepage
    const CameraTab(),
    const CalendarTab(),
    const ProfilePage(),
  ];

  // Your cosmic gradient (kept exactly the same)
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
      extendBody: true,  // Lets body flow behind navbar – fixes stacking!
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: _cosmicGradient)),
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 84,
        child: NavigationBar(
          backgroundColor: Colors.black54,
          indicatorColor: const Color(0xFF725ABA),
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
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

// ─────────────────────── REAL HOME TAB (Your Figma Design – Perfected) ───────────────────────
class RealHomeTab extends StatelessWidget {
  const RealHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Header Logo + Profile Icon
          Positioned(
            top: 0,
            left: 15,
            right: 15,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(51, 57, 118, 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 21.5,
                    backgroundImage: const AssetImage('assets/images/icon.png'),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ASTROOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.person_outline, color: Colors.white, size: 40),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),

          // Main Banner
          Positioned(
            top: 80,
            left: 13,
            child: Container(
              width: 367,
              height: 246,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 44, left: 16, right: 16),
                    child: Text(
                      '“POINT YOUR PHONE AT THE SKY \n& UNLOCK THE UNIVERSE.”',
                      style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Text(
                    'START STARGAZING NOW',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: 165,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color.fromRGBO(51, 57, 119, 1), Color.fromRGBO(96, 106, 221, 1)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: const Center(
                        child: Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Three Navigation Cards
          Positioned(
            top: 350,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCard('AR CAM', Icons.camera_alt),
                _buildCard('CALENDAR', Icons.calendar_today),
                _buildCard('PROFILE', Icons.person),
              ],
            ),
          ),

          // Tonight’s Sky Events – Fixed overlap!
          Positioned(
            top: 525,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tonight’s Sky Events', style: TextStyle(color: Colors.white, fontSize: 24)),
                const SizedBox(height: 35),  // ← Fixed: Increased from 20 to 40 – no more overlap!
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/background.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 133),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AR Camera', style: TextStyle(color: Colors.white, fontSize: 20)),
                        Text('blah blah blah', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Small Rectangle6.png
          Positioned(
            bottom: 40,
            left: 30,
            child: Container(
              width: 97,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/event_home.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCard(String title, IconData icon) {
    return Container(
      width: 106,
      height: 154,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(51, 57, 118, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 50),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}

// Other tabs unchanged...
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