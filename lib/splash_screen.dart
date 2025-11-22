import 'package:flutter/material.dart';

class SplashWidget extends StatelessWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.15, 0.79),
            end: Alignment(-0.35, -0.34),
            colors: [
              Color.fromRGBO(0, 19, 45, 1),
              Color.fromRGBO(0, 19, 46, 1),
              Color.fromRGBO(0, 30, 69, 1),
              Color.fromRGBO(0, 38, 87, 1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Astronaut image (centered)
            Center(
              child: Container(
                width: 195,
                height: 195,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/icon.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Caption on top + ASTROOT below it
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.19),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    // ← CAPTION FIRST (now on top)
                    Text(
                      'all the dreams are like twinkle stars',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'FunkieRetro',
                        fontSize: 17.5,
                        color: Color.fromRGBO(165, 157, 172, 0.9),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 10),

                    // ← ASTROOT SECOND (now below)
                    Text(
                      'ASTROOT',
                      style: TextStyle(
                        fontFamily: 'FunkieRetro',
                        fontSize: 58,
                        color: Color.fromRGBO(165, 157, 172, 0.9),
                        letterSpacing: 2,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}