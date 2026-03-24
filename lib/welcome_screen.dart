import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'auth_screen.dart';

// ─────────────────────────────────────────────
//  WelcomePage — cinematic, animated entry screen
// ─────────────────────────────────────────────
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  // ── Astronaut float + rotation ──
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late Animation<double> _floatAnim;
  late Animation<double> _rotateAnim;

  // ── Staggered text fade-in ──
  late AnimationController _textController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _buttonFade;

  // ── Button pulse ──
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Button orbiting ring ──
  late AnimationController _orbitController;

  // ── Tap → scale-down + fade transition ──
  late AnimationController _tapController;
  late Animation<double> _tapScale;
  late Animation<double> _tapFade;

  // ── Stars ──
  late List<_Star> _stars;
  late AnimationController _starController;

  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    // Float: gentle up/down, 3 s, looping with reverse
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 18).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Slow rotation: ±4°, 6 s, looping
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);
    _rotateAnim = Tween<double>(
      begin: -4 * math.pi / 180,
      end: 4 * math.pi / 180,
    ).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    // Stars drifting
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Text stagger — title at 400 ms, subtitle at 900 ms, button at 1 400 ms
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.20, 0.55, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.20, 0.55, curve: Curves.easeOut),
      ),
    );
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
      ),
    );
    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse: button breathes every 1.8 s
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.055).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Orbiting ring around button
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Tap scale/fade for transition
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeIn),
    );
    _tapFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeIn),
    );

    // Kick off text entrance after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _textController.forward();
    });

    // Init stars (deferred so we have size context)
    _stars = [];
  }

  void _initStars(Size size) {
    if (_stars.isNotEmpty) return;
    _stars = List.generate(40, (_) => _Star.random(_random, size));
  }

  Future<void> _onGetStarted() async {
    await _tapController.forward();
    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    _starController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initStars(size);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _tapScale,
          _tapFade,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _tapFade,
            child: Transform.scale(
              scale: _tapScale.value,
              child: child,
            ),
          );
        },
        child: Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.0, -1.0),
              end: Alignment(0.0, 1.0),
              colors: [
                Color(0xFF000A1E),
                Color(0xFF001230),
                Color(0xFF001E52),
                Color(0xFF002657),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // ── Star field ──
              AnimatedBuilder(
                animation: _starController,
                builder: (_, __) {
                  return CustomPaint(
                    size: size,
                    painter: _StarFieldPainter(
                      stars: _stars,
                      progress: _starController.value,
                    ),
                  );
                },
              ),

              // ── Soft nebula glow ──
              Positioned(
                top: size.height * 0.02,
                left: size.width * 0.05,
                child: _glowCircle(
                  size.width * 0.85,
                  const Color(0xFF6A3DB8),
                  0.18,
                ),
              ),

              // ── Secondary accent glow ──
              Positioned(
                top: size.height * 0.20,
                left: size.width * 0.30,
                child: _glowCircle(
                  size.width * 0.45,
                  const Color(0xFF4060D8),
                  0.12,
                ),
              ),

              // ── Floating + rotating astronaut ──
              AnimatedBuilder(
                animation: Listenable.merge([_floatAnim, _rotateAnim]),
                builder: (_, child) {
                  return Positioned(
                    top: size.height * 0.04 - _floatAnim.value,
                    left: size.width * 0.08,
                    right: size.width * 0.08,
                    child: SizedBox(
                      height: size.height * 0.56,
                      child: Transform.rotate(
                        angle: _rotateAnim.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/astronaut.png',
                  fit: BoxFit.contain,
                ),
              ),

              // ── Decorative large bubble (bottom-left) ──
              Positioned(
                top: size.height * 0.52,
                left: -size.width * 0.12,
                child: _glowCircle(
                  size.width * 0.52,
                  const Color(0xFF8C64DC),
                  0.14,
                ),
              ),

              // ── Small accent bubbles ──
              Positioned(
                top: size.height * 0.69,
                left: size.width * 0.37,
                child: _bubble(20, const Color(0xFFA078F0), 0.32),
              ),
              Positioned(
                top: size.height * 0.76,
                left: size.width * 0.06,
                child: _bubble(13, const Color(0xFF8264C8), 0.28),
              ),

              // ── TITLE — staggered fade + slide ──
              Positioned(
                top: size.height * 0.58,
                left: size.width * 0.06,
                right: size.width * 0.06,
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) {
                    return FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: const Text(
                          'EXPLORE THE\nUNKNOWN.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── SUBTITLE — slightly delayed ──
              Positioned(
                top: size.height * 0.695,
                left: size.width * 0.06,
                right: size.width * 0.06,
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) {
                    return FadeTransition(
                      opacity: _subtitleFade,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: Text(
                          'Your journey to the cosmos begins here.',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.60),
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── GET STARTED button (pulse + orbit ring) ──
              Positioned(
                bottom: size.height * 0.08,
                left: size.width * 0.18,
                right: size.width * 0.18,
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (_, child) {
                    return FadeTransition(
                      opacity: _buttonFade,
                      child: child,
                    );
                  },
                  child: AnimatedBuilder(
                    animation: Listenable.merge([
                      _pulseAnim,
                      _orbitController,
                    ]),
                    builder: (_, __) {
                      return Transform.scale(
                        scale: _pulseAnim.value,
                        child: GestureDetector(
                          onTap: _onGetStarted,
                          child: SizedBox(
                            height: size.height * 0.068,
                            child: CustomPaint(
                              painter: _OrbitPainter(
                                progress: _orbitController.value,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35),
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xFF8C64F0),
                                      Color(0xFFC88CFF),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF9B59E8)
                                          .withValues(alpha: 0.55),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFD090FF)
                                          .withValues(alpha: 0.20),
                                      blurRadius: 55,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'GET STARTED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glowCircle(double size, Color color, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );

  Widget _bubble(double size, Color color, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}

// ─────────────────────────────────────────────
//  Star model
// ─────────────────────────────────────────────
class _Star {
  final double x; // 0..1 fractional
  double y; // 0..1 fractional
  final double size;
  final double speed; // fraction of screen per loop
  final double opacity;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  factory _Star.random(math.Random rng, Size _) => _Star(
    x: rng.nextDouble(),
    y: rng.nextDouble(),
    size: rng.nextDouble() * 1.8 + 0.4,
    speed: rng.nextDouble() * 0.035 + 0.005,
    opacity: rng.nextDouble() * 0.25 + 0.08,
  );
}

// ─────────────────────────────────────────────
//  Star field painter — stars drift slowly downward
// ─────────────────────────────────────────────
class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress; // 0..1

  const _StarFieldPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // drift down, wrap
      final dy = (star.y + star.speed * progress) % 1.0;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: star.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
      canvas.drawCircle(
        Offset(star.x * size.width, dy * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
//  Orbit painter — two small glowing particles
//  circling the button
// ─────────────────────────────────────────────
class _OrbitPainter extends CustomPainter {
  final double progress; // 0..1

  const _OrbitPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const rx = 6.0; // x-radius of orbit ellipse (tight around pill)
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Two particles 180° apart
    for (int i = 0; i < 2; i++) {
      final angle = 2 * math.pi * progress + i * math.pi;
      final px = cx + (cx - 10) * math.cos(angle);
      final py = cy + rx * math.sin(angle);

      final glow = Paint()
        ..color = const Color(0xFFE0B0FF).withValues(alpha: 0.70)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(Offset(px, py), 5, glow);

      final core = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.95);
      canvas.drawCircle(Offset(px, py), 2.5, core);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.progress != progress;
}