// lib/screens/verify_email_screen.dart
import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();
  bool _isEmailSent = false;
  bool _isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Send the verification email as soon as the screen loads
    _sendVerificationEmail();

    // Start a timer to automatically check if the email has been verified
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel(); // Stop the timer
        // The AuthWrapper's stream will automatically navigate to the HomeScreen
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important: cancel the timer when the screen is disposed
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() => _isLoading = true);
    try {
      await _authService.sendVerificationEmail();
      setState(() => _isEmailSent = true);
      // GUARD THE CONTEXT with a 'mounted' check
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
      }
    } catch (e) {
      // GUARD THE CONTEXT with a 'mounted' check
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              _timer?.cancel(); // Stop timer before signing out
              _authService.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.indigo),
              const SizedBox(height: 20),
              Text(
                'A verification link has been sent to your email address. Please check your inbox (and spam folder) and click the link to continue.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _sendVerificationEmail,
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isEmailSent
                        ? 'Resend Email'
                        : 'Send Verification Email'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Checking for verification automatically...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
