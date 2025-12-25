import 'package:flutter/material.dart';
import 'edit_name.dart';     // ← Your new page
import 'edit_about.dart';    // ← Your new page
import 'history_page.dart';       // ← Your new page

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // These variables will change when user saves from edit pages
  String userName = 'Valentina M';
  String userAbout = 'Just..Do it';

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipPath(
                clipper: const WaveClipper(),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/profile_bg.jpg',
                      width: double.infinity,
                      height: screenHeight * 0.30,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),

              Transform.translate(
                offset: const Offset(0, -100),
                child: Center(
                  child: Stack(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/meoww.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blueAccent,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              onPressed: () {
                                print('Edit profile picture');
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 0),

              Transform.translate(
                offset: const Offset(0, -30),
                child: const Center(
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Color(0xFF6238EB),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0),

              Transform.translate(
                offset: const Offset(0, -25),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Name row — now tappable to open EditNamePage
                      InkWell(
                        onTap: () async {
                          final newName = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNamePage(currentName: userName),
                            ),
                          );
                          if (newName != null && newName is String) {
                            setState(() {
                              userName = newName;
                            });
                          }
                        },
                        child: _buildSectionRow(
                          icon: Icons.person,
                          label: 'Name',
                          value: userName,
                          valueColor: const Color(0xFF6A48E7),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // About row — now tappable to open EditAboutPage
                      InkWell(
                        onTap: () async {
                          final newAbout = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditAboutPage(currentAbout: userAbout),
                            ),
                          );
                          if (newAbout != null && newAbout is String) {
                            setState(() {
                              userAbout = newAbout;
                            });
                          }
                        },
                        child: _buildSectionRow(
                          icon: Icons.info,
                          label: 'About',
                          value: userAbout,
                          valueColor: const Color(0xFF5F41C9),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // History row — now tappable to open HistoryPage
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryPage(),
                            ),
                          );
                        },
                        child: _buildSectionRow(
                          icon: Icons.history,
                          label: 'History',
                          value: '',
                          valueColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Log Out — kept tappable with nice ripple
                      InkWell(
                        onTap: () {
                          print('Log Out tapped');
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.transparent,
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              'Log Out',
                              style: TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // This builds each row — exactly the same as before (value under label, left-aligned)
  Widget _buildSectionRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
              ),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.transparent,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ],
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  const WaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}