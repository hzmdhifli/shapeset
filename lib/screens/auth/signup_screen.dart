import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'widgets/social_button.dart';
import 'login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
                'CREATE YOUR\nACCOUNT',
                style: GoogleFonts.bebasNeue(
                  fontSize: 36,
                  letterSpacing: 3,
                  height: 1,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Join thousands of athletes training with the world\'s best programs.',
                style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.65),
              ),
              const SizedBox(height: 48),
              
              // Social Signup
              SocialButton(
                icon: Image.asset('assets/images/gmail-logo.png', height: 24),
                label: 'Sign in with Google',
                onTap: _handleGoogleSignup,
                iconBackgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 20),
              
              const Center(
                child: Text(
                  'Your name, email, and profile photo will be automatically synced from your Google account.',
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
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                      children: [
                        TextSpan(text: "Already have an account? "),
                        TextSpan(text: 'Sign in', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Points Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppColors.gold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'GET STARTED FAST',
                            style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'One-tap login means you can start your first workout in less than 30 seconds.',
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

  Widget _buildRing(BuildContext context, double size, double opacity) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.45 - (size / 2),
      left: MediaQuery.of(context).size.width * 0.5 - (size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold.withOpacity(opacity)),
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

  Future<void> _handleGoogleSignup() async {
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (error) {
      debugPrint('Google signup error: $error');
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
