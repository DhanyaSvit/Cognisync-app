import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // make sure this path is correct

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user = await AuthService().signInWithGoogle();
            if (user != null) {
              // Navigate to home screen or show success
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Welcome ${user.displayName}!')),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Sign in failed')));
              }
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
