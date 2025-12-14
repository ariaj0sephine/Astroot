import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashWidget(),  // Or whatever your first auth screen is
      // Your routes or navigator here
    );
  }
}