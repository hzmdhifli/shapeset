import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/social_button.dart';
import 'login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/localization_service.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBackButton(context),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/widgi.png',
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(height: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildLanguagePicker(context),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                L10n.s(context, 'create_account'),
                style: GoogleFonts.bebasNeue(
                  fontSize: 36,
                  letterSpacing: 3,
                  height: 1,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                L10n.s(context, 'join_thousands'),
                style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.65),
              ),
              const SizedBox(height: 48),
              
              // Social Signup
              SocialButton(
                icon: Image.asset('assets/images/goog.png', height: 24),
                label: L10n.s(context, 'sign_in_google'),
                onTap: _handleGoogleSignup,
                iconBackgroundColor: Colors.transparent,
              ),
              if (Platform.isIOS) ...[
                const SizedBox(height: 12),
                SocialButton(
                  icon: const Center(
                    child: Text(
                      '',
                      style: TextStyle(color: Colors.white, fontSize: 26, height: 1.25),
                    ),
                  ),
                  label: L10n.s(context, 'sign_in_apple'),
                  onTap: _handleAppleSignup,
                  iconBackgroundColor: Colors.black,
                ),
              ],
              const SizedBox(height: 20),
              
              Center(
                child: Text(
                  L10n.s(context, 'sync_info'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.dim, fontSize: 12, height: 1.5),
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
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      children: [
                        TextSpan(text: L10n.s(context, 'have_account')),
                        TextSpan(text: L10n.s(context, 'sign_in'), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
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
                        children: [
                          Text(
                            L10n.s(context, 'get_started_fast'),
                            style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L10n.s(context, 'one_tap_login'),
                            style: const TextStyle(color: AppColors.muted, fontSize: 10, height: 1.4),
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

  Widget _buildLanguagePicker(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => InkWell(
        onTap: () => _showLanguageDialog(context, settings),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.language, size: 14, color: AppColors.gold),
              const SizedBox(width: 6),
              Text(
                settings.locale.languageCode.toUpperCase(),
                style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'pt', 'name': 'Português'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'ar', 'name': 'العربية (Arabic)'},
      {'code': 'es', 'name': 'Español (Spanish)'},
      {'code': 'hi', 'name': 'हिन्दी (Hindi)'},
      {'code': 'zh', 'name': '中文 (Chinese)'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(L10n.s(context, 'select_language').toUpperCase(), style: const TextStyle(fontFamily: 'Bebas Neue', color: AppColors.text, letterSpacing: 1.5)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSelected = settings.locale.languageCode == lang['code'];
              return ListTile(
                title: Text(lang['name']!, style: TextStyle(color: isSelected ? AppColors.gold : AppColors.text, fontSize: 14)),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.gold, size: 18) : null,
                onTap: () {
                  settings.setLocale(Locale(lang['code']!));
                  Navigator.pop(context);
                },
              );
            },
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
          children: [
            const Icon(Icons.arrow_back, color: AppColors.muted, size: 16),
            const SizedBox(width: 8),
            Text(L10n.s(context, 'back'), style: const TextStyle(color: AppColors.muted, fontSize: 13)),
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

  Future<void> _handleAppleSignup() async {
    try {
      final user = await AuthService.signInWithApple();
      if (user != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    } catch (error) {
      debugPrint('Apple signup error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple sign-in failed: ${error.toString()}'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
