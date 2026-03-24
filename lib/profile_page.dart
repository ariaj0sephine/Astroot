// lib/screens/profile_page.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Cinematic ProfilePage
//  · Live cosmic background (twinkling stars + nebula drift)
//  · Avatar with personal nebula glow + orbiting planets
//  · Glass cards for Name / About / History / Log Out
//  · Staggered fade-in sections
//  · Inline edit with glow fields + star burst save
//  · Astronaut float-away log out animation
//  · NOW: name & about saved/loaded from Firestore
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/welcome_screen.dart';
import 'edit_name.dart';
import 'edit_about.dart';
import 'history_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // ── User data ──
  String userName = 'User';
  String userAbout = 'Welcome to the cosmos!';

  // ── Edit state ──
  bool _editingName = false;
  bool _editingAbout = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _aboutCtrl;
  final _nameFocus = FocusNode();
  final _aboutFocus = FocusNode();

  // ── Background ──
  late AnimationController _nebulaCtrl;
  late AnimationController _starCtrl;
  late List<_Star> _stars;

  // ── Avatar entrance ──
  late AnimationController _avatarCtrl;
  late Animation<double> _avatarScale;
  late Animation<double> _avatarFade;

  // ── Orbiting planets ──
  late AnimationController _orbitCtrl;

  // ── Camera pulse ──
  late AnimationController _cameraCtrl;
  late Animation<double> _cameraPulse;

  // ── Save star burst ──
  late AnimationController _burstCtrl;

  // ── Log out astronaut float-away ──
  late AnimationController _logoutCtrl;
  late Animation<double> _logoutFade;
  late Animation<Offset> _logoutSlide;
  bool _loggingOut = false;

  final _rng = math.Random();

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(text: userName);
    _aboutCtrl = TextEditingController(text: userAbout);

    // Load real user data from Firestore right away
    _loadUserData();

    // Background
    _nebulaCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 9))
      ..repeat(reverse: true);
    _starCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 15))
      ..repeat();
    _stars = [];

    // Avatar
    _avatarCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _avatarScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut));
    _avatarFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _avatarCtrl, curve: const Interval(0, 0.5)));
    _avatarCtrl.forward();

    // Orbits
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat();

    // Camera pulse
    _cameraCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _cameraPulse = Tween<double>(begin: 1.0, end: 1.14).animate(
        CurvedAnimation(parent: _cameraCtrl, curve: Curves.easeInOut));

    // Save burst
    _burstCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    // Logout float-away
    _logoutCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _logoutFade = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _logoutCtrl, curve: Curves.easeIn));
    _logoutSlide = Tween<Offset>(
        begin: Offset.zero, end: const Offset(0, -2.5))
        .animate(CurvedAnimation(parent: _logoutCtrl, curve: Curves.easeIn));
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          userName = doc.data()?['name'] ?? 'User';
          userAbout = doc.data()?['about'] ?? 'Welcome to the cosmos!';
          _nameCtrl.text = userName;
          _aboutCtrl.text = userAbout;
        });
      }
    } catch (e) {
      // Silent fail - keep default values if can't load
    }
  }

  void _initStars(Size size) {
    if (_stars.isNotEmpty) return;
    _stars = List.generate(60, (_) => _Star.random(_rng, size));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _aboutCtrl.dispose();
    _nameFocus.dispose();
    _aboutFocus.dispose();
    _nebulaCtrl.dispose();
    _starCtrl.dispose();
    _avatarCtrl.dispose();
    _orbitCtrl.dispose();
    _cameraCtrl.dispose();
    _burstCtrl.dispose();
    _logoutCtrl.dispose();
    super.dispose();
  }

  // ─── Save helpers ────────────────────────────────────────────────────────
  Future<void> _saveName() async {
    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() {
      userName = newName;
      _editingName = false;
    });

    _burstCtrl.forward(from: 0);

    // Save to Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'name': newName}, SetOptions(merge: true));
    }
  }

  Future<void> _saveAbout() async {
    final newAbout = _aboutCtrl.text.trim();

    setState(() {
      userAbout = newAbout;
      _editingAbout = false;
    });

    _burstCtrl.forward(from: 0);

    // Save to Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'about': newAbout}, SetOptions(merge: true));
    }
  }

  // ─── Log out ─────────────────────────────────────────────────────────────
  Future<void> _handleLogOut(BuildContext context) async {
    final bool? should = await showDialog<bool>(
      context: context,
      builder: (_) => _LogoutDialog(),
    );
    if (should != true || !mounted) return;

    setState(() => _loggingOut = true);
    await _logoutCtrl.forward();
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (route) => false,  // this removes ALL previous screens
    );  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initStars(size);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Animated nebula background ──
          AnimatedBuilder(
            animation: _nebulaCtrl,
            builder: (_, __) {
              final t = _nebulaCtrl.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(const Color(0xFF02071A), const Color(0xFF060B28), t)!,
                      Color.lerp(const Color(0xFF070B22), const Color(0xFF0C1130), t)!,
                      Color.lerp(const Color(0xFF0C1130), const Color(0xFF141848), t)!,
                      Color.lerp(const Color(0xFF131848), const Color(0xFF1A1E58), t)!,
                    ],
                    stops: const [0.0, 0.3, 0.65, 1.0],
                  ),
                ),
              );
            },
          ),

          // ── Nebula blobs ──
          AnimatedBuilder(
            animation: _nebulaCtrl,
            builder: (_, __) {
              final t = _nebulaCtrl.value;
              return Stack(children: [
                Positioned(
                    top: size.height * (0.1 + t * 0.04),
                    left: -80,
                    child: _blob(280, const Color(0xFF3B2880), 0.07 + t * 0.04)),
                Positioned(
                    top: size.height * (0.55 - t * 0.03),
                    right: -90,
                    child: _blob(240, const Color(0xFF1E3A8A), 0.06 + t * 0.03)),
              ]);
            },
          ),

          // ── Star field ──
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _StarFieldPainter(stars: _stars, progress: _starCtrl.value),
            ),
          ),

          // ── Page content (logout float-away wrapper) ──
          _loggingOut
              ? FadeTransition(
            opacity: _logoutFade,
            child: SlideTransition(
              position: _logoutSlide,
              child: _buildContent(size),
            ),
          )
              : _buildContent(size),

          // ── Save star burst overlay ──
          AnimatedBuilder(
            animation: _burstCtrl,
            builder: (_, __) {
              if (_burstCtrl.value == 0 || _burstCtrl.value >= 0.98) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SaveBurstPainter(progress: _burstCtrl.value),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Size size) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Avatar section ──
            _buildAvatarSection(size),

            const SizedBox(height: 32),

            // ── Glass cards ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildNameCard()
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart),
                  const SizedBox(height: 14),
                  _buildAboutCard()
                      .animate(delay: 420.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart),
                  const SizedBox(height: 14),
                  _buildHistoryCard()
                      .animate(delay: 540.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart),
                  const SizedBox(height: 14),
                  _buildLogOutCard()
                      .animate(delay: 660.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Avatar section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAvatarSection(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_avatarCtrl, _orbitCtrl, _cameraCtrl]),
      builder: (_, __) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Personal nebula glow
                FadeTransition(
                  opacity: _avatarFade,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7060D8).withOpacity(0.30),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                        BoxShadow(
                          color: const Color(0xFF9080E8).withOpacity(0.15),
                          blurRadius: 100,
                          spreadRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),

                // Orbiting planets
                ..._buildOrbitingPlanets(),

                // Avatar image
                FadeTransition(
                  opacity: _avatarFade,
                  child: Transform.scale(
                    scale: _avatarScale.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glass ring
                        Container(
                          width: 148,
                          height: 148,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.20),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9080FF).withOpacity(0.35),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // Profile picture
                        ClipOval(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/images/pfp.jfif'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Camera button (pulsing)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Transform.scale(
                            scale: _cameraPulse.value,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Add image picker later if you want
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF7060D8), Color(0xFF9080FF)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF9080FF).withOpacity(0.60),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Username
            FadeTransition(
              opacity: _avatarFade,
              child: Text(
                userName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FadeTransition(
              opacity: _avatarFade,
              child: Text(
                userAbout,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.50),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildOrbitingPlanets() {
    const planets = [
      _PlanetConfig(
          radius: 88, speedFactor: 1.0, size: 8, color: Color(0xFF5080FF), phaseOffset: 0),
      _PlanetConfig(
          radius: 100, speedFactor: 0.65, size: 6, color: Color(0xFFFFAA44), phaseOffset: 2.1),
      _PlanetConfig(
          radius: 75, speedFactor: 1.35, size: 5, color: Color(0xFFB090FF), phaseOffset: 4.2),
    ];

    return planets.map((p) {
      final angle = _orbitCtrl.value * 2 * math.pi * p.speedFactor + p.phaseOffset;
      final px = p.radius * math.cos(angle);
      final py = p.radius * math.sin(angle) * 0.35; // flatten to ellipse

      return Positioned(
        left: 110 + px - p.size / 2,
        top: 110 + py - p.size / 2,
        child: FadeTransition(
          opacity: _avatarFade,
          child: Container(
            width: p.size,
            height: p.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: p.color,
              boxShadow: [
                BoxShadow(
                  color: p.color.withOpacity(0.80),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Glass card helper
  // ─────────────────────────────────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.10), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D4EC8).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Name card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNameCard() {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _cardIcon(Icons.person_outline_rounded, const Color(0xFF9080FF)),
                const SizedBox(width: 12),
                const Text('NAME',
                    style: TextStyle(
                      color: Color(0xFF8890B8),
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _editingName = !_editingName;
                      if (_editingName) {
                        _nameCtrl.text = userName;
                        Future.delayed(const Duration(milliseconds: 80), () {
                          if (mounted) _nameFocus.requestFocus();
                        });
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _editingName
                          ? const Color(0xFF7060D8).withOpacity(0.25)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _editingName
                            ? const Color(0xFF9080FF).withOpacity(0.5)
                            : Colors.white.withOpacity(0.10),
                      ),
                    ),
                    child: Text(
                      _editingName ? 'Cancel' : 'Edit',
                      style: TextStyle(
                        color: _editingName
                            ? const Color(0xFF9080FF)
                            : Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState:
              _editingName ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              secondChild: Column(
                children: [
                  _glowTextField(
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    hint: 'Your cosmic name...',
                    accentColor: const Color(0xFF9080FF),
                  ),
                  const SizedBox(height: 10),
                  _saveButton(_saveName, const Color(0xFF9080FF)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  About card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAboutCard() {
    return _glassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _cardIcon(Icons.auto_awesome_outlined, const Color(0xFFFFAA44)),
                const SizedBox(width: 12),
                const Text('ABOUT',
                    style: TextStyle(
                      color: Color(0xFF8890B8),
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    )),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _editingAbout = !_editingAbout;
                      if (_editingAbout) {
                        _aboutCtrl.text = userAbout;
                        Future.delayed(const Duration(milliseconds: 80), () {
                          if (mounted) _aboutFocus.requestFocus();
                        });
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _editingAbout
                          ? const Color(0xFFFFAA44).withOpacity(0.18)
                          : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _editingAbout
                            ? const Color(0xFFFFAA44).withOpacity(0.4)
                            : Colors.white.withOpacity(0.10),
                      ),
                    ),
                    child: Text(
                      _editingAbout ? 'Cancel' : 'Edit',
                      style: TextStyle(
                        color: _editingAbout
                            ? const Color(0xFFFFAA44)
                            : Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState:
              _editingAbout ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: Text(
                userAbout,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _glowTextField(
                    controller: _aboutCtrl,
                    focusNode: _aboutFocus,
                    hint: 'Tell the universe about yourself...',
                    accentColor: const Color(0xFFFFAA44),
                    maxLines: 3,
                    showCounter: true,
                  ),
                  const SizedBox(height: 10),
                  _saveButton(_saveAbout, const Color(0xFFFFAA44)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  History card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHistoryCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const HistoryPage())),
      child: _glassCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Row(
            children: [
              _cardIcon(Icons.history_rounded, const Color(0xFF60C8FF)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('HISTORY',
                    style: TextStyle(
                      color: Color(0xFF8890B8),
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    )),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.35), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Log Out card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLogOutCard() {
    return GestureDetector(
      onTap: () => _handleLogOut(context),
      child: _glassCard(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Row(
            children: [
              _cardIcon(Icons.rocket_launch_outlined, const Color(0xFFFF6B6B)),
              const SizedBox(width: 12),
              const Text('LOG OUT',
                  style: TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  )),
              const Spacer(),
              Text('Float away →',
                  style: TextStyle(
                    color: const Color(0xFFFF6B6B).withOpacity(0.55),
                    fontSize: 12,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Shared UI helpers
  // ─────────────────────────────────────────────────────────────────────────
  Widget _cardIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _glowTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required Color accentColor,
    int maxLines = 1,
    bool showCounter = false,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: maxLines,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              cursorColor: accentColor,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                TextStyle(color: Colors.white.withOpacity(0.30), fontSize: 14),
                filled: true,
                fillColor: Colors.black.withOpacity(0.25),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: accentColor, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.10), width: 1),
                ),
              ),
            ),
            if (showCounter) ...[
              const SizedBox(height: 4),
              Text('${value.text.length}/120',
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
            ],
          ],
        );
      },
    );
  }

  Widget _saveButton(VoidCallback onSave, Color accentColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: onSave,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [accentColor.withOpacity(0.7), accentColor],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.40),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text('Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              )),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(opacity),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Planet config
// ─────────────────────────────────────────────────────────────────────────────
class _PlanetConfig {
  final double radius;
  final double speedFactor;
  final double size;
  final Color color;
  final double phaseOffset;

  const _PlanetConfig({
    required this.radius,
    required this.speedFactor,
    required this.size,
    required this.color,
    required this.phaseOffset,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Log Out dialog
// ─────────────────────────────────────────────────────────────────────────────
class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0xFF0C1030),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6050D8).withOpacity(0.20),
              blurRadius: 40,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🚀', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            const Text('Float Away?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )),
            const SizedBox(height: 10),
            Text(
              'This will sign you out. The stars will be waiting when you return!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.60),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withOpacity(0.07),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: const Center(
                        child: Text('Stay',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE05050), Color(0xFFFF7070)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF5050).withOpacity(0.35),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('Log Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Painters
// ─────────────────────────────────────────────────────────────────────────────

class _Star {
  final double x, y, size, speed, opacity;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
  factory _Star.random(math.Random rng, Size _) => _Star(
    x: rng.nextDouble(),
    y: rng.nextDouble(),
    size: rng.nextDouble() * 1.5 + 0.4,
    speed: rng.nextDouble() * 0.022 + 0.004,
    opacity: rng.nextDouble() * 0.55 + 0.20,
  );
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;
  const _StarFieldPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final dy = (s.y - s.speed * progress + 1.0) % 1.0;
      canvas.drawCircle(
        Offset(s.x * size.width, dy * size.height),
        s.size,
        Paint()
          ..color = Colors.white.withOpacity(s.opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.progress != progress;
}

// Save burst — radial star particles from center
class _SaveBurstPainter extends CustomPainter {
  final double progress;
  const _SaveBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.72; // near save button area
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final rng = math.Random(77);
    for (int i = 0; i < 18; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final r = progress * size.width * 0.28 * (rng.nextDouble() * 0.5 + 0.5);
      final px = cx + r * math.cos(angle);
      final py = cy + r * math.sin(angle);
      final colors = [
        const Color(0xFFFFFFFF),
        const Color(0xFFD0C8FF),
        const Color(0xFFFFE080),
        const Color(0xFF9080FF),
      ];
      canvas.drawCircle(
        Offset(px, py),
        (rng.nextDouble() * 2.5 + 0.8) * (1 - progress * 0.4),
        Paint()
          ..color = colors[i % 4].withOpacity(alpha * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
    // Center flash
    canvas.drawCircle(
      Offset(cx, cy),
      30 * progress,
      Paint()
        ..color = const Color(0xFFE0D8FF).withOpacity(alpha * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  @override
  bool shouldRepaint(_SaveBurstPainter old) => old.progress != progress;
}