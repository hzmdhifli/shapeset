import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'widgets/social_button.dart';
import 'signup_screen.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/localization_service.dart';

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
                L10n.s(context, 'welcome_back'),
                style: GoogleFonts.bebasNeue(
                  fontSize: 36,
                  letterSpacing: 3,
                  height: 1,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                L10n.s(context, 'sign_in_continue'),
                style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.65),
              ),
              const SizedBox(height: 48),
              
              // Social Login
              SocialButton(
                icon: Image.asset('assets/images/gmail-logo.png', height: 24),
                label: L10n.s(context, 'sign_in_google'),
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
                    text: TextSpan(
                      style: const TextStyle(color: AppColors.muted, fontSize: 13),
                      children: [
                        TextSpan(text: L10n.s(context, 'no_account')),
                        TextSpan(text: L10n.s(context, 'sign_up_free'), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
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
                        children: [
                          Text(
                            L10n.s(context, 'secure_access'),
                            style: const TextStyle(color: AppColors.text, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L10n.s(context, 'encryption_info'),
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
