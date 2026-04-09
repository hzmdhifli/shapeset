import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/program.dart';
import '../screens/detail/program_detail_screen.dart';
import '../services/localization_service.dart';

class AthleteCard extends StatelessWidget {
  final Program program;

  const AthleteCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramDetailScreen(program: program),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image with Blur/Filter
                _buildBackgroundImage(),
                
                // Gradient Overlay
                _buildOverlay(),
                
                // Gold Left Accent
                _buildGoldAccent(),
                
                // Content
                _buildContent(context),
                
                // Arrow Indicator
                _buildArrow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    final bool isNetwork = program.imagePath.startsWith('http');
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5), // Subtle "Poster" blur
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.25),
          BlendMode.darken,
        ),
        child: isNetwork
            ? Image.network(
                program.imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : Image.asset(
                program.imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surface,
      child: const Icon(Icons.person, color: AppColors.gold, size: 40),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.92),
            Colors.black.withOpacity(0.45),
            Colors.black.withOpacity(0.08),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }

  Widget _buildGoldAccent() {
    return Positioned(
      left: 0,
      top: 50,
      bottom: 50,
      width: 2.5,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              program.num,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xB2C9A84C), // gold with opacity
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 3),
          Text(
            program.name.split(' ').first, // Just the first name for the card look
            style: GoogleFonts.bebasNeue(
              fontSize: 22,
              letterSpacing: 2,
              height: 1,
              color: AppColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            program.alias,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.text.withOpacity(0.55),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.18),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              L10n.s(context, program.badge.toLowerCase().contains('muscle') ? 'goal_muscle' : 'goal_performance').split('·').first.trim(), // Short badge translation fallback
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.gold2,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildArrow() {
    return Positioned(
      top: 14,
      right: 14,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: const Icon(
          Icons.arrow_forward,
          size: 11,
          color: AppColors.text,
        ),
      ),
    );
  }
}

