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
      child: Row(
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
          const Icon(Icons.wb_sunny_outlined, color: AppColors.muted, size: 24),
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
          Text(
            'KEEP\nGOING $_userName',
            style: GoogleFonts.bebasNeue(
              fontSize: 28,
              letterSpacing: 2,
              height: 1.1,
              color: AppColors.text,
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
      padding: const EdgeInsets.symmetric(horizontal: 22),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: [
          _buildStatCard('🔥', historyCount.toString(), L10n.s(context, 'sessions_completed'), '+${workoutProvider.getWeekCompletionCount(activeProgram?.id ?? "")} this week', AppColors.redText, AppColors.redBg, AppColors.redText),
          _buildStatCard('⏱️', '34h', L10n.s(context, 'training_time'), '↑ 12% vs last wk', AppColors.text, AppColors.blueBg, AppColors.blueText),
          _buildStatCard('⚡', '12', L10n.s(context, 'streak'), 'Personal best!', AppColors.gold, AppColors.gold3, AppColors.gold2),
          _buildStatCard('🏋️', '4.2T', L10n.s(context, 'total_volume'), '↑ 8% this week', AppColors.text, AppColors.greenBg, AppColors.greenText),
        ],
      ),
    );
  }

  Widget _buildStatCard(String icon, String val, String label, String delta, Color valColor, Color deltaBg, Color deltaText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            val,
            style: GoogleFonts.bebasNeue(
              fontSize: 26,
              letterSpacing: 1,
              color: valColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              child: Text(
                delta,
                style: TextStyle(color: deltaText, fontSize: 10, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProgramCard(BuildContext context) {
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

    if (activeProgram == null) return const SizedBox();
    
    final completedCount = activeProgram.schedule.where((day) => workoutProvider.isDayCompleted(activeProgram!.id, day.dayNumber)).length;
    final totalDays = activeProgram.schedule.where((day) => day.isTraining).length;
    final progress = totalDays > 0 ? completedCount / totalDays : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProgramDetailScreen(program: activeProgram!)),
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
                   Text(
                    L10n.s(context, 'overall_completion'),
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  Text(
                    'Day $completedCount/${activeProgram.schedule.length} ✓',
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
                                fontSize: 24,
                                color: AppColors.text,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('EEEE, MMMM d').format(lastSession.date),
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
                    'MUSCLES TRAINED',
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
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S', 'M', 'T', 'W', 'T', 'F', 'S', 'S'];
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
          _buildAchievementItem('🏆', 'First Sweat', 'Completed your first session', true),
          _buildAchievementItem('🔥', 'On Fire', '7-day training streak', true),
          _buildAchievementItem('💪', 'Ironclad', 'Lifted 1 tonne in a week', true),
          _buildAchievementItem('🥇', 'Champion', 'Complete a full 12-week program', false),
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
}
