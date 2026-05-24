import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../services/localization_service.dart';
import '../../services/subscription_provider.dart';
import '../../services/auth_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isYearly = true;
  String _paymentMethod = 'card'; // 'card' or 'paypal'

  // Real Lemon Squeezy Checkout URLs
  final String _monthlyUrl = 'https://hazemdhifli.lemonsqueezy.com/checkout/buy/c4299c2e-e643-45c4-b12d-17c8ecf5168d?enabled=1599733';
  final String _yearlyUrl = 'https://hazemdhifli.lemonsqueezy.com/checkout/buy/2e2c35ae-7211-4677-b159-845aee137337?enabled=1599808';

  SubscriptionProvider? _subscriptionProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscriptionProvider = context.read<SubscriptionProvider>();
      _subscriptionProvider?.addListener(_onSubscriptionChanged);
    });
  }

  @override
  void dispose() {
    _subscriptionProvider?.removeListener(_onSubscriptionChanged);
    super.dispose();
  }

  void _onSubscriptionChanged() {
    if (mounted && (_subscriptionProvider?.isPro ?? false)) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pro Plan Activated Successfully!'),
            backgroundColor: AppColors.gold,
          ),
        );
      }
    }
  }

  Future<void> _launchCheckout() async {
    final user = AuthService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue')),
      );
      return;
    }

    String urlString = _isYearly ? _yearlyUrl : _monthlyUrl;
    
    // Append User ID to the URL to ensure correct account linking regardless of payment email
    final String separator = urlString.contains('?') ? '&' : '?';
    urlString += '${separator}checkout[custom][user_id]=${user.uid}';
    
    // Pre-fill the email in the checkout if available
    if (user.email != null) {
      urlString += '&checkout[email]=${user.email}';
    }

    final Uri url = Uri.parse(urlString);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_paymentMethod == 'paypal' 
            ? 'Opening secure PayPal checkout...' 
            : 'Opening secure checkout...'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.gold.withOpacity(0.9),
        ),
      );
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Could not launch checkout: $e');
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
                              
                              // Payment Method Selector
                              _buildPaymentMethodSelector(),
                              const SizedBox(height: 24),

                              if (_paymentMethod == 'card')
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.shield_outlined, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          L10n.s(context, 'upgrade_now').toUpperCase(),
                                          style: GoogleFonts.bebasNeue(
                                            fontSize: 20,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                _buildPayPalButton(),
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

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L10n.s(context, 'select_payment').toUpperCase(),
          style: GoogleFonts.bebasNeue(
            fontSize: 14,
            color: AppColors.muted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPaymentOption(
                id: 'card',
                label: L10n.s(context, 'credit_card'),
                icon: Icons.credit_card_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPaymentOption(
                id: 'paypal',
                label: 'PayPal',
                icon: Icons.account_balance_wallet_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.1) : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gold : AppColors.muted,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.gold : AppColors.muted,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayPalButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _launchCheckout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC439), // PayPal Gold
          foregroundColor: const Color(0xFF003087), // PayPal Blue
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: const Color(0xFFFFC439).withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Styled text to mimic PayPal logo
            Text(
              'Pay',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 22,
                color: const Color(0xFF003087),
              ),
            ),
            Text(
              'Pal',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 22,
                color: const Color(0xFF009CDE),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
