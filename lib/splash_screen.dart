import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(0, 19, 45, 1),
              Color.fromRGBO(0, 19, 46, 1),
              Color.fromRGBO(0, 30, 69, 1),
              Color.fromRGBO(0, 38, 87, 1),
            ],
            stops: [0.00, 0.15, 0.54, 0.93],
          ),
        ),
        child: Stack(
          children: [
            // Astronaut in the center
            Center(
              child: Container(
                width: 195,
                height: 195,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/icon_2.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Only ASTROOT text at the bottom (caption removed)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.19),
                child: const Text(
                  'ASTROOT',
                  style: TextStyle(
                    fontFamily: 'FunkieRetro',
                    fontSize: 58,
                    color: Color.fromRGBO(165, 157, 172, 0.9),
                    letterSpacing: 2,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}