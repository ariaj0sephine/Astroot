// lib/screens/home_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'camera_tab.dart';
import 'visible_tonight.dart';
import 'event_page.dart';
import 'profile_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  HomeScreen shell
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _lastTappedTab = -1;

  // Declared as nullable — assigned in initState, never accessed before then
  AnimationController? _nebulaCtrl;
  Animation<double>? _nebulaAnim;
  AnimationController? _tabBounceCtrl;

  @override
  void initState() {
    super.initState();

    _nebulaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _nebulaAnim = CurvedAnimation(
      parent: _nebulaCtrl!,
      curve: Curves.easeInOut,
    );

    _tabBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _nebulaCtrl?.dispose();
    _tabBounceCtrl?.dispose();
    super.dispose();
  }

  Future<void> _onTabTapped(int i) async {
    setState(() {
      _currentIndex = i;
      _lastTappedTab = i;
    });
    _tabBounceCtrl?.forward(from: 0);
  }

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
          // ── Animated nebula background ──
          AnimatedBuilder(
            animation: _nebulaAnim ?? const AlwaysStoppedAnimation(0),
            builder: (_, __) {
              final t = _nebulaAnim?.value ?? 0.0;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(const Color(0xFF00071A), const Color(0xFF050B2A), t)!,
                      Color.lerp(const Color(0xFF00132D), const Color(0xFF07103A), t)!,
                      Color.lerp(const Color(0xFF001E45), const Color(0xFF0A1855), t)!,
                      Color.lerp(const Color(0xFF002657), const Color(0xFF0D1F5C), t)!,
                    ],
                    stops: const [0.0, 0.15, 0.54, 1.0],
                  ),
                ),
              );
            },
          ),

          // Soft nebula blobs (very low opacity)
          AnimatedBuilder(
            animation: _nebulaAnim ?? const AlwaysStoppedAnimation(0),
            builder: (_, __) {
              final t = _nebulaAnim?.value ?? 0.0;
              return Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * (0.05 + t * 0.04),
                    left: -60,
                    child: _nebulaBlob(280, const Color(0xFF3B2880), 0.08 + t * 0.04),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * (0.35 - t * 0.03),
                    right: -80,
                    child: _nebulaBlob(260, const Color(0xFF1E3A8A), 0.07 + t * 0.03),
                  ),
                ],
              );
            },
          ),

          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
        ],
      ),
      bottomNavigationBar: _AnimatedBottomNav(
        currentIndex: _currentIndex,
        lastTappedTab: _lastTappedTab,
        bounceCtrl: _tabBounceCtrl,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _nebulaBlob(double size, Color color, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Animated Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final int lastTappedTab;
  final AnimationController? bounceCtrl;
  final ValueChanged<int> onTap;

  const _AnimatedBottomNav({
    required this.currentIndex,
    required this.lastTappedTab,
    required this.bounceCtrl,
    required this.onTap,
  });

  @override
  State<_AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class _AnimatedBottomNavState extends State<_AnimatedBottomNav>
    with TickerProviderStateMixin {
  // Stagger entrance
  late List<AnimationController> _entranceCtrl;
  late List<Animation<double>> _entranceFade;
  late List<Animation<double>> _entranceScale;

  // Shooting star on active icon
  late AnimationController _shootCtrl;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = List.generate(
      4,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _entranceFade = _entranceCtrl
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: c, curve: Curves.easeOut),
    ))
        .toList();
    _entranceScale = _entranceCtrl
        .map((c) => Tween<double>(begin: 0.4, end: 1).animate(
      CurvedAnimation(parent: c, curve: Curves.elasticOut),
    ))
        .toList();

    // Stagger launch
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: 120 + i * 100), () {
        if (mounted) _entranceCtrl[i].forward();
      });
    }

    _shootCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    for (final c in _entranceCtrl) c.dispose();
    _shootCtrl.dispose();
    super.dispose();
  }

  // Bounce scale for tapped tab
  double _bounceScale(int tabIndex) {
    if (tabIndex != widget.lastTappedTab) return 1.0;
    if (widget.bounceCtrl == null) return 1.0;
    final t = widget.bounceCtrl!.value;
    return 1.0 + math.sin(t * math.pi) * 0.25;
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home_outlined,
      Icons.star_outlined,
      Icons.calendar_today_outlined,
      Icons.account_circle_outlined,
    ];
    final activeIcons = [
      Icons.home,
      Icons.star,
      Icons.calendar_today,
      Icons.account_circle,
    ];

    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (i) {
          final isActive = i == widget.currentIndex;
          return AnimatedBuilder(
            animation: Listenable.merge([
              _entranceCtrl[i],
              if (widget.bounceCtrl != null) widget.bounceCtrl!,
              _shootCtrl,
            ]),
            builder: (_, __) {
              return FadeTransition(
                opacity: _entranceFade[i],
                child: Transform.scale(
                  scale: _entranceScale[i].value * _bounceScale(i),
                  child: GestureDetector(
                    onTap: () => widget.onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Active glow ring
                          if (isActive)
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF725ABA)
                                        .withValues(alpha: 0.55),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),

                          // Shooting star sweep on active tab
                          if (isActive)
                            CustomPaint(
                              size: const Size(60, 60),
                              painter: _ShootingStarNavPainter(
                                progress: _shootCtrl.value,
                              ),
                            ),

                          // Active indicator pill
                          if (isActive)
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF725ABA)
                                    .withValues(alpha: 0.85),
                              ),
                            ),

                          Icon(
                            isActive ? activeIcons[i] : icons[i],
                            color: isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.55),
                            size: 26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RealHomeTab
// ─────────────────────────────────────────────────────────────────────────────
class RealHomeTab extends StatefulWidget {
  const RealHomeTab({super.key});

  @override
  State<RealHomeTab> createState() => _RealHomeTabState();
}

class _RealHomeTabState extends State<RealHomeTab>
    with TickerProviderStateMixin {
  // Scroll for parallax
  final _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  // Header card fade-in
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  // Banner card fade + parallax
  late AnimationController _bannerCtrl;
  late Animation<double> _bannerFade;

  // Twinkling stars
  late AnimationController _twinkleCtrl;
  late List<_TwinkleStar> _twinkleStars;

  // CTA button pulse
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Nav cards stagger
  late List<AnimationController> _cardCtrl;
  late List<Animation<double>> _cardFade;
  late List<Animation<double>> _cardScale;

  // Nav card tap bounce
  late List<AnimationController> _cardBounce;

  // Meteor streak
  late AnimationController _meteorCtrl;

  // Event date glow pulse
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  final _rng = math.Random();

  @override
  void initState() {
    super.initState();

    _scrollCtrl.addListener(() {
      setState(() => _scrollOffset = _scrollCtrl.offset);
    });

    // Header
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    // Banner
    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bannerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOut),
    );

    // Twinkle
    _twinkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _twinkleStars = List.generate(22, (_) => _TwinkleStar.random(_rng));

    // CTA pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Nav cards stagger
    _cardCtrl = List.generate(
      3,
          (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 550)),
    );
    _cardFade = _cardCtrl
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: c, curve: Curves.easeOut),
    ))
        .toList();
    _cardScale = _cardCtrl
        .map((c) => Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: c, curve: Curves.elasticOut),
    ))
        .toList();

    _cardBounce = List.generate(
      3,
          (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 380)),
    );

    // Meteor streak
    _meteorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Event date glow
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // Staggered launch
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _headerCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _bannerCtrl.forward();
    });
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: 600 + i * 130), () {
        if (mounted) _cardCtrl[i].forward();
      });
    }
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _meteorCtrl.forward();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _headerCtrl.dispose();
    _bannerCtrl.dispose();
    _twinkleCtrl.dispose();
    _pulseCtrl.dispose();
    for (final c in _cardCtrl) c.dispose();
    for (final c in _cardBounce) c.dispose();
    _meteorCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Header ──
              FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: _buildHeader(context),
                ),
              ),

              const SizedBox(height: 16),

              // ── Banner with parallax + twinkling stars ──
              FadeTransition(
                opacity: _bannerFade,
                child: Transform.translate(
                  // parallax: banner moves slightly slower than scroll
                  offset: Offset(0, _scrollOffset * 0.25),
                  child: _buildBanner(size),
                ),
              ),

              const SizedBox(height: 22),

              // ── Nav cards (staggered) ──
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 12 : 0),
                      child: AnimatedBuilder(
                        animation:
                        Listenable.merge([_cardCtrl[i], _cardBounce[i]]),
                        builder: (_, child) {
                          final bounce = 1.0 +
                              math.sin(_cardBounce[i].value * math.pi) * 0.14;
                          return FadeTransition(
                            opacity: _cardFade[i],
                            child: Transform.scale(
                              scale: _cardScale[i].value * bounce,
                              child: child,
                            ),
                          );
                        },
                        child: _buildNavCard(
                          ['VISIBLE TONIGHT', 'EVENT PREDICTIONS', 'PROFILE'][i],
                          [Icons.star, Icons.calendar_today, Icons.person][i],
                          [1, 2, 3][i],
                          context,
                          _cardBounce[i],
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 26),

              // ── Major Upcoming Event ──
              const Text(
                'Major Upcoming Event',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 12),

              _buildEventCard(size),

              const SizedBox(height: 100), // bottom nav clearance
            ],
          ),
        ),
      ),
    );
  }

  // ── Header card ──
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF333976).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3D4EC8).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              final homeState =
              context.findAncestorStateOfType<_HomeScreenState>();
              homeState?.setState(() => homeState._currentIndex = 3);
            },
            child: const Icon(Icons.person_outline, color: Colors.white, size: 38),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  // ── Banner card with twinkling star overlay + parallax ──
  Widget _buildBanner(Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        height: 246,
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Dark overlay to make text readable
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),

            // Twinkling stars overlay
            AnimatedBuilder(
              animation: _twinkleCtrl,
              builder: (_, __) => CustomPaint(
                size: Size(size.width - 30, 246),
                painter: _TwinkleStarPainter(
                  stars: _twinkleStars,
                  progress: _twinkleCtrl.value,
                ),
              ),
            ),

            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 44, left: 16, right: 16),
                  child: Text(
                    '"POINT YOUR PHONE AT THE SKY\n& UNLOCK THE UNIVERSE."',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Text(
                  'START STARGAZING NOW',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, child) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: child,
                    ),
                    child: _TapFade(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CameraTab(),
                            fullscreenDialog: true,
                          ),
                        );
                      },
                      child: Container(
                        width: 165,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF333977),
                              Color(0xFF606ADD),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                              const Color(0xFF606ADD).withValues(alpha: 0.55),
                              blurRadius: 22,
                              spreadRadius: 1,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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

  // ── Nav card (with tap bounce) ──
  Widget _buildNavCard(
      String title,
      IconData icon,
      int? tabIndex,
      BuildContext context,
      AnimationController bounceCtrl,
      ) {
    return _TapFade(
      onTap: () {
        bounceCtrl.forward(from: 0);
        if (tabIndex != null) {
          final homeState =
          context.findAncestorStateOfType<_HomeScreenState>();
          homeState?.setState(() => homeState._currentIndex = tabIndex);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CameraTab(),
              fullscreenDialog: true,
            ),
          );
        }
      },
      child: Container(
        height: 154,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF333976).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D4EC8).withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 38),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Event card with meteor streak + date glow ──
  Widget _buildEventCard(Size size) {
    return _TapFade(
      onTap: () {
        final homeState =
        context.findAncestorStateOfType<_HomeScreenState>();
        homeState?.setState(() => homeState._currentIndex = 2);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF333976).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border:
          Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3D4EC8).withValues(alpha: 0.20),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Meteor streak (fires once on load)
              AnimatedBuilder(
                animation: _meteorCtrl,
                builder: (_, __) => CustomPaint(
                  size: Size(size.width - 30, 90),
                  painter: _MeteorPainter(progress: _meteorCtrl.value),
                ),
              ),

              // Card content
              Padding(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Lyrids Meteor Shower',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Date with glow pulse
                          AnimatedBuilder(
                            animation: _glowAnim,
                            builder: (_, __) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color(0xFF725ABA)
                                    .withValues(alpha: 0.22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF9D8CFF).withValues(
                                        alpha: _glowAnim.value * 0.45),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFF9D8CFF).withValues(
                                      alpha: _glowAnim.value * 0.55),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'April 22–23, 2026',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.75 + _glowAnim.value * 0.25),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.white38, size: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Tap-fade wrapper — fades + scales down on press, back up on release
// ─────────────────────────────────────────────────────────────────────────────
class _TapFade extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _TapFade({required this.child, required this.onTap});

  @override
  State<_TapFade> createState() => _TapFadeState();
}

class _TapFadeState extends State<_TapFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _fade  = Tween<double>(begin: 1.0, end: 0.55).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Opacity(
          opacity: _fade.value,
          child: Transform.scale(scale: _scale.value, child: child),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Twinkling star model
// ─────────────────────────────────────────────────────────────────────────────
class _TwinkleStar {
  final double x, y, baseOpacity, phase, size;
  const _TwinkleStar(
      {required this.x,
        required this.y,
        required this.baseOpacity,
        required this.phase,
        required this.size});

  factory _TwinkleStar.random(math.Random rng) => _TwinkleStar(
    x: rng.nextDouble(),
    y: rng.nextDouble(),
    baseOpacity: rng.nextDouble() * 0.5 + 0.25,
    phase: rng.nextDouble() * math.pi * 2,
    size: rng.nextDouble() * 1.4 + 0.5,
  );
}

class _TwinkleStarPainter extends CustomPainter {
  final List<_TwinkleStar> stars;
  final double progress;

  const _TwinkleStarPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle =
      (math.sin(progress * math.pi * 2 + s.phase) * 0.45 + 0.55).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: s.baseOpacity * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TwinkleStarPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Meteor streak painter (one-shot, diagonal sweep)
// ─────────────────────────────────────────────────────────────────────────────
class _MeteorPainter extends CustomPainter {
  final double progress;
  const _MeteorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 0.98) return;

    // Diagonal: top-right → bottom-left
    final startX = size.width * (0.55 + progress * 0.55);
    final startY = size.height * (progress * 0.35);
    final endX = startX - size.width * 0.38;
    final endY = startY + size.height * 0.28;

    // Tail fades in then fades out
    final alpha = progress < 0.5
        ? progress * 2
        : (1 - progress) * 2;

    final shader = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFFE8D8FF).withValues(alpha: alpha * 0.85),
      ],
    ).createShader(Rect.fromPoints(Offset(startX, startY), Offset(endX, endY)));

    final tailPaint = Paint()
      ..shader = shader
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tailPaint);

    // Head glow
    final headPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha * 0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset(endX, endY), 4, headPaint);

    // Sparkle trail
    final rng = math.Random(7);
    for (int i = 0; i < 6; i++) {
      final t = i / 6.0;
      final sx = startX + (endX - startX) * t + (rng.nextDouble() - 0.5) * 10;
      final sy = startY + (endY - startY) * t + (rng.nextDouble() - 0.5) * 6;
      final sp = Paint()
        ..color = const Color(0xFFB090FF).withValues(alpha: alpha * 0.4 * (1 - t));
      canvas.drawCircle(Offset(sx, sy), 1.5, sp);
    }
  }

  @override
  bool shouldRepaint(_MeteorPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shooting star sweep around active nav icon
// ─────────────────────────────────────────────────────────────────────────────
class _ShootingStarNavPainter extends CustomPainter {
  final double progress;
  const _ShootingStarNavPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 22.0;
    final angle = 2 * math.pi * progress;

    // Arc trail (last 90°)
    const arcLen = math.pi / 2;
    final startAngle = angle - arcLen;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFD0B8FF).withValues(alpha: 0.7),
        ],
        startAngle: startAngle,
        endAngle: angle,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle,
      arcLen,
      false,
      arcPaint,
    );

    // Head spark
    final hx = cx + r * math.cos(angle);
    final hy = cy + r * math.sin(angle);
    final headPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.90)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(hx, hy), 3, headPaint);
  }

  @override
  bool shouldRepaint(_ShootingStarNavPainter old) => old.progress != progress;
}