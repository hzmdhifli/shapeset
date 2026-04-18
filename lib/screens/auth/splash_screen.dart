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

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      // Safe image precaching
      if (mounted) {
        precacheImage(const AssetImage('assets/images/widgi.png'), context).catchError((_) {});
        precacheImage(const AssetImage('assets/images/whito.png'), context).catchError((_) {});
      }

      // Ensure the animation has time to at least show the logo
      await Future.delayed(const Duration(milliseconds: 1500));

      if (isLoggedIn && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error in splash screen check: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Glow
          _buildBackgroundEffects(),
          
          // Animated Content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/widgi.png',
                          height: 140,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Text(
                            'SHAPESET',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 64,
                              letterSpacing: 8,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'TRAIN LIKE A LEGEND',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.gold.withOpacity(0.7),
                            letterSpacing: 4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_isLoading) ...[
                          const SizedBox(height: 60),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.gold,
                              strokeWidth: 2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Action Buttons (shown only after loading)
          if (!_isLoading)
            Positioned(
              bottom: 40,
              left: 32,
              right: 32,
              child: FadeTransition(
                opacity: AlwaysStoppedAnimation(1.0),
                child: _buildWelcomeContent(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: _buildGlowSphere(300, AppColors.gold.withOpacity(0.05)),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: _buildGlowSphere(400, AppColors.gold.withOpacity(0.03)),
        ),
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(0.03),
                  Colors.transparent,
                ],
                radius: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlowSphere(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'GET STARTED →',
              style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 18, letterSpacing: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
              foregroundColor: AppColors.text,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'LOG IN',
              style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 18, letterSpacing: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'By continuing you agree to our Terms and Privacy Policy',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted.withOpacity(0.5), fontSize: 11),
        ),
      ],
    );
  }
}

