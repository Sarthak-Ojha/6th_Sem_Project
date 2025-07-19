import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum AuthMode { signIn, signUp }

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.signIn;
  String _email = '';
  String _password = '';
  String _error = '';
  bool _isLoading = false;

  void _switchMode() {
    setState(() {
      _authMode = _authMode == AuthMode.signIn
          ? AuthMode.signUp
          : AuthMode.signIn;
      _error = '';
    });
  }

  Future<void> _submit() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      if (_authMode == AuthMode.signIn) {
        await auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await auth.signUpWithEmailAndPassword(_email, _password);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
          ),
        );
      }
      // Optionally: Navigate to home/main screen on sign in/up
      // if (!mounted) return;
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignIn() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      await auth.signInWithGoogle();
      // Optionally: Navigate to home/main screen
      // if (!mounted) return;
      // Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    if (_email.isEmpty) {
      setState(() => _error = 'Enter your email to reset password.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      await auth.resetPassword(_email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignIn = _authMode == AuthMode.signIn;
    return Scaffold(
      appBar: AppBar(title: Text(isSignIn ? 'Sign In' : 'Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextFormField(
                      key: const ValueKey('email'),
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) => _email = value!.trim(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !value.contains('@')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('password'),
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (value) => _password = value!,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submit,
                            child: Text(isSignIn ? 'Sign In' : 'Sign Up'),
                          ),
                    TextButton(
                      onPressed: _switchMode,
                      child: Text(
                        isSignIn
                            ? 'Don\'t have an account? Sign up'
                            : 'Already have an account? Sign in',
                      ),
                    ),
                    if (isSignIn)
                      TextButton(
                        onPressed: _forgotPassword,
                        child: const Text('Forgot Password?'),
                      ),
                    const SizedBox(height: 12),
                    const Divider(),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        label: const Text('Sign in with Google'),
                        onPressed: _isLoading ? null : _googleSignIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
