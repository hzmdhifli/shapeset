import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/program.dart';
import '../screens/detail/program_detail_screen.dart';

class SpecialProgramCard extends StatelessWidget {
  final Program program;
  final String title;

  const SpecialProgramCard({
    super.key, 
    required this.program,
    required this.title,
  });

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
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.asset(
                program.imagePath,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.3),
              ),
              
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Gold Border Accent
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'FEATURED',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.bebasNeue(
                        fontSize: 32,
                        letterSpacing: 2,
                        color: AppColors.text,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '5 Specialized Physique Archetypes',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Play/Arrow icon
              Positioned(
                bottom: 24,
                right: 24,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withOpacity(0.2),
                    border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.gold,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
