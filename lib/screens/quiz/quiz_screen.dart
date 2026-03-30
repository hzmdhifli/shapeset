import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../../models/mock_data.dart';
import '../detail/program_detail_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentStep = 0;
  final Map<int, String> _answers = {};

  final List<QuizStep> _steps = [
    QuizStep(
      question: "WHAT'S YOUR MAIN GOAL?",
      subtext: "This helps us match you with the athlete whose training philosophy fits you best.",
      options: [
        QuizOption(title: "Build Muscle & Strength", sub: "Hypertrophy, power, mass", icon: "💪", value: "muscle"),
        QuizOption(title: "Lose Fat & Get Lean", sub: "Burn calories, cut body fat", icon: "🔥", value: "loss"),
        QuizOption(title: "Build Endurance & Stamina", sub: "Cardio, running, long distance", icon: "🏃", value: "endurance"),
        QuizOption(title: "Athletic Performance", sub: "Speed, agility, sport-specific", icon: "⚡", value: "muscle"),
      ],
    ),
    QuizStep(
      question: "HOW DO YOU TRAIN NOW?",
      subtext: "Your current experience level shapes the intensity of your program.",
      options: [
        QuizOption(title: "Beginner", sub: "Under 1 year of training", icon: "🌱", value: "beg"),
        QuizOption(title: "Intermediate", sub: "1–3 years of consistent training", icon: "🏋️", value: "int"),
        QuizOption(title: "Advanced", sub: "3+ years, serious athlete", icon: "🦾", value: "adv"),
      ],
    ),
    QuizStep(
      question: "HOW MUCH TIME DO YOU HAVE?",
      subtext: "Be realistic. Consistency beats intensity every time.",
      options: [
        QuizOption(title: "3 Days a Week", sub: "Compact, efficient sessions", icon: "📅", value: "3"),
        QuizOption(title: "4–5 Days a Week", sub: "Balanced split training", icon: "📆", value: "5"),
        QuizOption(title: "6 Days a Week", sub: "Full commitment mode", icon: "🔥", value: "6"),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_currentStep >= _steps.length) {
      return _buildResult();
    }

    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.muted),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
        ),
        title: const Text('FIND YOUR MATCH', style: TextStyle(fontFamily: 'Bebas Neue', letterSpacing: 2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(),
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
            SizedBox(
              width: double.infinity,
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
                  _currentStep == _steps.length - 1 ? 'SEE MY MATCH →' : 'CONTINUE →',
                  style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(_steps.length + 1, (index) {
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
    final Program match = mockPrograms.firstWhere(
      (p) => p.type.toString().split('.').last == goal,
      orElse: () => mockPrograms[0],
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
              const Text('YOUR PERFECT MATCH', style: TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(
                match.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 34, color: AppColors.gold, letterSpacing: 3),
              ),
              const SizedBox(height: 24),
              Text(
                "Your drive for performance and muscle perfectly matches ${match.name}'s methodology.",
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
                  child: const Text('VIEW FULL PROGRAM →', style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => setState(() {
                  _currentStep = 0;
                  _answers.clear();
                }),
                child: const Text('Retake the Quiz', style: TextStyle(color: AppColors.muted)),
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
