import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../../models/mock_data.dart';
import '../../widgets/athlete_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final programs = mockPrograms;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 38),
              _buildHero(),
              const SizedBox(height: 32),
              _buildAthleteGrid(programs),
              const SizedBox(height: 100), // Bottom nav space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ATHLÈTE',
            style: GoogleFonts.bebasNeue(
              fontSize: 24,
              letterSpacing: 2,
              color: AppColors.gold,
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border2),
            ),
            child: const Icon(Icons.search, color: AppColors.muted, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BODYBUILDING LEGENDS',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: AppColors.gold,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'CHOOSE YOUR\nPROGRAM',
            style: GoogleFonts.bebasNeue(
              fontSize: 38,
              letterSpacing: 3,
              height: 1,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select an athlete to explore their full training system.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteGrid(List<Program> programs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: programs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          return AthleteCard(program: programs[index]);
        },
      ),
    );
  }
}

