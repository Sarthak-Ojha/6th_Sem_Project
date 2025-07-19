// lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/verify_email_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // If the user is logged in
        else if (snapshot.hasData) {
          final user = snapshot.data!;
          // Check if their email is verified
          if (user.emailVerified) {
            return const HomeScreen();
          } else {
            // If not verified, send them to the verification screen
            return const VerifyEmailScreen();
          }
        }
        // If the user is logged out
        else {
          // Send them to the login screen
          return const LoginScreen();
        }
      },
    );
  }
}
