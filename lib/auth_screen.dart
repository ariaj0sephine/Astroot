// lib/screens/auth_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Cinematic AuthScreen  — floating astronaut · star particles · focus glows
//  field-shake errors · comet link · fade-out page transition
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Root shell
// ─────────────────────────────────────────────────────────────────────────────
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  bool isLogin = true;

  // Page-level fade+scale exit controller
  late AnimationController _exitCtrl;
  late Animation<double> _exitFade;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
    _exitScale = Tween<double>(begin: 1, end: 0.90).animate(
      CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _exitCtrl.dispose();
    super.dispose();
  }

  void toggle() => setState(() => isLogin = !isLogin);

  Future<void> goToHome() async {
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (_, child) => FadeTransition(
        opacity: _exitFade,
        child: Transform.scale(scale: _exitScale.value, child: child),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: isLogin
              ? LoginPage(
            key: const ValueKey('login'),
            onToggle: toggle,
            onSuccess: goToHome,
          )
              : SignUpPage(
            key: const ValueKey('signup'),
            onToggle: toggle,
            onSuccess: goToHome,
            switchToLogin: toggle,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared cosmic background (star field + floating astronaut)
// ─────────────────────────────────────────────────────────────────────────────
class _CosmicBackground extends StatefulWidget {
  final String astronautAsset;
  final double astronautWidth;
  final double astronautTopFraction;
  final Alignment astronautAlignment; // horizontal alignment

  const _CosmicBackground({
    required this.astronautAsset,
    this.astronautWidth = 260,
    this.astronautTopFraction = 0.0,
    this.astronautAlignment = Alignment.center,
  });

  @override
  State<_CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<_CosmicBackground>
    with TickerProviderStateMixin {
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;
  late AnimationController _starCtrl;
  late List<_Star> _stars;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _stars = [];
  }

  void _initStars(Size size) {
    if (_stars.isNotEmpty) return;
    _stars = List.generate(30, (_) => _Star.random(_rng, size));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _starCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _initStars(size);

    return Stack(
      children: [
        // Deep cosmic gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF02071A),
                Color(0xFF070B22),
                Color(0xFF0C1130),
                Color(0xFF131848),
              ],
              stops: [0, 0.3, 0.65, 1.0],
            ),
          ),
        ),

        // Star particles drifting upward
        AnimatedBuilder(
          animation: _starCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _StarFieldPainter(
              stars: _stars,
              progress: _starCtrl.value,
              driftUp: true,
            ),
          ),
        ),

        // Soft nebula glow
        Positioned(
          top: size.height * (widget.astronautTopFraction - 0.04),
          left: size.width * 0.10,
          child: Container(
            width: size.width * 0.80,
            height: size.width * 0.80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x1A7B50D8),
            ),
          ),
        ),

        // Floating astronaut (drifts upward on anim)
        AnimatedBuilder(
          animation: _floatAnim,
          builder: (_, child) => Positioned(
            top: size.height * widget.astronautTopFraction - _floatAnim.value,
            left: 0,
            right: 0,
            child: Align(
              alignment: widget.astronautAlignment,
              child: child!,
            ),
          ),
          child: Image.asset(
            widget.astronautAsset,
            width: widget.astronautWidth,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LOGIN PAGE
// ─────────────────────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  final VoidCallback onToggle;
  final VoidCallback onSuccess;

  const LoginPage({super.key, required this.onToggle, required this.onSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscurePass = true;

  // shake controller per field
  late AnimationController _emailShake;
  late AnimationController _passShake;
  late AnimationController _btnShake;

  @override
  void initState() {
    super.initState();
    _emailShake = _makeShakeCtrl();
    _passShake = _makeShakeCtrl();
    _btnShake = _makeShakeCtrl();
  }

  AnimationController _makeShakeCtrl() => AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  void _shake(AnimationController ctrl) {
    ctrl.forward(from: 0);
  }

  Future<void> _doLogin() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty) { _shake(_emailShake); return; }
    if (pass.isEmpty)  { _shake(_passShake);  return; }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    User? user = await AuthService().login(email, pass);
    if (!mounted) return;
    Navigator.pop(context);

    if (user != null) {
      _emailCtrl.clear(); _passCtrl.clear();
      widget.onSuccess();
    } else {
      _shake(_emailShake);
      _shake(_passShake);
      _shake(_btnShake);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed – check email/password'),
          backgroundColor: Color(0xFFB03060),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _emailFocus.dispose(); _passFocus.dispose();
    _emailShake.dispose(); _passShake.dispose(); _btnShake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox.expand(
      child: Stack(
        children: [
          // Cosmic background — astronaut sits just above the card
          const _CosmicBackground(
            astronautAsset: 'assets/images/sitting.png',
            astronautWidth: 220,
            astronautTopFraction: 0.07,
            astronautAlignment: Alignment.center,
          ),

          // Scrollable so keyboard doesn't bury the fields
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                children: [
                  // Spacer for astronaut area
                  SizedBox(height: size.height * 0.44),

                  // Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
                      decoration: BoxDecoration(
                        color: const Color(0xE6212860),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: const Color(0x335F70DC),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3D4EC8).withValues(alpha: 0.22),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LOG IN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 32),

                          _CosmicField(
                            label: 'E MAIL',
                            hint: 'you@cosmos.io',
                            controller: _emailCtrl,
                            focusNode: _emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            shakeCtrl: _emailShake,
                          ),
                          const SizedBox(height: 18),

                          _CosmicField(
                            label: 'PASSWORD',
                            hint: '••••••••',
                            controller: _passCtrl,
                            focusNode: _passFocus,
                            obscureText: _obscurePass,
                            shakeCtrl: _passShake,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white54,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),

                          const SizedBox(height: 10),


                          const SizedBox(height: 28),

                          Center(
                            child: _ShakeWidget(
                              controller: _btnShake,
                              child: _GlowButton(
                                label: 'LOG IN',
                                onPressed: _doLogin,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms)
                        .slideY(begin: 0.12, end: 0, curve: Curves.easeOutQuart),
                  ),

                  const SizedBox(height: 32),

                  // Comet toggle link — now inside scroll so always reachable
                  _CometLink(
                    text: "DON'T HAVE AN ACCOUNT?",
                    actionText: '  SIGN UP',
                    onTap: widget.onToggle,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SIGN UP PAGE
// ─────────────────────────────────────────────────────────────────────────────
class SignUpPage extends StatefulWidget {
  final VoidCallback onToggle;
  final VoidCallback onSuccess;
  final VoidCallback switchToLogin;

  const SignUpPage({
    super.key,
    required this.onToggle,
    required this.onSuccess,
    required this.switchToLogin,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _nameFocus    = FocusNode();
  final _emailFocus   = FocusNode();
  final _passFocus    = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  late AnimationController _nameShake;
  late AnimationController _emailShake;
  late AnimationController _passShake;
  late AnimationController _confirmShake;
  late AnimationController _btnShake;

  @override
  void initState() {
    super.initState();
    _nameShake    = _makeShake();
    _emailShake   = _makeShake();
    _passShake    = _makeShake();
    _confirmShake = _makeShake();
    _btnShake     = _makeShake();
  }

  AnimationController _makeShake() =>
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  void _shake(AnimationController c) => c.forward(from: 0);

  Future<void> _doSignUp() async {
    final name    = _nameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final pass    = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (name.isEmpty)    { _shake(_nameShake);    return; }
    if (email.isEmpty)   { _shake(_emailShake);   return; }
    if (pass.isEmpty)    { _shake(_passShake);    return; }
    if (confirm.isEmpty) { _shake(_confirmShake); return; }
    if (pass != confirm) {
      _shake(_passShake); _shake(_confirmShake);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }
    if (pass.length < 6) {
      _shake(_passShake);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    User? user = await AuthService().signUp(email, pass);
    if (!mounted) return;
    Navigator.pop(context);

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _nameCtrl.clear(); _emailCtrl.clear();
      _passCtrl.clear(); _confirmCtrl.clear();

      widget.onSuccess();
      if (mounted) widget.switchToLogin();
    } else {
      _shake(_emailShake); _shake(_btnShake);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup failed – email might already exist'),
          backgroundColor: Color(0xFFB03060),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    _nameFocus.dispose(); _emailFocus.dispose();
    _passFocus.dispose(); _confirmFocus.dispose();
    _nameShake.dispose(); _emailShake.dispose();
    _passShake.dispose(); _confirmShake.dispose();
    _btnShake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          const _CosmicBackground(
            astronautAsset: 'assets/images/astronaut_w_phone.png',
            astronautWidth: 180,
            astronautTopFraction: 0.00,
            astronautAlignment: Alignment(0.75, 0),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 220), // space for astronaut

                  const Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      fontFamily: 'Inter',
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 28),

                  _CosmicField(
                    label: 'YOUR NAME',
                    hint: 'e.g., Rio',
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    shakeCtrl: _nameShake,
                  ),
                  const SizedBox(height: 16),

                  _CosmicField(
                    label: 'E MAIL',
                    hint: 'you@cosmos.io',
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    shakeCtrl: _emailShake,
                  ),
                  const SizedBox(height: 16),

                  _CosmicField(
                    label: 'PASSWORD',
                    hint: 'Create a strong password',
                    controller: _passCtrl,
                    focusNode: _passFocus,
                    obscureText: _obscurePass,
                    shakeCtrl: _passShake,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: Colors.white54, size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _CosmicField(
                    label: 'CONFIRM PASSWORD',
                    hint: 'Re-type your password',
                    controller: _confirmCtrl,
                    focusNode: _confirmFocus,
                    obscureText: _obscureConfirm,
                    shakeCtrl: _confirmShake,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: Colors.white54, size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _ShakeWidget(
                    controller: _btnShake,
                    child: _GlowButton(
                      label: 'CREATE ACCOUNT',
                      onPressed: _doSignUp,
                      wide: true,
                    ),
                  ).animate().shimmer(duration: 1500.ms, delay: 600.ms),

                  const SizedBox(height: 28),

                  _CometLink(
                    text: 'ALREADY HAVE AN ACCOUNT?',
                    actionText: '  LOG IN',
                    onTap: widget.onToggle,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _CosmicField — text field with animated focus glow + star burst
// ─────────────────────────────────────────────────────────────────────────────
class _CosmicField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final AnimationController shakeCtrl;

  const _CosmicField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    required this.shakeCtrl,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  State<_CosmicField> createState() => _CosmicFieldState();
}

class _CosmicFieldState extends State<_CosmicField>
    with SingleTickerProviderStateMixin {
  bool _focused = false;

  // Star burst on focus
  late AnimationController _burstCtrl;
  late Animation<double> _burstAnim;

  @override
  void initState() {
    super.initState();
    _burstCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _burstAnim = CurvedAnimation(parent: _burstCtrl, curve: Curves.easeOut);

    widget.focusNode.addListener(() {
      final hasFocus = widget.focusNode.hasFocus;
      setState(() => _focused = hasFocus);
      if (hasFocus) _burstCtrl.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _burstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFFB0B8E8),
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),

        _ShakeWidget(
          controller: widget.shakeCtrl,
          child: AnimatedBuilder(
            animation: _burstAnim,
            builder: (_, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Star burst particles around field on focus
                  if (_focused || _burstCtrl.value > 0)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _StarBurstPainter(progress: _burstAnim.value),
                      ),
                    ),

                  // Field itself
                  child!,
                ],
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: _focused
                    ? [
                  BoxShadow(
                    color: const Color(0xFF7B6FE8).withValues(alpha: 0.50),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFF4B56D2).withValues(alpha: 0.25),
                    blurRadius: 8,
                  ),
                ]
                    : [
                  BoxShadow(
                    color: const Color(0xFF3D4EC8).withValues(alpha: 0.12),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: const Color(0xFF9D8CFF),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: const TextStyle(color: Color(0xFF4A5270), fontSize: 14),
                  filled: true,
                  fillColor: _focused
                      ? const Color(0xFF1A2060)
                      : const Color(0xFF151840),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0x22FFFFFF), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xFF7B6FE8), width: 1.5),
                  ),
                  suffixIcon: widget.suffixIcon,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _GlowButton — gradient pill with glow
// ─────────────────────────────────────────────────────────────────────────────
class _GlowButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool wide;

  const _GlowButton({
    required this.label,
    required this.onPressed,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : 220,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B4FD8), Color(0xFF9D8CFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A5CE8).withValues(alpha: 0.55),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFB090FF).withValues(alpha: 0.18),
            blurRadius: 50,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _CometLink — text link with a comet trailing across on tap
// ─────────────────────────────────────────────────────────────────────────────
class _CometLink extends StatefulWidget {
  final String text;
  final String actionText;
  final VoidCallback onTap;

  const _CometLink({
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  @override
  State<_CometLink> createState() => _CometLinkState();
}

class _CometLinkState extends State<_CometLink>
    with SingleTickerProviderStateMixin {
  late AnimationController _cometCtrl;
  late Animation<double> _cometPos;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _cometCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cometPos = CurvedAnimation(parent: _cometCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _cometCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_running) return;
    _running = true;
    _cometCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 350));
    widget.onTap();
    await _cometCtrl.forward();
    _cometCtrl.reset();
    _running = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _cometPos,
        builder: (_, child) => Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            // Comet streak
            if (_cometCtrl.value > 0)
              Positioned.fill(
                child: CustomPaint(
                  painter: _CometPainter(progress: _cometPos.value),
                ),
              ),
          ],
        ),
        child: Text.rich(
          TextSpan(
            text: widget.text,
            style: const TextStyle(
              color: Color(0xFF8890B8),
              fontSize: 13,
              fontFamily: 'Inter',
              letterSpacing: 0.4,
            ),
            children: [
              TextSpan(
                text: widget.actionText,
                style: const TextStyle(
                  color: Color(0xFF9D8CFF),
                  fontWeight: FontWeight.w700,
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
//  _ShakeWidget — wraps any child and shakes it horizontally on error
// ─────────────────────────────────────────────────────────────────────────────
class _ShakeWidget extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _ShakeWidget({required this.controller, required this.child});

  static double _shakeOffset(double t) {
    // 5 oscillations that decay
    return math.sin(t * math.pi * 5) * 7 * (1 - t);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeOffset(controller.value), 0),
        child: child,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Star field painter (upward drift)
// ─────────────────────────────────────────────────────────────────────────────
class _Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

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
    size: rng.nextDouble() * 1.6 + 0.4,
    speed: rng.nextDouble() * 0.030 + 0.004,
    opacity: rng.nextDouble() * 0.35 + 0.10,
  );
}

class _StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;
  final bool driftUp;

  const _StarFieldPainter({
    required this.stars,
    required this.progress,
    this.driftUp = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      double dy;
      if (driftUp) {
        dy = (s.y - s.speed * progress + 1.0) % 1.0;
      } else {
        dy = (s.y + s.speed * progress) % 1.0;
      }
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: s.opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);
      canvas.drawCircle(
        Offset(s.x * size.width, dy * size.height),
        s.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Star burst painter — radiating sparks on field focus
// ─────────────────────────────────────────────────────────────────────────────
class _StarBurstPainter extends CustomPainter {
  final double progress; // 0→1, fades + expands out

  const _StarBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const spokes = 8;
    final maxR = size.width * 0.60;
    final alpha = (1 - progress) * 0.8;

    for (int i = 0; i < spokes; i++) {
      final angle = (i / spokes) * 2 * math.pi;
      final r = maxR * progress;
      final px = cx + r * math.cos(angle);
      final py = cy + r * math.sin(angle);

      final paint = Paint()
        ..color = const Color(0xFF9D8CFF).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(px, py), 3.5 * (1 - progress * 0.6), paint);

      // Tail line
      final tailPaint = Paint()
        ..color = const Color(0xFF7060E0).withValues(alpha: alpha * 0.55)
        ..strokeWidth = 1.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawLine(
        Offset(cx + r * 0.3 * math.cos(angle), cy + r * 0.3 * math.sin(angle)),
        Offset(px, py),
        tailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarBurstPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Comet painter — streaks across the text widget on tap
// ─────────────────────────────────────────────────────────────────────────────
class _CometPainter extends CustomPainter {
  final double progress; // 0→1

  const _CometPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final x = size.width * progress;
    final y = size.height * 0.5;

    // Glowing head
    final headPaint = Paint()
      ..color = const Color(0xFFE8D8FF).withValues(alpha: (1 - progress) * 0.95)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(x, y), 4, headPaint);

    // Tail using a gradient path
    final tailLen = size.width * 0.28 * (1 - progress * 0.4);
    final shader = LinearGradient(
      colors: [
        const Color(0xFFB090FF).withValues(alpha: (1 - progress) * 0.7),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(x - tailLen, y - 2, tailLen, 4));

    final tailPaint = Paint()
      ..shader = shader
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(x - tailLen, y), Offset(x, y), tailPaint);

    // Tiny sparkles around head
    final rng = math.Random(42);
    for (int i = 0; i < 5; i++) {
      final sx = x + (rng.nextDouble() - 0.5) * 14;
      final sy = y + (rng.nextDouble() - 0.5) * 8;
      final sp = Paint()
        ..color = Colors.white.withValues(alpha: (1 - progress) * 0.55);
      canvas.drawCircle(Offset(sx, sy), 1.2, sp);
    }
  }

  @override
  bool shouldRepaint(_CometPainter old) => old.progress != progress;
}