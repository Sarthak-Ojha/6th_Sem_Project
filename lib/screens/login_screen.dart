// lib/screens/login_screen.dart
// (This is a basic template. You can style it as you like.)

import 'package:flutter/material.dart';
// ... import your AuthService and other necessary files

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Add controllers for text fields, etc.
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your Email and Password TextFields go here
            // Your Login Button goes here
            // Your Google Sign-In Button goes here

            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to the signup screen
                Navigator.of(context).pushNamed('/signup');
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
