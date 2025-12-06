import 'package:flutter/material.dart';
import 'splash_screen.dart';  // Your splash file (with the timer now).

void main() {
  runApp(const MyApp());  // Starts your app.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  // Modern way to handle keys (super safe).

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // Hides the "DEBUG" tag—looks pro.
      title: 'Citizen Stargazer Assistant',  // Full app name (shows in app switcher; matches your PPT).
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: MaterialColor(0xFF082857, const <int, Color>{
          50: Color(0xFF082857),  // Light variant (for backgrounds).
          100: Color(0xFF082857),
          200: Color(0xFF082857),
          300: Color(0xFF082857),
          400: Color(0xFF082857),
          500: Color(0xFF082857),  // Main color—your splash blue.
          600: Color(0xFF082857),
          700: Color(0xFF082857),
          800: Color(0xFF082857),
          900: Color(0xFF082857),  // Dark variant (for text/icons).
        }),
      ),
      home: const SplashWidget(),  // Starts with your splash (now with auto-nav).
      // Future-proof: Add routes here later, e.g., routes: {'/snap': (context) => SnapTab(),},
    );
  }
}