import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/home_page.dart';
import 'package:project/splash_screen.dart';
import 'firebase_options.dart';  // This file was just created!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Important line!

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citizen Stargazer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A0E1A),  // Deep space blue base
          brightness: Brightness.dark,  // Dark mode everywhere—no light flashes
        ),
        useMaterial3: true,  // Modern rounded buttons/gradients (matches your Figma)
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),  // Default bg for any blank spots
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1F2E),  // Subtle blue for future bars
          foregroundColor: Colors.white,  // White icons/text
        ),
      ),
      home: const SplashWidget(), // Or whatever your first auth screen is
      routes: {  // Easy jumps (bonus—your Auth uses pushReplacement to /home)
        '/home': (context) => const HomeScreen(),
      },
      // Your routes or navigator here
    );
  }
}