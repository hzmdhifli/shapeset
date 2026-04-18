import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../workout/workout_session_screen.dart';
import '../../services/localization_service.dart';
import '../../models/mock_data.dart';

class ProgramDetailScreen extends StatefulWidget {
  final Program program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  int _selectedSplitIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCaches();
  }

  void _initCaches() {
    initGlobalCaches((muscle, exercises) {
      return exercises.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontSize: 13)),
        );
      }).toList();
    });
  }

  String _getMuscleForExercise(String exName) {
    return exerciseToMuscle[exName] ?? 'Other';
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the link: $url')),
        );
      }
    }
  }

  void _showFST7Explanation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          border: Border(
            top: BorderSide(color: AppColors.gold, width: 2),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center_outlined, color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'FST-7 EXPLAINED',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 28,
                      color: AppColors.text,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              "FST-7 (Fascia Stretch Training) is a hypertrophy-focused training style designed by trainer Hany Rambod, involving 7 high-volume sets of 8–12 reps at the end of a workout. It uses minimal rest (30–45 seconds) to create a maximal muscle pump, stretching the muscle fascia from the inside out to promote growth and nutrient delivery.",
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.text.withOpacity(0.8),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    'GOT IT',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 18,
                      color: AppColors.gold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasSplits = widget.program.splits != null && widget.program.splits!.isNotEmpty;
    final List<ScheduleDay> days = hasSplits 
        ? widget.program.splits![_selectedSplitIndex].days 
        : (widget.program.schedule.isNotEmpty ? widget.program.schedule : []);

    return GestureDetector(
      onTap: () {
        // Clear focus if needed
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverToBoxAdapter(
            child: _buildHero(context),
          ),
          
          // Stats and Info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(context),
                  const SizedBox(height: 12),
                  _buildStyleBadge(),
                  const SizedBox(height: 8),
                  _buildQuote(),
                  const SizedBox(height: 32),
                  
                  if (hasSplits) ...[
                    _buildSectionTitle(context, 'gym_program_builder'),
                    const SizedBox(height: 16),
                    _buildSplitTabs(),
                    const SizedBox(height: 24),
                    Text(
                      widget.program.splits![_selectedSplitIndex].description,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else ...[
                    _buildSectionTitle(context, 'training_program'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.08),
                            AppColors.gold.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.tips_and_updates_outlined, size: 18, color: AppColors.gold),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TRAINING TIP',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 14,
                                    color: AppColors.gold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '"3x8-12" means 3 sets, each one between 8 (min) and 12 (max) repetitions.',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: AppColors.text.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),

          // Lazy loaded list of days
          if (hasSplits)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildDayCard(days[index]),
                  childCount: days.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildDayCard(days[index]),
                  childCount: days.length,
                ),
              ),
            ),

          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'focus_areas'),
                  const SizedBox(height: 12),
                  _buildTags(),
                  const SizedBox(height: 32),
                  _buildCTA(context),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildSplitTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.program.splits!.asMap().entries.map((entry) {
          final idx = entry.key;
          final split = entry.value;
          final bool isSelected = idx == _selectedSplitIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                split.name,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.black : AppColors.muted,
                ),
              ),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _selectedSplitIndex = idx);
              },
              selectedColor: AppColors.gold,
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.gold : AppColors.border),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSplitDays() {
    final split = widget.program.splits![_selectedSplitIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          split.description,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.muted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: split.days.length,
          itemBuilder: (context, index) {
            final day = split.days[index];
            return _buildDayCard(day);
          },
        ),
      ],
    );
  }

  Widget _buildDayCard(ScheduleDay day) {
    // Group exercises by muscle group using pre-calculated map for O(1) lookup
    final Map<String, List<WorkoutExercise>> groupedExercises = {};
    for (var ex in day.exercises) {
      final muscleGroup = _getMuscleForExercise(ex.name);
      groupedExercises.putIfAbsent(muscleGroup, () => []).add(ex);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                  ),
                  child: Text(
                    day.dayNumber.toUpperCase(),
                    style: GoogleFonts.bebasNeue(
                      fontSize: 15,
                      color: AppColors.gold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    day.name.toUpperCase(),
                    style: GoogleFonts.bebasNeue(
                      fontSize: 20,
                      color: AppColors.text,
                      letterSpacing: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          
          if (day.isTraining) ...[
            // Muscles and Exercises
            ...groupedExercises.entries.map((group) {
              final muscle = group.key;
              final exercises = group.value;
              final Color muscleBg = _getMuscleColor(muscle);
              final Color muscleText = _getMuscleTextColor(muscle);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: muscleBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        muscle.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: muscleText,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  ...exercises.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final ex = entry.value;
                    final pool = exercisePools[muscle] ?? [ex.name];

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: Row(
                        children: [
                          Text(
                            '${idx + 1}',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 14,
                              color: AppColors.dim,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              ex.name,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: exerciseFormGifs.containsKey(ex.name) ? () => _launchURL(exerciseFormGifs[ex.name]!) : null,
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    ex.detail,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                  if (exerciseFormGifs.containsKey(ex.name))
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.play_circle_outline, color: AppColors.gold, size: 12),
                                        const SizedBox(width: 4),
                                        Text(
                                          'FORM',
                                          style: GoogleFonts.bebasNeue(
                                            color: AppColors.gold,
                                            fontSize: 11,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  if (groupedExercises.entries.last.key != muscle)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                ],
              );
            }).toList(),
          ] else 
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'REST DAY',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Color _getMuscleColor(String muscle) {
    switch (muscle) {
      case 'Chest': return const Color(0xFFE6F1FB);
      case 'Back': return const Color(0xFFE1F5EE);
      case 'Shoulder': 
      case 'Shoulders':
      case 'Delts': return const Color(0xFFEEEDFE);
      case 'Arm': 
      case 'Arms':
      case 'Biceps':
      case 'Triceps': return const Color(0xFFFBEAF0);
      case 'Leg': 
      case 'Legs':
      case 'Quads':
      case 'Hamstrings': return const Color(0xFFEAF3DE);
      case 'Abs': return const Color(0xFFF1EFE8);
      case 'Calves':
      case 'Glutes':
      case 'Traps':
      case 'Weak Points': return const Color(0xFFFAEEDA);
      case 'Push': return const Color(0xFFE6F1FB);
      case 'Pull': return const Color(0xFFE1F5EE);
      default: return AppColors.surface;
    }
  }

  Color _getMuscleTextColor(String muscle) {
    switch (muscle) {
      case 'Chest': return const Color(0xFF0C447C);
      case 'Back': return const Color(0xFF085041);
      case 'Shoulder': 
      case 'Shoulders':
      case 'Delts': return const Color(0xFF3C3489);
      case 'Arm': 
      case 'Arms':
      case 'Biceps': return const Color(0xFF72243E);
      case 'Triceps': return const Color(0xFF993556);
      case 'Leg': 
      case 'Legs':
      case 'Quads': return const Color(0xFF27500A);
      case 'Hamstrings': return const Color(0xFF3B6D11);
      case 'Abs': return const Color(0xFF5F5E5A);
      case 'Calves': return const Color(0xFF633806);
      case 'Glutes': return const Color(0xFF854F0B);
      case 'Traps': return const Color(0xFF534AB7);
      case 'Weak Points': return const Color(0xFF633806);
      case 'Push': return const Color(0xFF0C447C);
      case 'Pull': return const Color(0xFF085041);
      default: return AppColors.muted;
    }
  }

  Widget _buildHero(BuildContext context) {
    final bool isNetwork = widget.program.imagePath.startsWith('http');
    return Stack(
      children: [
        // Background Image with Blur
        Container(
          height: 380,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.surface),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              BlendMode.darken,
            ),
            child: isNetwork
                ? Image.network(
                    widget.program.imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => Container(),
                  )
                : Image.asset(
                    widget.program.imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) => Container(),
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
                  Colors.black.withOpacity(0.1),
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
                widget.program.num,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.gold,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.program.name,
                style: GoogleFonts.bebasNeue(
                  fontSize: 42,
                  letterSpacing: 3,
                  height: 1,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.program.alias,
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
    String exCount = '0';
    if (widget.program.splits != null && widget.program.splits!.isNotEmpty) {
      exCount = widget.program.splits![_selectedSplitIndex].days.fold(0, (sum, day) => (sum as int) + day.exercises.length).toString();
    } else if (widget.program.schedule.isNotEmpty) {
      exCount = widget.program.schedule[0].exercises.length.toString();
    }
    
    return Row(
      children: [
        Expanded(child: _buildStatBox(exCount, L10n.s(context, 'exercises'))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatBox(widget.program.style, L10n.s(context, 'style'))),
        const SizedBox(width: 8),
        Expanded(child: _buildStatBox(widget.program.intensity, L10n.s(context, 'intensity'))),
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
    final bool isFST7 = widget.program.badge == 'FST-7';

    return GestureDetector(
      onTap: isFST7 ? _showFST7Explanation : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.gold3,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isFST7 ? AppColors.gold : AppColors.gold.withOpacity(0.25),
            width: isFST7 ? 1.5 : 1.0,
          ),
          boxShadow: isFST7 ? [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.program.badge,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: isFST7 ? AppColors.gold : AppColors.gold2,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            if (isFST7) ...[
              const SizedBox(width: 6),
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.gold),
            ],
          ],
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
        widget.program.quote,
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

  Widget _buildExerciseListItem(WorkoutExercise ex, int idx) {
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
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: widget.program.tags.map((tag) => _buildTag(tag)).toList(),
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
          final List<WorkoutExercise> exercises;
          final String title;
          
          if (widget.program.splits != null && widget.program.splits!.isNotEmpty) {
            final split = widget.program.splits![_selectedSplitIndex];
            exercises = split.days[0].exercises;
            title = '${split.name} - Day 1';
          } else if (widget.program.schedule.isNotEmpty) {
            exercises = widget.program.schedule[0].exercises;
            title = widget.program.name;
          } else {
            exercises = [];
            title = widget.program.name;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutSessionScreen(
                exercises: exercises,
                sessionTitle: title,
              ),
            ),
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
