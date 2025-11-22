import 'package:flutter/material.dart';
import 'splash_screen.dart'; // make sure this file contains the code from the plugin

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CSA',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: SplashWidget(),
      // If you add more pages later, you can define routes here.
    );
  }
}