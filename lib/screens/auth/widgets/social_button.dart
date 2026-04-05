import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconBackgroundColor;
  final Color? iconBorderColor;

  const SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconBackgroundColor,
    this.iconBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBackgroundColor ?? Colors.transparent, // Handled by provided icon
                border: iconBorderColor != null ? Border.all(color: iconBorderColor!) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6), // Slightly smaller than the 8px container to avoid bleed
                child: icon,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.dim, size: 18),
          ],
        ),
      ),
    );
  }
}
