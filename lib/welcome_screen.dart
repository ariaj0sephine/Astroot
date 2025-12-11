import 'package:flutter/material.dart';
import 'home_screen.dart'; // Your main screen (unchanged)

// This line brings in your combined Login + Sign Up page
import 'auth_screen.dart'; // ← Make sure auth_screen.dart is in the same folder as this file

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

            // Top-left floating bubbles (exact match)
            Positioned(
              top: screenHeight * 0.08,
              left: screenWidth * 0.23,
              child: _bubble(26, const Color.fromRGBO(90, 100, 160, 0.55)),
            ),
            Positioned(
              top: screenHeight * 0.13,
              left: screenWidth * 0.16,
              child: _bubble(18, const Color.fromRGBO(110, 120, 190, 0.45)),
            ),
            Positioned(
              top: screenHeight * 0.20,
              left: screenWidth * 0.23,
              child: _bubble(22, const Color.fromRGBO(80, 90, 150, 0.65)),
            ),

            // Large soft circle behind astronaut (perfect size & opacity)
            Positioned(
              top: screenHeight * 0.06,
              left: screenWidth * 0.25,
              child: Container(
                width: screenWidth * 0.88,
                height: screenHeight * 0.50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromRGBO(120, 90, 200, 0.22),
                ),
              ),
            ),

            // Astronaut - perfectly centered and sized
            Positioned(
              top: screenHeight * 0.03,
              left: screenWidth * 0.19,
              child: SizedBox(
                width: screenWidth * 0.74,
                height: screenHeight * 0.60,
                child: Image.asset(
                  'assets/images/astronaut.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 3 Bubbles behind the text (1 big + 2 small) - EXACTLY like your screenshot
            Positioned(
              top: screenHeight * 0.55,
              left: screenWidth * 0.02,
              child: _bubble(screenWidth * 0.42, const Color.fromRGBO(140, 100, 220, 0.18)), // Large one
            ),
            Positioned(
              top: screenHeight * 0.69,
              right: screenWidth * 0.28,
              child: _bubble(32, const Color.fromRGBO(160, 120, 240, 0.25)),
            ),
            Positioned(
              top: screenHeight * 0.75,
              left: screenWidth * 0.08,
              child: _bubble(24, const Color.fromRGBO(130, 100, 200, 0.20)),
            ),

            // Title - Left aligned, perfect font & spacing
            Positioned(
              top: screenHeight * 0.60,
              left: screenWidth * 0.14,
              right: screenWidth * 0.14,
              child: const Text(
                'EXPLORE THE\nUNKNOWN.',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            // GET STARTED Button - NOW OPENS LOGIN/SIGNUP (visuals unchanged)
            Positioned(
              bottom: screenHeight * 0.09,
              left: screenWidth * 0.22,
              right: screenWidth * 0.22,
              child: GestureDetector(
                onTap: () {
                  // This opens your combined Login/Sign Up screen
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
                        color: Colors.purple.withValues(alpha: 0.5), // Updated for modern Flutter
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

            // Bottom text - "SIGN UP" now opens Login/Sign Up screen too
            // Positioned(
            //   bottom: screenHeight * 0.07,
            //   left: 0,
            //   right: 0,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       const Text(
            //         "DON'T HAVE AN ACCOUNT? ",
            //         style: TextStyle(
            //           color: Colors.white70,
            //           fontSize: 13.5,
            //           fontWeight: FontWeight.w500,
            //         ),
            //       ),
            //       GestureDetector(
            //         onTap: () {
            //           // This also opens your combined Login/Sign Up screen
            //           Navigator.of(context).push(
            //             MaterialPageRoute(
            //               builder: (_) => const AuthScreen(),
            //             ),
            //           );
            //         },
            //         child: const Text(
            //           'SIGN UP',
            //           style: TextStyle(
            //             color: Color.fromRGBO(220, 160, 255, 1),
            //             fontSize: 13.5,
            //             fontWeight: FontWeight.bold,
            //             decoration: TextDecoration.underline,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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