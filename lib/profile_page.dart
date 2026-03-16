import 'package:flutter/material.dart';
import 'edit_name.dart';     // ← Your edit name page (must exist)
import 'edit_about.dart';    // ← Your edit about page (must exist)
import 'history_page.dart';  // ← Your history page (must exist)
import 'package:firebase_auth/firebase_auth.dart';  // For real logout
import 'package:flutter_animate/flutter_animate.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // These two lines hold the name and about text
  // They update automatically when you come back from edit pages
  String userName = 'Valentina M';
  String userAbout = 'Just..Do it';

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070B19), Color(0xFF0F172A), Color(0xFF1E1B4B)], // Cosmic background
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ====================== WAVE BACKGROUND ======================
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

                // ====================== PROFILE PICTURE ======================
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
                                image: AssetImage('assets/images/pfp.jfif'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Small camera button on picture
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
                                  // TODO: Add real photo picker later (Phase 5)
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

                // ====================== "EDIT" LABEL ======================
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

                // ====================== ALL SECTIONS ======================
                Transform.translate(
                  offset: const Offset(0, -25),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        // Name row (tap to edit)
                        InkWell(
                          onTap: () async {
                            final newName = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditNamePage(currentName: userName),
                              ),
                            );
                            if (newName != null && newName is String) {
                              setState(() => userName = newName);
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

                        // About row (tap to edit)
                        InkWell(
                          onTap: () async {
                            final newAbout = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAboutPage(currentAbout: userAbout),
                              ),
                            );
                            if (newAbout != null && newAbout is String) {
                              setState(() => userAbout = newAbout);
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

                        // History row
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HistoryPage()),
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

                        // ====================== LOG OUT ======================
                        InkWell(
                          onTap: () => _handleLogOut(context),
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
                      ].animate(interval: 100.ms).fade(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================== HELPER WIDGET (makes clean rows) ======================
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
                border: Border.all(color: const Color(0xFF5F6ADC).withOpacity(0.5), width: 1),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF5F6ADC).withOpacity(0.2), blurRadius: 8, spreadRadius: 1)
                ],
              ),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFF1E244B),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 20),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 24)),
          ],
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 50),
            child: Text(
              value,
              style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ],
    );
  }

  // ====================== LOG OUT (safest version) ======================
  void _handleLogOut(BuildContext context) async {
    final bool? shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF001A72),
          title: const Text('Log Out?', style: TextStyle(color: Colors.white)),
          content: const Text('This will sign you out. You can sign back in anytime!', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel', style: TextStyle(color: Colors.purple))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log Out', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );

    if (shouldLogOut == true) {
      await FirebaseAuth.instance.signOut();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out! 🌟 Ready for more stars?'), backgroundColor: Color(0xFF001A72)),
        );
      }

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}

// ====================== WAVE CLIPPER (makes the curved background) ======================
class WaveClipper extends CustomClipper<Path> {
  const WaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height + 30, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}