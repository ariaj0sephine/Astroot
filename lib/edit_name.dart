// lib/screens/edit_name.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class EditNamePage extends StatefulWidget {
  final String currentName;
  const EditNamePage({super.key, required this.currentName});

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage>
    with TickerProviderStateMixin {
  late TextEditingController _ctrl;
  late AnimationController _nebulaCtrl;
  late AnimationController _starCtrl;
  late AnimationController _burstCtrl;
  late List<_Star> _stars;
  final _rng = math.Random();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentName);
    _ctrl.addListener(() => setState(() {}));

    _nebulaCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 8))..repeat(reverse: true);
    _starCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 14))..repeat();
    _burstCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700));
    _stars = [];
  }

  void _initStars(Size size) {
    if (_stars.isNotEmpty) return;
    _stars = List.generate(55, (_) => _Star.random(_rng, size));
  }

  @override
  void dispose() {
    _ctrl.dispose(); _focus.dispose();
    _nebulaCtrl.dispose(); _starCtrl.dispose(); _burstCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    _burstCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) Navigator.pop(context, _ctrl.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initStars(size);

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
        title: const Text('Edit Name',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            )),
      ),
      body: Stack(
        children: [
          // Nebula bg
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
                      Color.lerp(const Color(0xFF131848), const Color(0xFF1A1E58), t)!,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              );
            },
          ),
          // Stars
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _StarFieldPainter(stars: _stars, progress: _starCtrl.value),
            ),
          ),
          // Burst
          AnimatedBuilder(
            animation: _burstCtrl,
            builder: (_, __) {
              if (_burstCtrl.value == 0 || _burstCtrl.value >= 0.98) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BurstPainter(
                      progress: _burstCtrl.value,
                      cx: size.width / 2,
                      cy: size.height * 0.82,
                    ),
                  ),
                ),
              );
            },
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Label
                  Text('YOUR COSMIC NAME',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 11,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 20),

                  // Glass text field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12), width: 1),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      maxLength: 15,
                      autofocus: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      cursorColor: const Color(0xFF9080FF),
                      decoration: InputDecoration(
                        hintText: 'Enter your name...',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 20),
                        filled: true,
                        fillColor: Colors.transparent,
                        counterStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 12),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF9080FF), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.10),
                              width: 1),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Save button
                  GestureDetector(
                    onTap: _onSave,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6050C8), Color(0xFF9080FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7060D8).withValues(alpha: 0.50),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('SAVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared painters / models ────────────────────────────────────────────────

class _Star {
  final double x, y, size, speed, opacity;
  const _Star({required this.x, required this.y,
    required this.size, required this.speed, required this.opacity});
  factory _Star.random(math.Random rng, Size _) => _Star(
    x: rng.nextDouble(), y: rng.nextDouble(),
    size: rng.nextDouble() * 1.4 + 0.4,
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

class _BurstPainter extends CustomPainter {
  final double progress;
  final double cx, cy;
  const _BurstPainter({required this.progress, required this.cx, required this.cy});

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final rng = math.Random(55);
    for (int i = 0; i < 16; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final r = progress * size.width * 0.30 * (rng.nextDouble() * 0.5 + 0.5);
      final colors = [
        const Color(0xFFFFFFFF), const Color(0xFFD0C8FF),
        const Color(0xFFFFE080), const Color(0xFF9080FF),
      ];
      canvas.drawCircle(
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        (rng.nextDouble() * 2.5 + 0.8) * (1 - progress * 0.4),
        Paint()
          ..color = colors[i % 4].withValues(alpha: alpha * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
    canvas.drawCircle(Offset(cx, cy), 28 * progress,
      Paint()
        ..color = const Color(0xFFE0D8FF).withValues(alpha: alpha * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.progress != progress;
}