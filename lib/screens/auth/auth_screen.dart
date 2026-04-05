import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../onboarding/onboarding_screen.dart';
import 'widgets/social_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleAuth() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null && mounted) {
        // Decide if we should go to Onboarding or Main screen.
        // For now, let's go to MainScreen for sign-in or Onboarding for first-time.
        // Usually, signs lead to MainScreen and registration to Onboarding,
        // but with Google it can be both.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Auth error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ATHLÈTE',
                style: GoogleFonts.bebasNeue(
                  fontSize: 52,
                  letterSpacing: 6,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'TRAIN LIKE A LEGEND',
                style: TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 2),
              ),
              const SizedBox(height: 60),
              SocialButton(
                icon: Image.asset('assets/images/gmail-logo.png', height: 24),
                label: 'Sign in with Google',
                onTap: _handleGoogleAuth,
                iconBackgroundColor: Colors.transparent,
              ),
              if (_isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(color: AppColors.gold),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
