import 'package:flutter/material.dart';
import 'camera_tab.dart';  // Your REAL camera (preview + snap)—not placeholder!

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;  // 3 tabs: 0=RealHomeTab, 1=Calendar, 2=Profile (camera pushed—no tab)

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
    final List<Widget> screens = [  // 3 only—no camera tab (push instead for immersion)
      const RealHomeTab(),
      const CalendarTab(),
      const ProfileTab(),
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
          IndexedStack(  // Fast switch, keeps state
            index: _currentIndex,
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(  // 3 icons—clean, no camera clutter
        height: 84,
        child: NavigationBar(
          backgroundColor: Colors.black.withOpacity(0.4),  // Your screenshot bg
          indicatorColor: const Color(0xFF725ABA),  // Purple glow
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined, size: 30), selectedIcon: Icon(Icons.home, size: 30), label: ''),
            NavigationDestination(icon: Icon(Icons.calendar_today_outlined, size: 30), selectedIcon: Icon(Icons.calendar_today, size: 30), label: ''),
            NavigationDestination(icon: Icon(Icons.account_circle_outlined, size: 30), selectedIcon: Icon(Icons.account_circle, size: 30), label: ''),
          ],
        ),
      ),
    );
  }
}

// Your Screenshot-Perfect Home Tab (header, banner, cards, events—exact positions)
class RealHomeTab extends StatelessWidget {
  const RealHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Header (top:0, height:60—your screenshot match)
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
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(  // Tap to Profile tab (index 2)
                    onTap: () {
                      final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                      homeState?._currentIndex = 2;
                      homeState?.setState(() {});
                    },
                    child: const Icon(Icons.person_outline, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),

          // Banner (top:80, height:246—quote + "Get Started" push to camera)
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
                    child: const Text(
                      '“POINT YOUR PHONE AT THE SKY \n& UNLOCK THE UNIVERSE.”',
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
                    child: GestureDetector(  // RESTORED: Push real camera (slide-in, snap works)
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CameraTab(),  // Your full camera_tab.dart
                            fullscreenDialog: true,  // Immersive—no nav bar
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

          // Nav Cards (top:350—AR CAM push, others switch tabs)
          Positioned(
            top: 350,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavCard('AR CAM', Icons.camera_alt, null, context),  // Push camera
                _buildNavCard('CALENDAR', Icons.calendar_today, 1, context),  // Tab 1
                _buildNavCard('PROFILE', Icons.person, 2, context),  // Tab 2
              ],
            ),
          ),

          // Events (top:525, 35px space—no overlap)
          Positioned(
            top: 525,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tonight’s Sky Events', style: TextStyle(color: Colors.white, fontSize: 24)),
                const SizedBox(height: 35),
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

          // Bottom Image (bottom:40—your screenshot exact)
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

  // Nav Card Builder (push for AR CAM, switch for others—direct index, no -1)
  static Widget _buildNavCard(String title, IconData icon, int? tabIndex, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tabIndex != null) {  // CAL/PROFILE: Switch tabs
          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
          homeState?._currentIndex = tabIndex;
          homeState?.setState(() {});
        } else {  // AR CAM: Push real camera
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
      ),
    );
  }
}

// Calendar & Profile Placeholders (unchanged—Phase 4 expand)
class CalendarTab extends StatelessWidget {
  const CalendarTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Calendar Tab: Facts & Read Aloud\n(Dive into astronomy!)', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
  );
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Profile Tab\nManage Account & Saved Stars', style: TextStyle(fontSize: 20, color: Colors.white), textAlign: TextAlign.center),
        SizedBox(height: 30),
        ElevatedButton(onPressed: null, child: Text('Sign In (Coming Soon)', style: TextStyle(color: Colors.black))),
      ],
    ),
  );
}