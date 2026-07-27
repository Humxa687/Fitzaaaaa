import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import 'dart:async';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoggingIn = false;
  bool _isPhoneMode = false;
  bool _otpSent = false;
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  void _handleGoogleSignIn() async {
    setState(() => _isLoggingIn = true);
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    // Real implementation would use GoogleSignIn() here.
    // We mock it for now since Firebase isn't set up yet.
    await Future.delayed(const Duration(seconds: 2));
    await provider.loginWithGoogle("Google User", "user@gmail.com");
    if (mounted) {
      setState(() => _isLoggingIn = false);
    }
  }

  void _sendOtp() async {
    if (_phoneController.text.trim().length < 10) return;
    setState(() => _isLoggingIn = true);
    // Mock sending OTP
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoggingIn = false;
      _otpSent = true;
    });
  }

  void _verifyOtp() async {
    if (_otpController.text.trim().length != 6) return;
    setState(() => _isLoggingIn = true);
    final provider = Provider.of<FitnessProvider>(context, listen: false);
    
    // Mock verification
    await Future.delayed(const Duration(seconds: 2));
    // Since we don't have a specific phone login method yet, we use a mocked google one to simulate login success
    await provider.loginWithGoogle("Phone User", "phone_${_phoneController.text}@fitza.com");
    
    if (mounted) {
      setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: theme.brightness == Brightness.dark
                    ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B), const Color(0xFF020617)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0), const Color(0xFFEEF2F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Glowing background circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.25),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.2, duration: 3.seconds),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.2),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 0.9, end: 1.15, duration: 4.seconds),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Modern 3D Logo Container
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.45),
                            blurRadius: 30,
                            spreadRadius: 4,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: FitzaTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(Icons.fitness_center_rounded, size: 55, color: Colors.white),
                          ),
                        ),
                      ),
                    ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 24),

                    // App Title & Tagline
                    Text(
                      "FITZA",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        fontSize: 34,
                        color: theme.colorScheme.primary,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 6),

                    Text(
                      "Next-Gen AI Fitness Experience",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Authentication Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.07)
                                : Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.12)
                                  : Colors.black.withOpacity(0.08),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isPhoneMode 
                                    ? (_otpSent ? "Verify OTP" : "Phone Login")
                                    : "Welcome to Fitza",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isPhoneMode 
                                    ? (_otpSent ? "Enter the 6-digit code sent to ${_phoneController.text}" : "We will send a 6-digit verification code to your number.")
                                    : "Sign in to access your AI personalized fitness journey.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              if (!_isPhoneMode) ...[
                                // Google Sign-In Button
                                _buildButton(
                                  label: "Continue with Google",
                                  iconUrl: "https://img.icons8.com/color/48/000000/google-logo.png",
                                  isLoading: _isLoggingIn,
                                  onPressed: _handleGoogleSignIn,
                                  theme: theme,
                                ),
                                const SizedBox(height: 16),
                                
                                // Phone Sign-In Button
                                _buildButton(
                                  label: "Continue with Phone",
                                  iconData: Icons.phone_android_rounded,
                                  isLoading: false,
                                  onPressed: () => setState(() => _isPhoneMode = true),
                                  theme: theme,
                                ),
                              ] else if (!_otpSent) ...[
                                // Phone Number Input
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: "+1 234 567 8900",
                                    prefixIcon: const Icon(Icons.phone),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildButton(
                                  label: "Send OTP",
                                  iconData: Icons.send_rounded,
                                  isLoading: _isLoggingIn,
                                  onPressed: _sendOtp,
                                  theme: theme,
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => setState(() => _isPhoneMode = false),
                                  child: const Text("Back to options"),
                                )
                              ] else ...[
                                // OTP Input
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    hintText: "------",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildButton(
                                  label: "Verify & Login",
                                  iconData: Icons.check_circle_rounded,
                                  isLoading: _isLoggingIn,
                                  onPressed: _verifyOtp,
                                  theme: theme,
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => setState(() => _otpSent = false),
                                  child: const Text("Change Phone Number"),
                                )
                              ],
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
    required ThemeData theme,
    String? iconUrl,
    IconData? iconData,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 4,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Please wait...",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconUrl != null)
                  Image.network(
                    iconUrl,
                    height: 24,
                    errorBuilder: (_, __, ___) => const Icon(Icons.account_circle, color: Colors.blue, size: 24),
                  )
                else if (iconData != null)
                  Icon(iconData, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
    );
  }
}
