import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../workout/workout_session_screen.dart';
import '../../services/localization_service.dart';

class ProgramDetailScreen extends StatelessWidget {
  final Program program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildStatsRow(context),
                  const SizedBox(height: 12),
                  _buildStyleBadge(),
                  const SizedBox(height: 8),
                  _buildQuote(),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'training_program'),
                  const SizedBox(height: 12),
                  _buildExerciseList(),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'focus_areas'),
                  const SizedBox(height: 12),
                  _buildTags(),
                  const SizedBox(height: 32),
                  _buildCTA(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final bool isNetwork = program.imagePath.startsWith('http');
    return Stack(
      children: [
        // Background Image with Blur
        Container(
          height: 380,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.surface),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.darken,
              ),
              child: isNetwork
                  ? Image.network(
                      program.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Container(),
                    )
                  : Image.asset(
                      program.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Container(),
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
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                  AppColors.background,
                ],
                stops: const [0.5, 0.75, 1.0],
              ),
            ),
          ),
        ),
        
        // Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 12),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back, color: AppColors.muted, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      L10n.s(context, 'back'),
                      style: GoogleFonts.dmSans(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Title Content
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.num,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.gold,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                program.name,
                style: GoogleFonts.bebasNeue(
                  fontSize: 42,
                  letterSpacing: 3,
                  height: 1,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                program.alias,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.text.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatBox(program.schedule.isNotEmpty ? program.schedule[0].exercises.length.toString() : '0', L10n.s(context, 'exercises'))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatBox(program.style, L10n.s(context, 'style'))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatBox(program.intensity, L10n.s(context, 'intensity'))),
      ],
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 22,
              color: AppColors.gold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: AppColors.muted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold3,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Text(
        program.badge,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          color: AppColors.gold2,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildQuote() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.only(left: 14),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.gold, width: 2)),
      ),
      child: Text(
        program.quote,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppColors.muted,
          height: 1.75,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        L10n.s(context, key).toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: AppColors.dim,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    final exercises = program.schedule.isNotEmpty ? program.schedule[0].exercises : <WorkoutExercise>[];
    return Column(
      children: exercises.asMap().entries.map((entry) {
        final idx = entry.key;
        final ex = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Text(
                '0${idx + 1}',
                style: GoogleFonts.bebasNeue(
                  fontSize: 18,
                  color: AppColors.dim,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ex.detail,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress Bar
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: ex.progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: program.tags.map((tag) => _buildTag(tag)).toList(),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background3,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border2),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: AppColors.muted,
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkoutSessionScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          L10n.s(context, 'start_this_program'),
          style: GoogleFonts.bebasNeue(
            fontSize: 17,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}
