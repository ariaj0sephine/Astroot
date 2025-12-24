// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'services/auth_services.dart';     // Your AuthService file
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // NEW: For optional name save

// Import your HomeScreen (adjust path if needed)
import 'home_page.dart'; // Change if your home file is named differently

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // true = Login, false = Sign Up

  void toggle() {
    setState(() => isLogin = !isLogin);
  }

  // Go to Home after success
  void goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: isLogin
            ? LoginPage(onToggle: toggle, onSuccess: goToHome)
            : SignUpPage(onToggle: toggle, onSuccess: goToHome, switchToLogin: toggle),
      ),
    );
  }
}

// ====================== LOGIN PAGE ======================
class LoginPage extends StatefulWidget {
  final VoidCallback onToggle;
  final VoidCallback onSuccess;

  const LoginPage({super.key, required this.onToggle, required this.onSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.15, 0.77),
          end: Alignment(-0.77, -0.73),
          colors: [Color(0xFF00132D), Color(0xFF001E45), Color(0xFF002657)],
        ),
      ),
      child: Stack(
        children: [
          // Astronaut + circles (unchanged – perfect!)
          Positioned(
            top: -50,
            left: -20,
            child: SizedBox(
              width: 400,
              height: 500,
              child: Stack(
                children: [
                  Center(
                    child: Image.asset('assets/images/sitting.png', width: 280, fit: BoxFit.contain),
                  ),
                  Positioned(
                    top: 140,
                    right: 40,
                    child: Container(
                      width: 43,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A2B5C),
                        borderRadius: BorderRadius.all(Radius.elliptical(43, 40)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: 10,
                    child: Container(
                      width: 50,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xFF313E84),
                        borderRadius: BorderRadius.all(Radius.elliptical(50, 46)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Login Card (unchanged layout)
          Positioned(
            top: 360,
            left: 36,
            right: 36,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
              decoration: BoxDecoration(
                color: const Color(0xFF333976),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LOG IN', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                  const SizedBox(height: 40),

                  const Text('E MAIL', style: TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Color(0xFF6A788B)),
                    decoration: InputDecoration(
                      hintText: 'Example@gmail.com',
                      hintStyle: const TextStyle(color: Color(0xFF6A788B), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF333976),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('PASSWORD', style: TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Color(0xFF6A788B)),
                    decoration: InputDecoration(
                      hintText: 'Example_1',
                      hintStyle: const TextStyle(color: Color(0xFF6A788B), fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF333976),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('FORGOT PASSWORD ?', style: TextStyle(color: Color(0xFF6A788B), fontSize: 12)),
                  ),

                  const SizedBox(height: 30),

                  // Login Button (UPDATED with better feedback)
                  Center(
                    child: Container(
                      width: 220,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(colors: [Color(0xFF333976), Color(0xFF5F6ADC)]),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          String email = emailController.text.trim();
                          String password = passwordController.text;

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill email and password')),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          );

                          User? user = await AuthService().login(email, password);

                          Navigator.pop(context); // Hide loading

                          if (user != null) {
                            widget.onSuccess(); // Go to Home
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Login successful! Welcome back 🌟'),
                                backgroundColor: Color(0xFF4CAF50),
                              ),
                            );
                            emailController.clear();
                            passwordController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Login failed – check email/password'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        child: const Text('LOG IN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom "Sign Up" link
          Positioned(
            bottom: 35,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: widget.onToggle,
                child: const Text(
                  "DON'T HAVE AN ACCOUNT? SIGN UP",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

// ====================== SIGN UP PAGE ======================
class SignUpPage extends StatefulWidget {
  final VoidCallback onToggle;
  final VoidCallback onSuccess;
  final VoidCallback switchToLogin; // NEW: To flip back after success

  const SignUpPage({super.key, required this.onToggle, required this.onSuccess, required this.switchToLogin});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true; // NEW: Independent toggle for confirm field

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.15, 0.77),
          end: Alignment(-0.77, -0.73),
          colors: [Color(0xFF00132D), Color(0xFF001E45), Color(0xFF002657)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Astronaut (unchanged)
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -30,
                    right: 20,
                    child: Container(width: 80, height: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0B274C))),
                  ),
                  Image.asset('assets/images/astronaut_w_phone.png', width: 180, fit: BoxFit.contain),
                ],
              ),

              const SizedBox(height: 30),
              const Text('SIGN UP', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.normal, fontFamily: 'Inter')),

              const SizedBox(height: 30),

              _buildField(label: 'YOUR NAME', hint: 'e.g., Rio', controller: nameController),
              const SizedBox(height: 20),
              _buildField(label: 'E MAIL', hint: 'Example@gmail.com', controller: emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),

              // Password with toggle
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  hintText: 'Create a strong password',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF333976),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // Confirm Password with own toggle
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirm,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'CONFIRM PASSWORD',
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  hintText: 'Re-type your password',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF333976),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    String name = nameController.text.trim();
                    String email = emailController.text.trim();
                    String password = passwordController.text;
                    String confirm = confirmPasswordController.text;

                    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    if (password != confirm) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match!')),
                      );
                      return;
                    }
                    if (password.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password must be at least 6 characters')),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );

                    User? user = await AuthService().signUp(email, password);

                    Navigator.pop(context); // Hide loading

                    if (user != null) {
                      // OPTIONAL: Save name to Firestore (nice touch!)
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                        'name': name,
                        'email': email,
                        'createdAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));

                      widget.onSuccess(); // Go to Home
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account created! Welcome to the stars 🌌'),
                          backgroundColor: Color(0xFF4CAF50),
                        ),
                      );

                      // Clear fields and switch to Login
                      nameController.clear();
                      emailController.clear();
                      passwordController.clear();
                      confirmPasswordController.clear();
                      widget.switchToLogin(); // Auto flip back
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Signup failed – email might already exist'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5F6ADC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: widget.onToggle,
                child: const Text.rich(
                  TextSpan(
                    text: 'ALREADY HAVE AN ACCOUNT? ',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    children: [TextSpan(text: 'LOG IN', style: TextStyle(color: Color(0xFF9D8CFF), fontWeight: FontWeight.bold))],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF333976),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}