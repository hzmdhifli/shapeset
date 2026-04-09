import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/mock_data.dart';
import '../detail/program_detail_screen.dart';
import '../../services/localization_service.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildGreeting(context),
              _buildStatsGrid(context),
              const SizedBox(height: 24),
              _buildSectionLabel(context, 'active_program_label'),
              _buildActiveProgramCard(context),
              _buildSectionLabel(context, 'weekly_activity'),
              _buildWeeklyActivityChart(context),
              _buildSectionLabel(context, 'month_streak'),
              _buildStreakSection(context),
              _buildSectionLabel(context, 'achievements'),
              _buildAchievementsList(context),
              const SizedBox(height: 90),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${L10n.s(context, 'week')} 3 ${L10n.s(context, 'of')} 12 · Ronaldo Program',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'KEEP\nGOING ALEX',
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

  Widget _buildSectionLabel(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Text(
        L10n.s(context, key).toUpperCase(),
        style: const TextStyle(
          color: AppColors.dim,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: LayoutBuilder(builder: (context, constraints) {
        // Use a aspect ratio that provides enough height (at least 135px)
        double cardWidth = (constraints.maxWidth - 10) / 2;
        double childAspectRatio = cardWidth / 135;
        
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard('🔥', '18', L10n.s(context, 'sessions_completed'), '+3 this week', AppColors.redText, AppColors.redBg, AppColors.redText),
            _buildStatCard('⏱️', '34h', L10n.s(context, 'training_time'), '↑ 12% vs last wk', AppColors.text, AppColors.blueBg, AppColors.blueText),
            _buildStatCard('⚡', '12', L10n.s(context, 'streak'), 'Personal best!', AppColors.gold, AppColors.gold3, AppColors.gold2),
            _buildStatCard('🏋️', '4.2T', L10n.s(context, 'total_volume'), '↑ 8% this week', AppColors.text, AppColors.greenBg, AppColors.greenText),
          ],
        );
      }),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProgramDetailScreen(program: mockPrograms[0])),
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
              const Text('CRISTIANO RONALDO', style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 22, color: AppColors.text, letterSpacing: 2)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: const LinearProgressIndicator(
                  value: 0.25,
                  backgroundColor: Color(0x1FC9A84C),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${L10n.s(context, 'week')} 3 ${L10n.s(context, 'of')} 12',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  Text(
                    '25% ${L10n.s(context, 'complete_label')}',
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

  Widget _buildWeeklyActivityChart(BuildContext context) {
    final data = [3, 4, 5, 4, 6, 5, 3];
    final labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
    const maxVal = 6;

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
