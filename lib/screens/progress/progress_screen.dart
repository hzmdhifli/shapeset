import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/mock_data.dart';
import '../detail/program_detail_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildGreeting(),
              _buildStatsGrid(),
              _buildActiveProgramCard(context),
              _buildSectionTitle('Weekly Sessions'),
              _buildChartCard(),
              _buildSectionTitle('This Month\'s Streak'),
              _buildStreakRow(),
              _buildSectionTitle('Achievements'),
              _buildAchievements(),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('ATHLÈTE', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.gold)),
          const Icon(Icons.wb_sunny_outlined, color: AppColors.muted, size: 24),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Week 3 of 12 · Ronaldo Program', style: TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 1)),
          SizedBox(height: 3),
          Text('KEEP\nGOING ALEX', style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 28, letterSpacing: 2, height: 1.1, color: AppColors.text)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
        children: [
          _buildStatCard('🔥', '18', 'Sessions Completed', '+3 this week', AppColors.redText),
          _buildStatCard('⏱️', '34h', 'Total Training Time', '↑ 12% vs last wk', AppColors.text),
          _buildStatCard('⚡', '12', 'Day Streak', 'Personal best!', AppColors.gold),
          _buildStatCard('🏋️', '4.2T', 'Total Volume Lifted', '↑ 8% this week', AppColors.text),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, String delta, Color valueColor) {
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
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 26, color: valueColor, letterSpacing: 1)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(100)),
            child: Text(delta, style: const TextStyle(fontSize: 10, color: AppColors.greenText, fontWeight: FontWeight.bold)),
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
      child: Container(
        margin: const EdgeInsets.all(22),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(colors: [Color(0xFF1A1208), Color(0xFF221808)]),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ACTIVE PROGRAM', style: TextStyle(color: AppColors.gold, fontSize: 10, letterSpacing: 1.5)),
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
            const SizedBox(height: 5),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Week ', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  TextSpan(text: '3', style: TextStyle(fontSize: 11, color: AppColors.gold2, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' of 12 · 25% complete', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 19, letterSpacing: 2, color: AppColors.text)),
    );
  }

  Widget _buildChartCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sessions per week', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text)),
          const Text('Last 7 weeks · goal: 6/week', style: TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 18),
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(0.5, 'W1'),
                _buildBar(0.66, 'W2'),
                _buildBar(0.83, 'W3'),
                _buildBar(0.66, 'W4'),
                _buildBar(1.0, 'W5'),
                _buildBar(0.83, 'W6'),
                _buildBar(0.5, 'W7', isHighlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double pct, String label, {bool isHighlight = false}) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: 15,
            decoration: BoxDecoration(color: AppColors.background3, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80 * pct,
              decoration: BoxDecoration(
                color: isHighlight ? AppColors.gold : AppColors.gold.withOpacity(0.35),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
      ],
    );
  }

  Widget _buildStreakRow() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: List.generate(28, (index) {
          String status = 'done';
          if (index % 7 == 4) status = 'skip';
          if (index == 27) status = 'today';
          return _buildStreakDay(days[index % 7], status);
        }),
      ),
    );
  }

  Widget _buildStreakDay(String day, String status) {
    Color bg = AppColors.background;
    Color text = AppColors.dim;
    BoxBorder? border = Border.all(color: AppColors.border);

    if (status == 'done') {
      bg = AppColors.gold3;
      text = AppColors.gold2;
      border = Border.all(color: AppColors.gold.withOpacity(0.3));
    } else if (status == 'today') {
      bg = AppColors.gold;
      text = Colors.black;
      border = null;
    } else if (status == 'skip') {
      bg = AppColors.background3;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: border),
      alignment: Alignment.center,
      child: Text(day, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text)),
    );
  }

  Widget _buildAchievements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          _buildAchItem('🏆', 'First Sweat', 'Completed your first session', true),
          _buildAchItem('🔥', 'On Fire', '7-day training streak', true),
          _buildAchItem('💪', 'Ironclad', 'Lifted 1 tonne in a week', true),
          _buildAchItem('🥇', 'Champion', 'Complete a full 12-week program', false),
        ],
      ),
    );
  }

  Widget _buildAchItem(String icon, String title, String desc, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.5,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: isUnlocked ? AppColors.gold3 : AppColors.background3, borderRadius: BorderRadius.circular(10)),
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
            if (!isUnlocked) const Icon(Icons.lock_outline, size: 14, color: AppColors.dim),
          ],
        ),
      ),
    );
  }
}
