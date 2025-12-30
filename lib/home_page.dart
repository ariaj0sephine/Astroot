import 'package:flutter/material.dart';
import 'camera_tab.dart';  // Your REAL camera (preview + snap)—not placeholder!
import 'virtual_planatorium.dart';  // Your AR tab (from Phase 3)
import 'event_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;  // 4 tabs: 0=RealHomeTab, 1=Calendar, 2=Profile (camera pushed—no tab), 3=ar cam

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
      const VirtualPlanetariumScreen(),
      const EventWidget(),
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
            NavigationDestination(icon: Icon(Icons.star_outlined, size: 30), selectedIcon: Icon(Icons.star, size: 30), label: '',),
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
                _buildNavCard('AR CAM', Icons.camera_alt, null, context), // Push camera
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
class _EventWidgetState extends State<EventWidget> {
  // Individual toggle states for each card (start as OFF)
  bool _quadrantidsToggle = false;
  bool _eclipseToggle = false;
  bool _lyridsToggle = false;
  bool _etaToggle = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 393,
      height: 852,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(0, 26, 114, 1),
      ),
      child: Stack(
        children: <Widget>[
          // Header bar
          Positioned(
            top: 39,
            left: 19,
            child: Container(
              width: 346,
              height: 48,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 13,
                    left: 138,
                    child: const Text(
                      'EVENTS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontFamily: 'Inter',
                        fontSize: 20,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        height: 1,
                      ),
                    ),
                  ),
                  // Notification bell icon button
                  Positioned(
                    top: 0,
                    left: 299,
                    child: Container(
                      width: 47,
                      height: 47,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(51, 57, 118, 1),
                        borderRadius: BorderRadius.all(Radius.elliptical(47, 47)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Main content with tabs and cards
          Positioned(
            top: 124,
            left: 26,
            child: Container(
              width: 340,
              height: 620,
              child: Stack(
                children: <Widget>[
                  // Tabs row (unchanged)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 339,
                      height: 40,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 148,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 205,
                            child: Container(
                              width: 134,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 11,
                            left: 16,
                            child: const Text(
                              'Meteor showers',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 11,
                            left: 242,
                            child: const Text(
                              'Eclipses',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 1: Quadrantids
                  Positioned(
                    top: 88,
                    left: 1,
                    child: Container(
                      width: 339,
                      height: 97,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 339,
                              height: 97,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          // Working toggle switch
                          Positioned(
                            top: 38,
                            left: 273,
                            child: SizedBox(
                              width: 42,
                              height: 22,
                              child: Switch(
                                value: _quadrantidsToggle,
                                onChanged: (value) {
                                  setState(() {
                                    _quadrantidsToggle = value;
                                  });
                                },
                                activeColor: const Color.fromRGBO(84, 108, 190, 1),
                                activeTrackColor: const Color.fromRGBO(84, 108, 190, 1),
                                inactiveThumbColor: const Color.fromRGBO(217, 217, 217, 1),
                                inactiveTrackColor: const Color.fromRGBO(217, 217, 217, 0.5),
                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                                thumbColor: MaterialStateProperty.all(Colors.white),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 21,
                            child: Container(
                              width: 72,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/quad.jpg'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 17,
                            left: 115,
                            child: const Text(
                              'Quadrantids\nMeteor Shower',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 63,
                            left: 111,
                            child: const Text(
                              'January 3–4, 2026',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 2: Total Lunar Eclipse
                  Positioned(
                    top: 233,
                    left: 1,
                    child: Container(
                      width: 339,
                      height: 97,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 339,
                              height: 97,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 38,
                            left: 271,
                            child: SizedBox(
                              width: 42,
                              height: 22,
                              child: Switch(
                                value: _eclipseToggle,
                                onChanged: (value) {
                                  setState(() {
                                    _eclipseToggle = value;
                                  });
                                },
                                activeColor: const Color.fromRGBO(84, 108, 190, 1),
                                activeTrackColor: const Color.fromRGBO(84, 108, 190, 1),
                                inactiveThumbColor: const Color.fromRGBO(217, 217, 217, 1),
                                inactiveTrackColor: const Color.fromRGBO(217, 217, 217, 0.5),
                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                                thumbColor: MaterialStateProperty.all(Colors.white),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 21,
                            child: Container(
                              width: 72,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/total_lunar.jpg'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 26,
                            left: 111,
                            child: const Text(
                              'Total Lunar Eclipse',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 54,
                            left: 115,
                            child: const Text(
                              'March 3, 2026',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 3: Lyrids
                  Positioned(
                    top: 378,
                    left: 1,
                    child: Container(
                      width: 339,
                      height: 97,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 339,
                              height: 97,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 38,
                            left: 272,
                            child: SizedBox(
                              width: 42,
                              height: 22,
                              child: Switch(
                                value: _lyridsToggle,
                                onChanged: (value) {
                                  setState(() {
                                    _lyridsToggle = value;
                                  });
                                },
                                activeColor: const Color.fromRGBO(84, 108, 190, 1),
                                activeTrackColor: const Color.fromRGBO(84, 108, 190, 1),
                                inactiveThumbColor: const Color.fromRGBO(217, 217, 217, 1),
                                inactiveTrackColor: const Color.fromRGBO(217, 217, 217, 0.5),
                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                                thumbColor: MaterialStateProperty.all(Colors.white),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 21,
                            child: Container(
                              width: 72,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/lyrids.jpg'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 118,
                            child: const Text(
                              'Lyrids Meteor\nShower',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 62,
                            left: 118,
                            child: const Text(
                              'April 22–23, 2026.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Card 4: Eta Aquariids
                  Positioned(
                    top: 523,
                    left: 1,
                    child: Container(
                      width: 339,
                      height: 97,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 339,
                              height: 97,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color.fromRGBO(51, 57, 118, 1),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 38,
                            left: 273,
                            child: SizedBox(
                              width: 42,
                              height: 22,
                              child: Switch(
                                value: _etaToggle,
                                onChanged: (value) {
                                  setState(() {
                                    _etaToggle = value;
                                  });
                                },
                                activeColor: const Color.fromRGBO(84, 108, 190, 1),
                                activeTrackColor: const Color.fromRGBO(84, 108, 190, 1),
                                inactiveThumbColor: const Color.fromRGBO(217, 217, 217, 1),
                                inactiveTrackColor: const Color.fromRGBO(217, 217, 217, 0.5),
                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                                thumbColor: MaterialStateProperty.all(Colors.white),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 18,
                            left: 21,
                            child: Container(
                              width: 72,
                              height: 62,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: const DecorationImage(
                                  image: AssetImage('assets/images/eta.jpg'),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 13,
                            left: 118,
                            child: const Text(
                              'Eta Aquariids\nMeteor Shower',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 16,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 60,
                            left: 119,
                            child: const Text(
                              'May 5–6, 2026.',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 15,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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