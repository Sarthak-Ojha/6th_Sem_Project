// lib/screens/splash_screen.dart
// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/auth_wrapper.dart'; // Ensure you have this wrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Controls the fade-in animation
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start the navigation timer and the fade-in animation
    _startSplash();
  }

  void _startSplash() async {
    // Trigger the fade-in animation shortly after the widget builds
    Timer(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Wait for 3 seconds on the splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Navigate to the AuthWrapper, which will handle auth state
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Use a gradient for a visually appealing background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          // AnimatedOpacity provides a smooth fade-in effect
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 2),
            curve: Curves.easeIn,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
                const Icon(
                  Icons.quiz_rounded,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                // App Name
                Text(
                  'Quiz App',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
