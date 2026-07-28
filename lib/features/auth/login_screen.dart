import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import 'phone_verification_modal.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;

  void _handleGoogleSignIn(FitnessProvider provider) async {
    setState(() => _isLoggingIn = true);
    await provider.loginWithGoogle("Google User", "user@gmail.com");
    if (mounted) {
      setState(() => _isLoggingIn = false);
    }
  }

  void _handlePhoneSignIn() {
    PhoneVerificationModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FitnessProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFF3F6FA),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Minimalist background circles
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withValues(alpha: 0.1),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // New Minimalist Logo Container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Icon(Icons.fitness_center_rounded, size: 60, color: Colors.blue.shade400),
                          ),
                        ),
                      ),
                    ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 600.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 28),

                    // App Title
                    Text(
                      "FITZA",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3.0,
                        fontSize: 36,
                        color: Colors.blue.shade600,
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 8),

                    Text(
                      "Next-Gen AI Fitness Experience",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 50),

                    // White Login Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 30,
                            spreadRadius: 0,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Welcome to Fitza",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Sign in to access your AI\npersonalized fitness journey.",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // Google Sign-In Button
                          ElevatedButton(
                            onPressed: _isLoggingIn ? null : () => _handleGoogleSignIn(provider),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.white,
                              foregroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200,
                                ),
                              ),
                            ),
                            child: _isLoggingIn
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.blue.shade600),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        "https://img.icons8.com/color/48/000000/google-logo.png",
                                        height: 22,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.account_circle, color: Colors.blue, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      const Text(
                                        "Continue with Google",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),

                          const SizedBox(height: 16),

                          // Phone Sign-In Button
                          ElevatedButton(
                            onPressed: _isLoggingIn ? null : _handlePhoneSignIn,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.white,
                              foregroundColor: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.brightness == Brightness.dark ? Colors.white12 : Colors.grey.shade200,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone_android_rounded, size: 22, color: Colors.blue.shade500),
                                const SizedBox(width: 14),
                                const Text(
                                  "Continue with Phone",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
