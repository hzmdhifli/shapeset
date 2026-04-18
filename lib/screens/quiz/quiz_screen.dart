import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../../models/mock_data.dart';
import '../detail/program_detail_screen.dart';
import '../../services/localization_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentStep = 0;
  final Map<int, String> _answers = {};

  List<QuizStep> _getSteps(BuildContext context) => [
    QuizStep(
      question: L10n.s(context, 'quiz_title'),
      subtext: L10n.s(context, 'goal_sub'),
      options: [
        QuizOption(title: L10n.s(context, 'goal_muscle'), sub: L10n.s(context, 'goal_muscle_sub'), icon: "💪", value: "muscle"),
        QuizOption(title: L10n.s(context, 'goal_fat'), sub: L10n.s(context, 'goal_fat_sub'), icon: "🔥", value: "loss"),
        QuizOption(title: L10n.s(context, 'goal_endurance'), sub: L10n.s(context, 'goal_endurance_sub'), icon: "🏃", value: "endurance"),
        QuizOption(title: L10n.s(context, 'goal_performance'), sub: L10n.s(context, 'goal_performance_sub'), icon: "⚡", value: "performance"),
      ],
    ),
    QuizStep(
      question: L10n.s(context, 'focus_areas'),
      subtext: L10n.s(context, 'hero_subtitle'),
      options: [
        QuizOption(title: L10n.s(context, 'chest_day'), sub: "Maximum push power", icon: "👕", value: "Chest"),
        QuizOption(title: L10n.s(context, 'back'), sub: "The V-taper look", icon: "🎒", value: "Back"),
        QuizOption(title: L10n.s(context, 'exercises'), sub: "Explosive movement", icon: "🦵", value: "Legs"),
        QuizOption(title: "Arms", sub: "Peak bicep & tricep", icon: "🦾", value: "Arms"),
      ],
    ),
    QuizStep(
      question: L10n.s(context, 'level_title'),
      subtext: L10n.s(context, 'level_sub'),
      options: [
        QuizOption(title: L10n.s(context, 'exp_beg'), sub: L10n.s(context, 'exp_beg_sub'), icon: "🌱", value: "beg"),
        QuizOption(title: L10n.s(context, 'exp_int'), sub: L10n.s(context, 'exp_int_sub'), icon: "🏋️", value: "int"),
        QuizOption(title: L10n.s(context, 'exp_adv'), sub: L10n.s(context, 'exp_adv_sub'), icon: "🦾", value: "adv"),
      ],
    ),
    QuizStep(
      question: L10n.s(context, 'days_title'),
      subtext: L10n.s(context, 'days_sub'),
      options: [
        QuizOption(title: L10n.s(context, 'time_3'), sub: L10n.s(context, 'time_3_sub'), icon: "📅", value: "3"),
        QuizOption(title: L10n.s(context, 'time_5'), sub: L10n.s(context, 'time_5_sub'), icon: "📆", value: "5"),
        QuizOption(title: L10n.s(context, 'time_6'), sub: L10n.s(context, 'time_6_sub'), icon: "🔥", value: "6"),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps(context);
    if (_currentStep >= steps.length) {
      return _buildResult();
    }

    final step = steps[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(L10n.s(context, 'quiz_title'), style: const TextStyle(fontFamily: 'Bebas Neue', letterSpacing: 2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(steps.length),
            const SizedBox(height: 28),
            Text(step.question, style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 26, letterSpacing: 2, height: 1.15)),
            const SizedBox(height: 6),
            Text(step.subtext, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.6)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: step.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final opt = step.options[index];
                  final isSelected = _answers[_currentStep] == opt.value;
                  return _buildOption(opt, isSelected);
                },
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentStep--),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            L10n.s(context, 'back').toUpperCase(),
                            style: const TextStyle(color: AppColors.muted, fontFamily: 'Bebas Neue', fontSize: 13, letterSpacing: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _answers.containsKey(_currentStep) ? () => setState(() => _currentStep++) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        disabledBackgroundColor: AppColors.gold.withOpacity(0.3),
                      ),
                      child: Text(
                        _currentStep == steps.length - 1 ? L10n.s(context, 'quiz_match') : L10n.s(context, 'quiz_continue'),
                        style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int totalSteps) {
    return Row(
      children: List.generate(totalSteps + 1, (index) {
        final isDone = index <= _currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            height: 3,
            decoration: BoxDecoration(
              color: isDone ? AppColors.gold : AppColors.border2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOption(QuizOption opt, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _answers[_currentStep] = opt.value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1A10) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.gold : AppColors.border2),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.gold.withOpacity(0.1) : AppColors.background3,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(opt.icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opt.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text)),
                  Text(opt.sub, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final goal = _answers[0] ?? 'muscle';
    final focus = _answers[1] ?? 'Chest';
    
    // First try to match by Tags (Muscle Focus)
    Program match = mockPrograms.firstWhere(
      (p) => p.tags.any((tag) => tag.toLowerCase().contains(focus.toLowerCase())),
      orElse: () {
        // Fallback to Goal match
        return mockPrograms.firstWhere(
          (p) => p.type.toString().split('.').last == goal,
          orElse: () => mockPrograms[0],
        );
      },
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💪', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(L10n.s(context, 'quiz_result_label'), style: const TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(
                match.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 34, color: AppColors.gold, letterSpacing: 3),
              ),
              const SizedBox(height: 24),
              Text(
                L10n.s(context, 'quiz_result_desc').replaceAll('{name}', match.name),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.7),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProgramDetailScreen(program: match)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(L10n.s(context, 'view_program'), style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() {
                  _currentStep = 0;
                  _answers.clear();
                }),
                child: Text(L10n.s(context, 'retake_quiz'), style: const TextStyle(color: AppColors.muted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizStep {
  final String question;
  final String subtext;
  final List<QuizOption> options;
  QuizStep({required this.question, required this.subtext, required this.options});
}

class QuizOption {
  final String title;
  final String sub;
  final String icon;
  final String value;
  QuizOption({required this.title, required this.sub, required this.icon, required this.value});
}
