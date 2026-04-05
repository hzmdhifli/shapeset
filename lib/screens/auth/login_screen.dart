import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'widgets/social_button.dart';
import 'signup_screen.dart';
import '../../main.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
              const SizedBox(height: 36),
              Text(
                'WELCOME\nBACK',
                style: GoogleFonts.bebasNeue(
                  fontSize: 36,
                  letterSpacing: 3,
                  height: 1,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to continue your training journey.',
                style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.65),
              ),
              const SizedBox(height: 48),
              
              // Social Login
              SocialButton(
                icon: Image.asset('assets/images/gmail-logo.png', height: 24),
                label: 'Sign in with Google',
                onTap: _handleGoogleLogin,
                iconBackgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),
              
              const Center(
                child: Text(
                  'Your progress will be automatically saved to your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.dim, fontSize: 12, height: 1.5),
                ),
              ),
              
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SignupScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                      children: [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(text: 'Sign up free', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Security Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface2.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: AppColors.gold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'SECURE ACCESS',
                            style: TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'We use industry-standard encryption to protect your data.',
                            style: TextStyle(color: AppColors.muted, fontSize: 10, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.arrow_back, color: AppColors.muted, size: 16),
            SizedBox(width: 8),
            Text('Back', style: TextStyle(color: AppColors.muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (error) {
      debugPrint('Google login error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${error.toString()}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
