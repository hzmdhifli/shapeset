import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && mounted) {
      // If already logged in, skip splash buttons and go home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Decorative Rings
          _buildRing(context, 500, 0.04),
          _buildRing(context, 340, 0.06),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                Text(
                  'ATHLÈTE',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 52,
                    letterSpacing: 6,
                    color: AppColors.gold,
                  ),
                ),
                Text(
                  'TRAIN LIKE A LEGEND',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.muted,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 2),
                _buildButtons(context),
                const SizedBox(height: 20),
                const Text.rich(
                  TextSpan(
                    style: TextStyle(color: AppColors.dim, fontSize: 10, height: 1.6),
                    children: [
                      TextSpan(text: 'By continuing you agree to our '),
                      TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.muted, decoration: TextDecoration.underline)),
                      TextSpan(text: '\nand '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.muted, decoration: TextDecoration.underline)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
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

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text(
              'GET STARTED →',
              style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 0),
            ),
            child: const Text(
              'LOG IN',
              style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3, color: AppColors.text),
            ),
          ),
        ),
      ],
    );
  }
}
