// lib/screens/history_page.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Cinematic HistoryPage
//  · Live cosmic background (twinkling stars + nebula drift)
//  · Animated constellation header line
//  · Vertical timeline with glowing connector dots
//  · Glassmorphic observation cards
//  · Twinkling star icon per card
//  · Expandable fact notes
//  · Empty state with shooting star animation
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with TickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ── Background ──
  late AnimationController _nebulaCtrl;
  late AnimationController _starCtrl;
  late List<_Star> _bgStars;

  // ── Header constellation draw-in ──
  late AnimationController _constellCtrl;

  // ── Empty state shooting star ──
  late AnimationController _shootCtrl;

  // ── Per-card twinkle (built lazily) ──
  final Map<int, AnimationController> _twinkleCtrl = {};

  // ── Expanded cards ──
  final Set<int> _expandedCards = {};

  final _rng = math.Random();

  @override
  void initState() {
    super.initState();

    _nebulaCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 9))..repeat(reverse: true);
    _starCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 15))..repeat();
    _bgStars = [];

    _constellCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2200))..forward();

    _shootCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2400))..repeat(
      period: const Duration(milliseconds: 3800),
    );
  }

  void _initStars(Size size) {
    if (_bgStars.isNotEmpty) return;
    _bgStars = List.generate(65, (_) => _Star.random(_rng, size));
  }

  AnimationController _twinkleFor(int index) {
    if (!_twinkleCtrl.containsKey(index)) {
      final c = AnimationController(vsync: this,
          duration: Duration(milliseconds: 1800 + _rng.nextInt(600)))
        ..repeat(reverse: true);
      _twinkleCtrl[index] = c;
    }
    return _twinkleCtrl[index]!;
  }

  @override
  void dispose() {
    _nebulaCtrl.dispose();
    _starCtrl.dispose();
    _constellCtrl.dispose();
    _shootCtrl.dispose();
    for (final c in _twinkleCtrl.values) { c.dispose(); }
    super.dispose();
  }

  String _formatDate(dynamic ts) {
    if (ts == null) return 'Unknown Date';
    if (ts is Timestamp) {
      final d = ts.toDate();
      const m = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${m[d.month-1]} ${d.day}, ${d.year}';
    }
    if (ts is String) return ts;
    return ts.toString();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initStars(size);
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Discoveries',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            )),
      ),
      body: Stack(
        children: [
          // ── Nebula gradient ──
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
                Positioned(top: size.height * (0.06 + t * 0.04), left: -70,
                    child: _blob(270, const Color(0xFF3B2880), 0.07 + t * 0.04)),
                Positioned(top: size.height * (0.55 - t * 0.03), right: -80,
                    child: _blob(230, const Color(0xFF1E3A8A), 0.06 + t * 0.03)),
              ]);
            },
          ),

          // ── Star field ──
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _StarFieldPainter(stars: _bgStars, progress: _starCtrl.value),
            ),
          ),

          // ── Page content ──
          user == null
              ? _buildSignInPrompt()
              : _buildTimeline(user, size),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Timeline
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTimeline(User user, Size size) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .doc(user.uid)
          .collection('observations')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9080FF)));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading history',
                style: TextStyle(color: Colors.red.shade300)),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(size, docs.length)),
            if (docs.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildTimelineItem(
                      docs[index].data() as Map<String, dynamic>,
                      index,
                      isLast: index == docs.length - 1,
                    ),
                    childCount: docs.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Header with animated constellation
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(Size size, int count) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR COSMIC JOURNAL',
                        style: TextStyle(
                          color: Color(0xFF8890B8),
                          fontSize: 11,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(duration: 500.ms),
                      const SizedBox(height: 6),
                      Text(
                        count > 0
                            ? '$count ${count == 1 ? 'Discovery' : 'Discoveries'}'
                            : 'Begin Your Journey',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 100.ms)
                          .slideX(begin: -0.1, end: 0),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Timeline item
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTimelineItem(Map<String, dynamic> data, int index,
      {required bool isLast}) {
    final starName = data['star_name'] as String? ?? 'Unknown Object';
    final fact = data['fact'] as String? ?? '';
    final date = _formatDate(data['timestamp']);
    final isExpanded = _expandedCards.contains(index);
    final twCtrl = _twinkleFor(index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Timeline connector ──
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  // Dot
                  AnimatedBuilder(
                    animation: twCtrl,
                    builder: (_, __) {
                      final glow = 0.4 + twCtrl.value * 0.6;
                      return Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF9080FF),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9080FF).withValues(alpha: glow * 0.7),
                              blurRadius: 10 + glow * 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Line
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 1.5,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF9080FF).withValues(alpha: 0.40),
                              const Color(0xFF9080FF).withValues(alpha: 0.08),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Card ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, top: 12),
                child: GestureDetector(
                  onTap: () {
                    if (fact.isNotEmpty) {
                      setState(() {
                        if (isExpanded) {
                          _expandedCards.remove(index);
                        } else {
                          _expandedCards.add(index);
                        }
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3D4EC8).withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Twinkling star icon
                              AnimatedBuilder(
                                animation: twCtrl,
                                builder: (_, __) {
                                  final glow = 0.3 + twCtrl.value * 0.7;
                                  return Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFFE080)
                                          .withValues(alpha: 0.10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFE080)
                                              .withValues(alpha: glow * 0.35),
                                          blurRadius: 12 + glow * 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: Color.lerp(
                                          const Color(0xFFFFD060),
                                          const Color(0xFFFFFFCC),
                                          twCtrl.value),
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 12),

                              // Star name + date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      starName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    // Date badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: const Color(0xFF9080FF)
                                            .withValues(alpha: 0.12),
                                        border: Border.all(
                                            color: const Color(0xFF9080FF)
                                                .withValues(alpha: 0.20)),
                                      ),
                                      child: Text(
                                        date,
                                        style: const TextStyle(
                                          color: Color(0xFFB090FF),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Expand chevron if has fact
                              if (fact.isNotEmpty)
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.expand_more_rounded,
                                    color: Colors.white.withValues(alpha: 0.35),
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),

                          // Fact (collapsed/expanded)
                          if (fact.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                            const SizedBox(height: 10),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 250),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: Text(
                                fact,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                              secondChild: Text(
                                fact,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 + index * 80))
        .fadeIn(duration: 450.ms)
        .slideX(begin: -0.12, end: 0, curve: Curves.easeOutQuart);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Empty state
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shooting star canvas
            SizedBox(
              width: 200,
              height: 120,
              child: AnimatedBuilder(
                animation: _shootCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _ShootingStarPainter(progress: _shootCtrl.value),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Silhouette icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9080FF).withValues(alpha: 0.10),
                border: Border.all(
                    color: const Color(0xFF9080FF).withValues(alpha: 0.20)),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: Color(0xFFB090FF), size: 40),
            ),

            const SizedBox(height: 24),

            const Text(
              'YOUR COSMIC JOURNEY\nBEGINS HERE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                height: 1.3,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 14),

            Text(
              'Point your phone at the sky to log\nyour first stellar discovery.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.50),
                fontSize: 14,
                height: 1.6,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 350.ms),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFF9080FF).withValues(alpha: 0.10),
                border: Border.all(
                    color: const Color(0xFF9080FF).withValues(alpha: 0.25)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('☄️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text('Open Camera to Start',
                      style: TextStyle(
                        color: Color(0xFFB090FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      )),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 500.ms).scale(
                begin: const Offset(0.9, 0.9)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Sign-in prompt
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌌', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            const Text('Sign in to access\nyour stargazing history',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                )),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6050C8), Color(0xFF9080FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7060D8).withValues(alpha: 0.45),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Text('Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Painters
// ─────────────────────────────────────────────────────────────────────────────

class _Star {
  final double x, y, size, speed, opacity;
  const _Star({required this.x, required this.y,
    required this.size, required this.speed, required this.opacity});
  factory _Star.random(math.Random rng, Size _) => _Star(
    x: rng.nextDouble(), y: rng.nextDouble(),
    size: rng.nextDouble() * 1.5 + 0.4,
    speed: rng.nextDouble() * 0.022 + 0.004,
    opacity: rng.nextDouble() * 0.25 + 0.08,
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
        Offset(s.x * size.width, dy * size.height), s.size,
        Paint()
          ..color = Colors.white.withValues(alpha: s.opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.7),
      );
    }
  }
  @override
  bool shouldRepaint(_StarFieldPainter old) => old.progress != progress;
}

// Header constellation — 5 stars connected left→right with draw-in animation
class _HeaderConstellationPainter extends CustomPainter {
  final double progress;
  const _HeaderConstellationPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Star positions (normalized)
    final points = [
      Offset(0.04, 0.7),
      Offset(0.18, 0.25),
      Offset(0.35, 0.65),
      Offset(0.52, 0.20),
      Offset(0.68, 0.60),
      Offset(0.82, 0.30),
      Offset(0.96, 0.55),
    ].map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList();

    // Draw lines (animated draw-in per segment)
    final totalSegments = points.length - 1;
    for (int i = 0; i < totalSegments; i++) {
      final segStart = i / totalSegments;
      final segEnd   = (i + 1) / totalSegments;
      final segProgress = ((progress - segStart) / (segEnd - segStart)).clamp(0.0, 1.0);
      if (segProgress <= 0) continue;

      final p1 = points[i];
      final p2 = points[i + 1];
      final ep = Offset(
        p1.dx + (p2.dx - p1.dx) * segProgress,
        p1.dy + (p2.dy - p1.dy) * segProgress,
      );

      canvas.drawLine(p1, ep, Paint()
        ..color = const Color(0xFF6070C8).withValues(alpha: 0.40)
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1));
    }

    // Draw star dots
    for (int i = 0; i < points.length; i++) {
      final dotProgress = ((progress - (i / points.length) * 0.6) / 0.3).clamp(0.0, 1.0);
      if (dotProgress <= 0) continue;

      // Glow
      canvas.drawCircle(points[i], 5,
          Paint()
            ..color = const Color(0xFFD0C8FF).withValues(alpha: 0.25 * dotProgress)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
      // Core dot
      canvas.drawCircle(points[i], 2.2,
          Paint()..color = Colors.white.withValues(alpha: dotProgress));
    }
  }

  @override
  bool shouldRepaint(_HeaderConstellationPainter old) => old.progress != progress;
}

// Empty state shooting star — looping diagonal streak
class _ShootingStarPainter extends CustomPainter {
  final double progress;
  const _ShootingStarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Ease in/out within a loop window
    final t = progress.clamp(0.0, 1.0);
    final alpha = t < 0.5 ? t * 2 : (1 - t) * 2;
    if (alpha <= 0) return;

    final startX = size.width * 0.85;
    final startY = size.height * 0.05;
    final endX = startX - size.width * 0.75 * t;
    final endY = startY + size.height * 0.75 * t;

    final shader = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFFE0D8FF).withValues(alpha: alpha * 0.85),
      ],
    ).createShader(Rect.fromPoints(
        Offset(startX, startY), Offset(endX, endY)));

    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      Paint()
        ..shader = shader
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Glowing head
    canvas.drawCircle(Offset(endX, endY), 4,
        Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.90)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Sparkles
    final rng = math.Random(13);
    for (int i = 0; i < 5; i++) {
      final sx = endX + (rng.nextDouble() - 0.5) * 14;
      final sy = endY + (rng.nextDouble() - 0.5) * 10;
      canvas.drawCircle(Offset(sx, sy), 1.2,
          Paint()..color = const Color(0xFFB090FF).withValues(
              alpha: alpha * 0.50 * (1 - t * 0.5)));
    }
  }

  @override
  bool shouldRepaint(_ShootingStarPainter old) => old.progress != progress;
}