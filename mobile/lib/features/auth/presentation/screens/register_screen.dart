import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// RegisterScreen now redirects to WelcomeScreen which contains
/// the integrated login/register forms in a Bottom Sheet.
/// This screen is kept for backward compatibility with routes.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to welcome screen with register mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/welcome?mode=register');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while redirecting
    return const Scaffold(
      backgroundColor: Color(0xFF16213e),
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}



