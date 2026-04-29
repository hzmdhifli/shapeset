import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../models/mock_data.dart';
import '../../models/program.dart';
import '../detail/program_detail_screen.dart';
import '../../services/localization_service.dart';
import '../../services/workout_provider.dart';
import '../../main.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  SharedPreferences? _prefs;
  String _userName = 'CHAMP';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _userName = prefs.getString('userName')?.toUpperCase() ?? 'ALEX';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildGreeting(context)),
            _buildStatsGrid(context),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // Last Completed Session (New Section)
            _buildLastSessionSection(context),
            
            SliverToBoxAdapter(child: _buildSectionLabel(context, 'active_program_label')),
            SliverToBoxAdapter(child: _buildActiveProgramCard(context)),
            SliverToBoxAdapter(child: _buildSectionLabel(context, 'weekly_activity')),
            SliverToBoxAdapter(child: _buildWeeklyActivityChart(context)),
            SliverToBoxAdapter(child: _buildSectionLabel(context, 'month_streak')),
            SliverToBoxAdapter(child: _buildStreakSection(context)),
            
            // Program Completions (New Section)
            _buildProgramCompletionsSection(context),
            
            SliverToBoxAdapter(child: _buildSectionLabel(context, 'achievements')),
            SliverToBoxAdapter(child: _buildAchievementsList(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, right: 22, top: 20, bottom: 18),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                L10n.s(context, 'home_title'),
                style: GoogleFonts.bebasNeue(
                  fontSize: 24,
                  letterSpacing: 2,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          Image.asset(
            'assets/images/widgi.png',
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    Program? activeProgram;
    final gender = _prefs?.getString('userGender')?.toLowerCase();
    
    if (workoutProvider.activeProgramId != null) {
      activeProgram = [...mockPrograms, ...mockFemalePrograms].firstWhere(
        (p) => p.id == workoutProvider.activeProgramId,
        orElse: () => (gender == 'female' || gender == 'woman') ? mockFemalePrograms[0] : mockPrograms[0]
      );
    } else {
      activeProgram = (gender == 'female' || gender == 'woman') ? mockFemalePrograms[0] : mockPrograms[0];
    }

    final programName = activeProgram?.name ?? 'Training';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${L10n.s(context, 'week')} 3 ${L10n.s(context, 'of')} 12 · $programName',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              '${L10n.s(context, 'keep_going')}\n$_userName',
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                letterSpacing: 2,
                height: 1.1,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String key, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            L10n.s(context, key).toUpperCase(),
            style: const TextStyle(
              color: AppColors.dim,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.8,
            ),
          ),
          if (trailing != null)
            Text(
              trailing.toUpperCase(),
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final historyCount = workoutProvider.history.length;
    
    Program? activeProgram;
    final gender = _prefs?.getString('userGender')?.toLowerCase();
    if (workoutProvider.activeProgramId != null) {
      activeProgram = [...mockPrograms, ...mockFemalePrograms].firstWhere(
        (p) => p.id == workoutProvider.activeProgramId,
        orElse: () => (gender == 'female' || gender == 'woman') ? mockFemalePrograms[0] : mockPrograms[0]
      );
    } else {
      activeProgram = (gender == 'female' || gender == 'woman') ? mockFemalePrograms[0] : mockPrograms[0];
    }
    
    return SliverPadding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 22),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.25, // Increased for more text breathing room
        children: [
          _buildStatCard('🔥', historyCount.toString(), L10n.s(context, 'sessions_completed'), '+${workoutProvider.getWeekCompletionCount(activeProgram?.id ?? "")} ${L10n.s(context, 'week')}', AppColors.redText, AppColors.redBg, AppColors.redText),
          _buildStatCard('⏱️', Localizations.localeOf(context).languageCode == 'ar' ? '٣٤ س' : '34h', L10n.s(context, 'training_time'), Localizations.localeOf(context).languageCode == 'ar' ? '↑ ١٢٪ عن الأسبوع الماضي' : '↑ 12% vs last wk', AppColors.text, AppColors.blueBg, AppColors.blueText),
          _buildStatCard('⚡', '12', L10n.s(context, 'streak'), L10n.s(context, 'personal_best'), AppColors.gold, AppColors.gold3, AppColors.gold2),
          _buildStatCard('🏋️', Localizations.localeOf(context).languageCode == 'ar' ? '٤.٢ ط' : '4.2T', L10n.s(context, 'total_volume'), '↑ 8% ${L10n.s(context, 'week')}', AppColors.text, AppColors.greenBg, AppColors.greenText),
        ],
      ),
    );
  }

  Widget _buildStatCard(String icon, String val, String label, String delta, Color valColor, Color deltaBg, Color deltaText) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: _res(context, 16))),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              val,
              style: GoogleFonts.bebasNeue(
                fontSize: _res(context, 28),
                letterSpacing: 1,
                color: valColor,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              label,
              style: TextStyle(color: AppColors.muted, fontSize: _res(context, 11)),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: deltaBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  delta,
                  style: TextStyle(color: deltaText, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProgramCard(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    if (workoutProvider.activeProgramId == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              const Icon(Icons.fitness_center_outlined, color: AppColors.muted, size: 32),
              const SizedBox(height: 16),
              Text(
                L10n.s(context, 'no_program_selected'),
                style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to HOME Tab
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(L10n.s(context, 'start_program_button'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    final activeProgramId = workoutProvider.activeProgramId;
    final activeProgram = [...mockPrograms, ...mockFemalePrograms].firstWhere(
      (p) => p.id == activeProgramId,
      orElse: () => mockPrograms[0]
    );
    
    final completedCount = activeProgram.schedule.where((day) => workoutProvider.isDayCompleted(activeProgram.id, day.dayNumber)).length;
    final totalDays = activeProgram.schedule.where((day) => day.isTraining).length;
    final progress = totalDays > 0 ? completedCount / totalDays : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProgramDetailScreen(program: activeProgram)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: [Color(0xFF1A1208), Color(0xFF221808)]),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10n.s(context, 'active_program_label'), style: const TextStyle(color: AppColors.gold, fontSize: 10, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(activeProgram.name.toUpperCase(), style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 22, color: AppColors.text, letterSpacing: 2)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0x1FC9A84C),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      L10n.s(context, 'overall_completion'),
                      style: const TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ),
                  Text(
                    '${L10n.s(context, 'day')} $completedCount/${activeProgram.schedule.length} ✓',
                    style: const TextStyle(fontSize: 11, color: AppColors.gold2, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastSessionSection(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final lastSession = workoutProvider.getLastCompletedSession();
    
    if (lastSession == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(context, 'last_completed_session'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lastSession.dayName.toUpperCase(),
                              style: GoogleFonts.bebasNeue(
                                fontSize: lastSession.dayName.length > 18 ? 19 : 24,
                                color: AppColors.text,
                                letterSpacing: lastSession.dayName.length > 18 ? 1.0 : 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('EEEE, d MMMM', Localizations.localeOf(context).languageCode).format(lastSession.date),
                              style: const TextStyle(color: AppColors.muted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 16),
                  Text(
                    L10n.s(context, 'muscles_trained'),
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      color: AppColors.muted,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: lastSession.musclesTrained.map((m) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                      ),
                      child: Text(
                        m.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart(BuildContext context) {
    final data = [4, 5, 2, 6, 4, 7, 5]; // Mock but feel realistic
    final labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
    const maxVal = 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.s(context, 'sessions_per_week'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      L10n.s(context, 'sessions_goal'),
                      style: const TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
                _buildLegendItem(L10n.s(context, 'done'), AppColors.gold),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              decoration: BoxDecoration(
                                color: AppColors.background3,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                              child: FractionallySizedBox(
                                heightFactor: data[index] / maxVal,
                                widthFactor: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: index == 6 ? AppColors.gold : AppColors.gold.withOpacity(0.35),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(labels[index], style: const TextStyle(color: AppColors.muted, fontSize: 9)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
      ],
    );
  }

  Widget _buildStreakSection(BuildContext context) {
    final days = Localizations.localeOf(context).languageCode == 'ar' 
        ? ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح']
        : ['M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final status = List.generate(28, (i) => i % 7 == 4 ? 'skip' : (i == 27 ? 'today' : 'done'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(days.length, (index) {
            final isDone = status[index] == 'done';
            final isToday = status[index] == 'today';

            return Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.gold
                    : isDone
                        ? AppColors.gold3
                        : AppColors.background3,
                border: isToday
                    ? null
                    : Border.all(color: isDone ? AppColors.gold.withOpacity(0.25) : AppColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                days[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isToday
                      ? Colors.black
                      : isDone
                          ? AppColors.gold2
                          : AppColors.dim,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAchievementsList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          _buildAchievementItem('🏆', L10n.s(context, 'first_sweat_title'), L10n.s(context, 'first_sweat_desc'), true),
          _buildAchievementItem('🔥', L10n.s(context, 'on_fire_title'), L10n.s(context, 'on_fire_desc'), true),
          _buildAchievementItem('💪', L10n.s(context, 'ironclad_title'), L10n.s(context, 'ironclad_desc'), true),
          _buildAchievementItem('🥇', L10n.s(context, 'champion_title'), L10n.s(context, 'champion_desc'), false),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String icon, String title, String desc, bool isUnlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isUnlocked ? AppColors.gold3 : AppColors.background3,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text)),
                    Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ),
              if (!isUnlocked)
                const Icon(Icons.lock_outline, size: 14, color: AppColors.dim),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramCompletionsSection(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final reps = workoutProvider.programRepetitions;
    
    if (reps.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(context, 'program_completions'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: reps.entries.map((entry) {
                final programId = entry.key;
                final count = entry.value;
                
                final program = [...mockPrograms, ...mockFemalePrograms].firstWhere(
                  (p) => p.id == programId,
                  orElse: () => mockPrograms[0]
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(program.imagePath),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          entry.value.toString(),
                          style: GoogleFonts.bebasNeue(color: AppColors.gold, fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              program.name.toUpperCase(),
                              style: GoogleFonts.bebasNeue(fontSize: 18, color: AppColors.text, letterSpacing: 1),
                            ),
                            Text(
                              L10n.s(context, 'times_finished').replaceAll('{num}', count.toString()),
                              style: const TextStyle(fontSize: 11, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.workspace_premium, color: AppColors.gold, size: 22),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
  double _res(BuildContext context, double original) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 375.0;
    if (scale < 0.85) scale = 0.85;
    if (scale > 1.25) scale = 1.25;
    return original * scale;
  }
}
