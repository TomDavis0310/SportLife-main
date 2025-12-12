import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// LoginScreen now redirects to WelcomeScreen which contains
/// the integrated login/register forms in a Bottom Sheet.
/// This screen is kept for backward compatibility with routes.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to welcome screen with login mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/welcome?mode=login');
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
