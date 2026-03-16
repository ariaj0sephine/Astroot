import 'package:flutter/material.dart';
import 'home_page.dart';
import 'auth_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.15, 0.77),
            end: Alignment(-0.77, -0.73),
            colors: [
              Color.fromRGBO(0, 19, 45, 1),
              Color.fromRGBO(0, 30, 69, 1),
              Color.fromRGBO(0, 38, 87, 1),
            ],
          ),
        ),
        child: Stack(
          children: [

            // ── Large soft glow circle behind astronaut ──
            Positioned(
              top: screenHeight * 0.04,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: screenWidth * 0.82,
                  height: screenWidth * 0.82,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(120, 90, 200, 0.22),
                  ),
                ),
              ),
            ),

            // ── Top-left floating small bubbles ──
            Positioned(
              top: screenHeight * 0.08,
              left: screenWidth * 0.10,
              child: _bubble(14, const Color.fromRGBO(110, 120, 190, 0.55)),
            ),
            Positioned(
              top: screenHeight * 0.14,
              left: screenWidth * 0.06,
              child: _bubble(10, const Color.fromRGBO(110, 120, 190, 0.45)),
            ),

            // ── Astronaut — centered horizontally, upper half ──
            Positioned(
              top: screenHeight * 0.04,
              left: screenWidth * 0.10,
              right: screenWidth * 0.10,
              child: SizedBox(
                height: screenHeight * 0.55,
                child: Image.asset(
                  'assets/images/astronaut.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ── Large decorative bubble bottom-left (behind title) ──
            Positioned(
              top: screenHeight * 0.54,
              left: -screenWidth * 0.10,
              child: _bubble(
                screenWidth * 0.48,
                const Color.fromRGBO(140, 100, 220, 0.18),
              ),
            ),

            // ── Two small accent bubbles near title ──
            Positioned(
              top: screenHeight * 0.70,
              left: screenWidth * 0.38,
              child: _bubble(20, const Color.fromRGBO(160, 120, 240, 0.30)),
            ),
            Positioned(
              top: screenHeight * 0.76,
              left: screenWidth * 0.06,
              child: _bubble(14, const Color.fromRGBO(130, 100, 200, 0.25)),
            ),

            // ── Title — bottom-left, matching screenshot ──
            Positioned(
              top: screenHeight * 0.58,
              left: screenWidth * 0.06,
              right: screenWidth * 0.06,
              child: const Text(
                'EXPLORE THE\nUNKNOWN.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // ── GET STARTED button ──
            Positioned(
              bottom: screenHeight * 0.09,
              left: screenWidth * 0.22,
              right: screenWidth * 0.22,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AuthScreen(),
                    ),
                  );
                },
                child: Container(
                  height: screenHeight * 0.068,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color.fromRGBO(140, 100, 240, 1),
                        Color.fromRGBO(200, 140, 255, 1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.5),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'GET STARTED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}