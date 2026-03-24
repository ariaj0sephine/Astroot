// lib/screens/event_page.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Cinematic EventWidget
//  · Live cosmic background (twinkling stars + nebula drift)
//  · Glassmorphic filter tabs with star particle burst on active
//  · Staggered list fade with scale + glow on tap
//  · Animated notification toggle with star burst
//  · Full-screen glass bottom sheet detail with meteor streak
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EventWidget extends StatefulWidget {
  const EventWidget({super.key});

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget>
    with TickerProviderStateMixin {
  String _selectedFilter = 'all';
  late List<bool> _reminderOn;

  // ── Background animations ──
  late AnimationController _nebulaCtrl;
  late AnimationController _starCtrl;
  late List<_Star> _stars;

  // ── Tab switch animation ──
  late AnimationController _tabCtrl;
  late Animation<double> _tabFade;

  // ── Per-card tap scale ──
  final List<AnimationController> _cardTap = [];

  // ── Per-card reminder burst ──
  final List<AnimationController> _reminderBurst = [];

  final _rng = math.Random();

  // ─── Event data ───────────────────────────────────────────────────────────
  final List<Map<String, String>> events = [
    {
      'title': 'Quadrantids Meteor Shower',
      'date': 'January 3–4, 2026',
      'short': 'Up to 100 meteors/hour.',
      'full':
      'One of the strongest showers of the year! Fast, bright shooting stars that can reach up to 100 per hour under perfect conditions. Best viewed in the Northern Hemisphere after midnight. In 2026, a nearly full Moon will hide many fainter meteors, but the brightest ones will still shine through.',
      'image': 'assets/images/quad.jpg',
      'type': 'meteor',
      'rate': '100/hr',
    },
    {
      'title': 'Total Lunar Eclipse',
      'date': 'March 3, 2026',
      'short': 'Blood Moon! • Visible worldwide at night',
      'full':
      'A stunning "Blood Moon"! The Moon passes through Earth\'s shadow and turns a deep reddish color. Completely safe to watch with the naked eye. Visible anywhere it\'s nighttime — in 2026, best seen from the Americas, Europe, Africa, and parts of Asia. It lasts several hours, so plenty of time to enjoy.',
      'image': 'assets/images/total_lunar.jpg',
      'type': 'eclipse',
      'rate': 'Full',
    },
    {
      'title': 'Lyrids Meteor Shower',
      'date': 'April 22–23, 2026',
      'short': '10–20 meteors/hour • Some bright fireballs',
      'full':
      'One of the oldest known showers, recorded for over 2,700 years! Produces about 10–20 meteors per hour, with some bright fireballs and fast streaks. Great dark skies in 2026 thanks to low moonlight. Best in the Northern Hemisphere — look toward the constellation Lyra after midnight.',
      'image': 'assets/images/lyrids.jpg',
      'type': 'meteor',
      'rate': '20/hr',
    },
    {
      'title': 'Eta Aquariids Meteor Shower',
      'date': 'May 5–6, 2026',
      'short': 'Up to 50 meteors/hour.',
      'full':
      'Fast and bright meteors from debris of famous Halley\'s Comet! Up to 50 per hour in perfect conditions, best viewed before dawn. Much stronger in the Southern Hemisphere, but visible worldwide. In 2026, bright moonlight may reduce numbers, but early risers can still catch great streaks.',
      'image': 'assets/images/eta.jpg',
      'type': 'meteor',
      'rate': '50/hr',
    },
    {
      'title': 'Perseids Meteor Shower',
      'date': 'August 12–13, 2026',
      'short': 'Up to 100 meteors/hour • Excellent dark skies!',
      'full':
      'One of the most popular and reliable showers! Up to 100 fast, bright meteors per hour with long trails. In 2026, perfect dark skies near New Moon make it extra spectacular. Best in the Northern Hemisphere during warm summer nights — a favorite for stargazing parties.',
      'image': 'assets/images/perseids.jpg',
      'type': 'meteor',
      'rate': '100/hr',
    },
    {
      'title': 'Total Solar Eclipse',
      'date': 'August 12, 2026',
      'short': 'Day turns to night! • Path over Europe',
      'full':
      'Day turns to sudden darkness! The Moon completely covers the Sun for up to 2 minutes, revealing the glowing corona. Total path crosses Greenland, Iceland, and northern Spain. Partial views across much of Europe and nearby areas. Never look directly without proper eclipse glasses (except during totality).',
      'image': 'assets/images/solar_eclipse.jpg',
      'type': 'eclipse',
      'rate': 'Total',
    },
    {
      'title': 'Orionids Meteor Shower',
      'date': 'October 21–22, 2026',
      'short': '20–25 meteors/hour • From Halley\'s Comet',
      'full':
      'Fast meteors with glowing trails, also from Halley\'s Comet debris! About 20–25 per hour, some bright ones. Visible worldwide, best after midnight. In 2026, some moonlight interference, but still a beautiful show radiating from near Orion.',
      'image': 'assets/images/orionids.jpg',
      'type': 'meteor',
      'rate': '25/hr',
    },
    {
      'title': 'Geminids Meteor Shower',
      'date': 'December 13–14, 2026',
      'short': 'Up to 120 colorful meteors/hour!',
      'full':
      'Often the strongest and most colorful shower of the year! Up to 120 bright, multicolored meteors per hour, visible all night long. Great dark skies in 2026. Best worldwide, even before midnight — perfect for cold winter evenings under the stars.',
      'image': 'assets/images/geminids.jpg',
      'type': 'meteor',
      'rate': '120/hr',
    },
  ];

  @override
  void initState() {
    super.initState();

    _reminderOn = List<bool>.filled(events.length, false);

    _nebulaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _tabFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOut),
    );
    _tabCtrl.forward();

    for (int i = 0; i < events.length; i++) {
      _cardTap.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ));
      _reminderBurst.add(AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      ));
    }

    _stars = [];
  }

  void _initStars(Size size) {
    if (_stars.isNotEmpty) return;
    _stars = List.generate(40, (_) => _Star.random(_rng, size));
  }

  @override
  void dispose() {
    _nebulaCtrl.dispose();
    _starCtrl.dispose();
    _tabCtrl.dispose();
    for (final c in _cardTap) { c.dispose(); }
    for (final c in _reminderBurst) { c.dispose(); }
    super.dispose();
  }

  void _switchFilter(String filter) {
    setState(() {
      _selectedFilter = (_selectedFilter == filter) ? 'all' : filter;
    });
    _tabCtrl.forward(from: 0);
  }

  List<Map<String, String>> get _filtered => events
      .where((e) => _selectedFilter == 'all' || e['type'] == _selectedFilter)
      .toList();

  // ── Find original index for reminder toggle ──
  int _originalIndex(Map<String, String> event) => events.indexOf(event);

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
          // ── Nebula background ──
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
                      Color.lerp(const Color(0xFF000A1E), const Color(0xFF04082A), t)!,
                      Color.lerp(const Color(0xFF00132D), const Color(0xFF060E38), t)!,
                      Color.lerp(const Color(0xFF001845), const Color(0xFF0A1450), t)!,
                      Color.lerp(const Color(0xFF002050), const Color(0xFF0C1A5C), t)!,
                    ],
                    stops: const [0.0, 0.2, 0.55, 1.0],
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
                  top: size.height * (0.08 + t * 0.05),
                  left: -70,
                  child: _blob(260, const Color(0xFF3B2880), 0.07 + t * 0.04),
                ),
                Positioned(
                  top: size.height * (0.50 - t * 0.04),
                  right: -80,
                  child: _blob(220, const Color(0xFF1E3A8A), 0.06 + t * 0.03),
                ),
              ]);
            },
          ),

          // ── Star field ──
          AnimatedBuilder(
            animation: _starCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _StarFieldPainter(
                stars: _stars,
                progress: _starCtrl.value,
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabs(),
                const SizedBox(height: 8),
                Expanded(child: _buildList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const Text(
            'EVENTS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF725ABA).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: const Color(0xFF725ABA).withValues(alpha: 0.4)),
            ),
            child: Text(
              '${events.length}',
              style: const TextStyle(
                  color: Color(0xFFB090FF), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: -0.2, end: 0);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Tabs
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _tab('meteor', '☄️  Meteors'),
          const SizedBox(width: 12),
          _tab('eclipse', '🌑  Eclipses'),
        ],
      ),
    );
  }

  Widget _tab(String filter, String label) {
    final isActive = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => _switchFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: isActive
              ? const LinearGradient(
            colors: [Color(0xFF5860D8), Color(0xFF8B5CE8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: isActive
                ? const Color(0xFF9D8CFF).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.10),
            width: 1,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: const Color(0xFF6A5CE8).withValues(alpha: 0.45),
              blurRadius: 18,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFFB090FF).withValues(alpha: 0.15),
              blurRadius: 30,
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.55),
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
            // Star particle burst when active
            if (isActive) ...[
              const SizedBox(width: 6),
              _TabStarBurst(key: ValueKey(filter)),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Event list
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildList() {
    final filtered = _filtered;
    return FadeTransition(
      opacity: _tabFade,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        physics: const BouncingScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final event = filtered[index];
          final origIdx = _originalIndex(event);
          return _buildCard(event, origIdx, index);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCard(Map<String, String> event, int origIdx, int listIdx) {
    final isMeteor = event['type'] == 'meteor';
    final accentColor =
    isMeteor ? const Color(0xFFFFAA44) : const Color(0xFFB090FF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTapDown: (_) => _cardTap[origIdx].forward(),
        onTapUp: (_) {
          _cardTap[origIdx].reverse();
          _openDetail(event, origIdx);
        },
        onTapCancel: () => _cardTap[origIdx].reverse(),
        child: AnimatedBuilder(
          animation: _cardTap[origIdx],
          builder: (_, child) => Transform.scale(
            scale: 1.0 - _cardTap[origIdx].value * 0.025,
            child: child,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.10),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // ── Image with slow zoom ──
                  SizedBox(
                    width: 100,
                    height: 110,
                    child: _ZoomImage(asset: event['image']!),
                  ),

                  // ── Text content ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: accentColor.withValues(alpha: 0.30),
                                  width: 1),
                            ),
                            child: Text(
                              isMeteor ? '☄️ METEOR' : '🌑 ECLIPSE',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),

                          // Title
                          Text(
                            event['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),

                          // Date
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined,
                                  color: accentColor.withValues(alpha: 0.8),
                                  size: 11),
                              const SizedBox(width: 4),
                              Text(
                                event['date']!,
                                style: TextStyle(
                                  color: accentColor.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),

                          // Rate badge + short desc
                          Row(
                            children: [
                              // Rate pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accentColor.withValues(alpha: 0.25),
                                      accentColor.withValues(alpha: 0.10),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '★ ${event['rate']!}',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Reminder toggle ──
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Burst ring when ON
                        AnimatedBuilder(
                          animation: _reminderBurst[origIdx],
                          builder: (_, __) {
                            final p = _reminderBurst[origIdx].value;
                            if (p == 0) return const SizedBox.shrink();
                            return CustomPaint(
                              size: const Size(60, 60),
                              painter: _ReminderBurstPainter(progress: p),
                            );
                          },
                        ),
                        _AnimatedSwitch(
                          value: _reminderOn[origIdx],
                          onChanged: (v) {
                            setState(() => _reminderOn[origIdx] = v);
                            if (v) _reminderBurst[origIdx].forward(from: 0);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 80 + listIdx * 80))
        .fade(duration: 450.ms)
        .slideY(begin: 0.18, end: 0, curve: Curves.easeOutQuart);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Detail bottom sheet
  // ─────────────────────────────────────────────────────────────────────────
  void _openDetail(Map<String, String> event, int origIdx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventDetailSheet(event: event),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
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
//  Event Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _EventDetailSheet extends StatefulWidget {
  final Map<String, String> event;
  const _EventDetailSheet({required this.event});

  @override
  State<_EventDetailSheet> createState() => _EventDetailSheetState();
}

class _EventDetailSheetState extends State<_EventDetailSheet>
    with TickerProviderStateMixin {
  late AnimationController _meteorCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _meteorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  @override
  void dispose() {
    _meteorCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMeteor = widget.event['type'] == 'meteor';
    final accentColor =
    isMeteor ? const Color(0xFFFFAA44) : const Color(0xFFB090FF);
    final size = MediaQuery.of(context).size;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          color: const Color(0xFF080C22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Stack(
            children: [
              // ── Meteor streak on open ──
              AnimatedBuilder(
                animation: _meteorCtrl,
                builder: (_, __) => CustomPaint(
                  size: Size(size.width, 300),
                  painter:
                  _DetailMeteorPainter(progress: _meteorCtrl.value),
                ),
              ),

              // ── Scrollable content ──
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: SingleChildScrollView(
                    controller: scrollCtrl,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),

                        // Hero image
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.20),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _ZoomImage(asset: widget.event['image']!),
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        const Color(0xFF080C22)
                                            .withValues(alpha: 0.85),
                                      ],
                                    ),
                                  ),
                                ),
                                // Type badge on image
                                Positioned(
                                  top: 14,
                                  left: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                      Colors.black.withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: accentColor
                                              .withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      isMeteor ? '☄️ METEOR SHOWER' : '🌑 ECLIPSE',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                                // Close button
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color:
                                        Colors.black.withValues(alpha: 0.55),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.20)),
                                      ),
                                      child: const Icon(Icons.close_rounded,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Date row
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      color: accentColor, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.event['date']!,
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Rate pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accentColor.withValues(alpha: 0.20),
                                      accentColor.withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: accentColor.withValues(alpha: 0.35)),
                                ),
                                child: Text(
                                  '★  ${widget.event['short']!}',
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Divider
                              Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              const SizedBox(height: 20),

                              // Full description
                              Text(
                                widget.event['full']!,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.80),
                                  fontSize: 15,
                                  height: 1.7,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Tip box
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFF1A1040).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: accentColor.withValues(alpha: 0.20)),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      isMeteor ? '🌌' : '🔭',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        isMeteor
                                            ? 'Find a dark spot away from city lights and let your eyes adjust for 20 minutes.'
                                            : 'Use certified eclipse glasses for solar events. Never look directly at the Sun.',
                                        style: TextStyle(
                                          color:
                                          Colors.white.withValues(alpha: 0.65),
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
//  Zoom image widget (slow scale-in on load)
// ─────────────────────────────────────────────────────────────────────────────
class _ZoomImage extends StatefulWidget {
  final String asset;
  const _ZoomImage({required this.asset});

  @override
  State<_ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<_ZoomImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();
    _scale = Tween<double>(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Image.asset(
          widget.asset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Tab star burst widget
// ─────────────────────────────────────────────────────────────────────────────
class _TabStarBurst extends StatefulWidget {
  const _TabStarBurst({super.key});

  @override
  State<_TabStarBurst> createState() => _TabStarBurstState();
}

class _TabStarBurstState extends State<_TabStarBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return CustomPaint(
          size: const Size(16, 16),
          painter: _TabBurstPainter(progress: t),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Animated switch widget
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedSwitch({required this.value, required this.onChanged});

  @override
  State<_AnimatedSwitch> createState() => _AnimatedSwitchState();
}

class _AnimatedSwitchState extends State<_AnimatedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.value) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_AnimatedSwitch old) {
    super.didUpdateWidget(old);
    if (widget.value && !old.value) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.value && old.value) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => Container(
        decoration: widget.value
            ? BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9D8CFF)
                  .withValues(alpha: _glowAnim.value * 0.55),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        )
            : null,
        child: child,
      ),
      child: Switch(
        value: widget.value,
        onChanged: widget.onChanged,
        activeColor: const Color(0xFFB090FF),
        activeTrackColor: const Color(0xFF5040A0),
        inactiveThumbColor: Colors.grey.shade500,
        inactiveTrackColor: Colors.grey.shade800,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Painters
// ─────────────────────────────────────────────────────────────────────────────

class _Star {
  final double x, y, size, speed, opacity;
  const _Star(
      {required this.x,
        required this.y,
        required this.size,
        required this.speed,
        required this.opacity});
  factory _Star.random(math.Random rng, Size _) => _Star(
    x: rng.nextDouble(),
    y: rng.nextDouble(),
    size: rng.nextDouble() * 1.2 + 0.5,
    speed: rng.nextDouble() * 0.025 + 0.004,
    opacity: rng.nextDouble() * 0.30 + 0.10,
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
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: s.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
      canvas.drawCircle(
          Offset(s.x * size.width, dy * size.height), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.progress != progress;
}

// Tab active star burst (rotating sparks)
class _TabBurstPainter extends CustomPainter {
  final double progress;
  const _TabBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final angle = progress * math.pi * 2;
    for (int i = 0; i < 4; i++) {
      final a = angle + i * math.pi / 2;
      final r = 5.0 + math.sin(progress * math.pi * 2) * 2;
      final px = cx + r * math.cos(a);
      final py = cy + r * math.sin(a);
      final paint = Paint()
        ..color = const Color(0xFFD0C0FF)
            .withValues(alpha: 0.6 + math.sin(progress * math.pi * 4) * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(px, py), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_TabBurstPainter old) => old.progress != progress;
}

// Reminder toggle burst
class _ReminderBurstPainter extends CustomPainter {
  final double progress;
  const _ReminderBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final alpha = (1 - progress).clamp(0.0, 1.0);
    final rng = math.Random(21);
    for (int i = 0; i < 10; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final r = progress * 28.0;
      final px = cx + r * math.cos(angle);
      final py = cy + r * math.sin(angle);
      final paint = Paint()
        ..color = const Color(0xFFB090FF).withValues(alpha: alpha * 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(px, py), 2.5 * (1 - progress * 0.5), paint);
    }
    // Center flash
    final flash = Paint()
      ..color =
      const Color(0xFFE0D0FF).withValues(alpha: alpha * 0.4 * (1 - progress))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(cx, cy), 20 * progress, flash);
  }

  @override
  bool shouldRepaint(_ReminderBurstPainter old) => old.progress != progress;
}

// Detail sheet meteor streak
class _DetailMeteorPainter extends CustomPainter {
  final double progress;
  const _DetailMeteorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 0.98) return;

    final alpha = progress < 0.45
        ? progress / 0.45
        : 1 - (progress - 0.45) / 0.55;

    // Multiple meteors for drama
    final meteors = [
      [0.85, 0.05, -0.55, 0.30],
      [0.95, 0.02, -0.45, 0.22],
      [0.75, 0.08, -0.40, 0.18],
    ];

    for (final m in meteors) {
      final startX = size.width * m[0];
      final startY = size.height * m[1];
      final endX = startX + size.width * m[2] * progress;
      final endY = startY + size.height * m[3] * progress;

      final shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFE0D8FF).withValues(alpha: alpha * 0.7),
        ],
      ).createShader(Rect.fromPoints(
          Offset(startX, startY), Offset(endX, endY)));

      final paint = Paint()
        ..shader = shader
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      // Glowing head
      final head = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(endX, endY), 3.5, head);
    }
  }

  @override
  bool shouldRepaint(_DetailMeteorPainter old) => old.progress != progress;
}