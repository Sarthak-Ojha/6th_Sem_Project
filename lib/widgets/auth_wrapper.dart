// lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import '../screens/signin_screen.dart'; // CHANGED: Import SigninScreen instead of LoginScreen
import '../screens/verify_email_screen.dart';
import '../screens/splash_screen.dart'; // ADDED: Import SplashScreen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading/splash screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // CHANGED: Use SplashScreen instead of basic loading
        }
        // Handle stream errors
        else if (snapshot.hasError) {
          return ErrorScreen(
            title: 'Authentication Error',
            message: 'Something went wrong with authentication.',
            error: snapshot.error.toString(),
            onRetry: () {
              // Trigger a rebuild by creating a new stream
              FirebaseAuth.instance.authStateChanges();
            },
          );
        }
        // If user is logged in
        else if (snapshot.hasData) {
          final user = snapshot.data!;
          // Check if email is verified
          if (user.emailVerified) {
            return const HomeScreen(); // ADDED: const
          } else {
            // Show email verification screen
            return const VerifyEmailScreen(); // ADDED: const
          }
        }
        // If user is not logged in
        else {
          // Send them to the signin screen - UPDATED
          return const SigninScreen(); // CHANGED: Use SigninScreen instead of LoginScreen
        }
      },
    );
  }
}

// Enhanced Error Screen
class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final String error;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Error Details (collapsible)
                ExpansionTile(
                  title: const Text('Error Details'),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        error,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Retry Button
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
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
