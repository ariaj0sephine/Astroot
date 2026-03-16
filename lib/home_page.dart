import 'package:flutter/material.dart';
import 'camera_tab.dart';
import 'visisble_tonight.dart';
import 'event_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
    final List<Widget> screens = [
      const RealHomeTab(),
      const VisibleTonightScreen(),
      const EventWidget(),
      ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: _cosmicGradient)),
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 84,
        child: NavigationBar(
          backgroundColor: Colors.black.withOpacity(0.4),
          indicatorColor: const Color(0xFF725ABA),
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined, size: 30), selectedIcon: Icon(Icons.home, size: 30), label: ''),
            NavigationDestination(icon: Icon(Icons.star_outlined, size: 30), selectedIcon: Icon(Icons.star, size: 30), label: ''),
            NavigationDestination(icon: Icon(Icons.calendar_today_outlined, size: 30), selectedIcon: Icon(Icons.calendar_today, size: 30), label: ''),
            NavigationDestination(icon: Icon(Icons.account_circle_outlined, size: 30), selectedIcon: Icon(Icons.account_circle, size: 30), label: ''),
          ],
        ),
      ),
    );
  }
}

class RealHomeTab extends StatelessWidget {
  const RealHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Header
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
                  const CircleAvatar(
                    radius: 21.5,
                    backgroundImage: AssetImage('assets/images/icon.png'),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ASTROOT',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                      homeState?.setState(() => homeState._currentIndex = 3);
                    },
                    child: const Icon(Icons.person_outline, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),

          // Banner
          Positioned(
            top: 80,
            left: 15,
            right: 15,
            child: Container(
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
                  const Padding(
                    padding: EdgeInsets.only(top: 44, left: 16, right: 16),
                    child: Text(
                      '"POINT YOUR PHONE AT THE SKY \n& UNLOCK THE UNIVERSE."',
                      style: TextStyle(color: Colors.white, fontSize: 20, height: 1.4),
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraTab(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
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
                  ),
                ],
              ),
            ),
          ),

          // Nav Cards
          Positioned(
            top: 350,
            left: 15,
            right: 15,
            child: Row(
              children: [
                Expanded(child: _buildNavCard('VISIBLE TONIGHT', Icons.star, 1, context)),
                const SizedBox(width: 12),
                Expanded(child: _buildNavCard('EVENT PREDICTIONS', Icons.calendar_today, 2, context)),
                const SizedBox(width: 12),
                Expanded(child: _buildNavCard('PROFILE', Icons.person, 3, context)),
              ],
            ),
          ),

          // Major Upcoming Event
          Positioned(
            top: 550,
            left: 15,
            right: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Major Upcoming Event', style: TextStyle(color: Colors.white, fontSize: 24)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                    homeState?.setState(() => homeState._currentIndex = 2);
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(51, 57, 118, 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/lyrids.jpg',
                            width: 80,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Lyrids Meteor Shower', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('April 22–23, 2026', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white54, size: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNavCard(String title, IconData icon, int? tabIndex, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tabIndex != null) {
          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
          homeState?.setState(() => homeState._currentIndex = tabIndex);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraTab(),
              fullscreenDialog: true,
            ),
          );
        }
      },
      child: Container(
        height: 154,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(51, 57, 118, 1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}