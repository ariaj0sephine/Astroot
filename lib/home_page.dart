import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(0, 26, 114, 1),
        body: const HomePage(),
        // Replace the following with your existing navbar widget or BottomNavigationBar
        bottomNavigationBar: YourNavbarWidget(), // Replace with your navbar widget
      ),
    );
  }
}

// HomePage Widget (Main Content)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Header with Logo and Profile Icon
          Positioned(
            top: 21,
            left: 15,
            right: 15,
            child: Container(
              height: 69,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(51, 57, 118, 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 21.5,
                    backgroundImage: AssetImage('assets/images/Ellipse1.png'),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ASTROOT',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),

          // Main Banner
          Positioned(
            top: 134,
            left: 13,
            child: Container(
              width: 367,
              height: 246,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(
                  image: AssetImage('assets/images/Rectangle7.png'),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Inter',
                        fontSize: 20,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Text(
                    'START STARGAZING NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      width: 165,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(51, 57, 119, 1),
                            Color.fromRGBO(96, 106, 221, 1),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Cards (AR CAM, CALENDAR, PROFILE)
          Positioned(
            top: 424,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavCard('AR CAM', Icons.camera_alt),
                _buildNavCard('CALENDAR', Icons.calendar_today),
                _buildNavCard('PROFILE', Icons.person),
              ],
            ),
          ),

          // Tonight’s Sky Events
          Positioned(
            top: 622,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tonight’s Sky Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/Rectangle5.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 133),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'AR Camera',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Inter',
                          ),
                        ),
                        Text(
                          'blah blah blah',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Rectangle6.png at the Bottom
          Positioned(
            bottom: 20, // Adjust this value based on your navbar height
            left: 30,
            child: Container(
              width: 97,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage('assets/images/Rectangle6.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildNavCard(String title, IconData icon) {
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for Your Navbar (Replace with Your Actual Navbar)
class YourNavbarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromRGBO(51, 57, 118, 1),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    );
  }
}