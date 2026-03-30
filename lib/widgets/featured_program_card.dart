import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/mock_data.dart';
import '../screens/detail/program_detail_screen.dart';

class FeaturedProgramCard extends StatelessWidget {
  const FeaturedProgramCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramDetailScreen(program: mockPrograms[0]),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1208),
              Color(0xFF2D1E0A),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTag(),
                      const SizedBox(height: 7),
                      Text(
                        'CRISTIANO\nRONALDO',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontSize: 26,
                              height: 1.1,
                            ),
                      ),
                      const Text(
                        'Full Body Performance · 12 Weeks',
                        style: TextStyle(
                          color: Color(0x8CFFFFFF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStat('12', 'Weeks'),
                      const SizedBox(width: 18),
                      _buildStat('6', 'Days/Wk'),
                      const SizedBox(width: 18),
                      _buildStat('2.8K', 'Athletes'),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 18,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.13),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withOpacity(0.28)),
                  ),
                  child: const Icon(Icons.arrow_forward, color: AppColors.gold, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold3,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: const Text(
        '⚡ FEATURED PROGRAM',
        style: TextStyle(
          color: AppColors.gold2,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Bebas Neue',
            fontSize: 19,
            color: AppColors.gold2,
            letterSpacing: 1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.muted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
