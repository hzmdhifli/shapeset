import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../services/localization_service.dart';
import '../../services/subscription_provider.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isYearly = true;

  // Real Lemon Squeezy Checkout URLs
  final String _monthlyUrl = 'https://hazemdhifli.lemonsqueezy.com/checkout/buy/2e2c35ae-7211-4677-b159-845aee137337';
  final String _yearlyUrl = 'https://hazemdhifli.lemonsqueezy.com/checkout/buy/c4299c2e-e643-45c4-b12d-17c8ecf5168d';

  Future<void> _launchCheckout() async {
    final String urlString = _isYearly ? _yearlyUrl : _monthlyUrl;
    final Uri url = Uri.parse(urlString);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        // Note: Real verification happens via webhooks or polling your backend.
        // For testing, you can still use the debug button in Profile to unlock.
      }
    } catch (e) {
      debugPrint('Could not launch checkout: $e');
    }
  }

  // White Test: Simulate successful payment locally
  Future<void> _simulateSuccess() async {
    final subProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    await subProvider.setPro(true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test: Subscription Activated!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Return to profile/home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image/Gradient
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'assets/images/arnold.jpg', // Using an existing asset as placeholder for background
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.surface, Colors.black],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            // Restore purchase logic
                          },
                          child: Text(
                            L10n.s(context, 'restore_purchase'),
                            style: const TextStyle(color: AppColors.muted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Column(
                      children: [
                        // Pro Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            L10n.s(context, 'pro_badge'),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          L10n.s(context, 'pro_title'),
                          style: GoogleFonts.bebasNeue(
                            fontSize: 48,
                            color: Colors.white,
                            letterSpacing: 4,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          L10n.s(context, 'pro_subtitle'),
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Column(
                      children: [
                        _buildFeatureRow(context, L10n.s(context, 'pro_feature_1')),
                        _buildFeatureRow(context, L10n.s(context, 'pro_feature_2')),
                        _buildFeatureRow(context, L10n.s(context, 'pro_feature_3')),
                        _buildFeatureRow(context, L10n.s(context, 'pro_feature_5')),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Column(
                      children: [
                        // Plan Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildToggleItem(
                                  label: L10n.s(context, 'monthly_plan'),
                                  isSelected: !_isYearly,
                                  onTap: () => setState(() => _isYearly = false),
                                ),
                              ),
                              Expanded(
                                child: _buildToggleItem(
                                  label: L10n.s(context, 'yearly_plan'),
                                  isSelected: _isYearly,
                                  onTap: () => setState(() => _isYearly = true),
                                  showBadge: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Price Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.gold.withOpacity(0.1),
                                AppColors.gold.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _isYearly ? L10n.s(context, 'year_price') : L10n.s(context, 'month_price'),
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 56,
                                  color: AppColors.gold,
                                  letterSpacing: 2,
                                  height: 1,
                                ),
                              ),
                              Text(
                                _isYearly ? L10n.s(context, 'per_year') : L10n.s(context, 'per_month'),
                                style: const TextStyle(color: AppColors.muted, fontSize: 14),
                              ),
                              if (_isYearly) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    L10n.s(context, 'save_33'),
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _launchCheckout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.gold,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 8,
                                    shadowColor: AppColors.gold.withOpacity(0.4),
                                  ),
                                  child: Text(
                                    L10n.s(context, 'upgrade_now').toUpperCase(),
                                    style: GoogleFonts.bebasNeue(
                                      fontSize: 20,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Column(
                      children: [
                        Text(
                          L10n.s(context, 'terms_agree'),
                          style: const TextStyle(color: AppColors.dim, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        // WHITE TEST BUTTON
                        TextButton(
                          onPressed: _simulateSuccess,
                          child: Text(
                            'WHITE TEST: SIMULATE SUCCESS',
                            style: TextStyle(
                              color: AppColors.gold.withOpacity(0.3),
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: isSelected ? AppColors.gold.withOpacity(0.5) : Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (showBadge) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  L10n.s(context, 'save_33'),
                  style: const TextStyle(color: Colors.black, fontSize: 7, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
