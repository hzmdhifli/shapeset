import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/exercise.dart';
import '../../main.dart';
import '../../services/localization_service.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _currentExIndex = 0;
  int _secondsRemaining = 90;
  Timer? _timer;
  final List<bool> _completedSets = List.filled(5, false);

  List<Exercise> _getExercises(BuildContext context) => [
    Exercise(
      category: L10n.s(context, 'chest_day'),
      name: L10n.s(context, 'bench_press'),
      sets: 4,
      reps: '8–10',
      rest: '90s',
      tip: 'Keep shoulder blades retracted. Drive through the heels, elbows at 45°.',
    ),
    Exercise(
      category: L10n.s(context, 'fitness_profile'),
      name: L10n.s(context, 'overhead_press'),
      sets: 4,
      reps: '6–8',
      rest: '2min',
      tip: 'Brace your core. Avoid flaring elbows; press the bar slightly back overhead.',
    ),
    Exercise(
      category: L10n.s(context, 'active_program_label'),
      name: L10n.s(context, 'barbell_row'),
      sets: 4,
      reps: '8–10',
      rest: '90s',
      tip: 'Hinge at hips, keep spine neutral. Drive elbows to your hip, not behind.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _getExercises(context);
    if (_currentExIndex >= exercises.length) return const SizedBox.shrink();
    
    final exercise = exercises[_currentExIndex];
    final progress = (_currentExIndex + 1) / exercises.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildProgressSection(context, progress, exercises.length),
                    _buildTimerSection(),
                    _buildExerciseCard(context, exercise),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(context, exercises.length),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: AppColors.muted, size: 20),
                const SizedBox(width: 6),
                Text(L10n.s(context, 'end_session'), style: const TextStyle(color: AppColors.muted, fontSize: 13)),
              ],
            ),
          ),
          Text(
            L10n.s(context, 'training'),
            style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 2, color: AppColors.text),
          ),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, double progress, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${L10n.s(context, 'exercise')} ${_currentExIndex + 1} ${L10n.s(context, 'of')} $total', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              Text('0:00 ${L10n.s(context, 'elapsed')}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: _secondsRemaining / 90,
              strokeWidth: 6,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          Text(
            '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 28, color: AppColors.gold, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exercise.category.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(exercise.name, style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 28, color: AppColors.text, letterSpacing: 2)),
          const SizedBox(height: 14),
          _buildExerciseStats(context, exercise),
          const SizedBox(height: 18),
          _buildSetsList(context, exercise),
          const SizedBox(height: 18),
          _buildTip(exercise.tip),
        ],
      ),
    );
  }

  Widget _buildExerciseStats(BuildContext context, Exercise exercise) {
    return Row(
      children: [
        Expanded(child: _buildExStatBox(exercise.sets.toString(), L10n.s(context, 'sets'))),
        const SizedBox(width: 8),
        Expanded(child: _buildExStatBox(exercise.reps, L10n.s(context, 'reps'))),
        const SizedBox(width: 8),
        Expanded(child: _buildExStatBox(exercise.rest, L10n.s(context, 'rest'))),
      ],
    );
  }

  Widget _buildExStatBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.background3, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 20, color: AppColors.text, letterSpacing: 1)),
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _buildSetsList(BuildContext context, Exercise exercise) {
    return Column(
      children: List.generate(exercise.sets, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: AppColors.background3, borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Text('${L10n.s(context, 'set')} ${index + 1}', style: const TextStyle(fontSize: 11, color: AppColors.dim)),
              const SizedBox(width: 10),
              Expanded(child: Text('${exercise.reps} ${L10n.s(context, 'reps').toLowerCase()}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.text))),
              GestureDetector(
                onTap: () => setState(() => _completedSets[index] = !_completedSets[index]),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _completedSets[index] ? AppColors.gold : Colors.transparent,
                    border: Border.all(color: _completedSets[index] ? AppColors.gold : AppColors.border2, width: 1.5),
                  ),
                  child: _completedSets[index] ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTip(String tip) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.background3,
        border: Border(left: BorderSide(color: AppColors.gold, width: 2)),
        borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Text(tip, style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.6)),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, int totalCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          if (_currentExIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _currentExIndex--;
                  _secondsRemaining = 90;
                  _startTimer();
                  for (int i = 0; i < 5; i++) _completedSets[i] = false;
                }),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: AppColors.border2),
                ),
                child: Text('← ${L10n.s(context, 'prev')}', style: const TextStyle(color: AppColors.muted)),
              ),
            ),
          if (_currentExIndex > 0)
            const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentExIndex < totalCount - 1) {
                  setState(() {
                    _currentExIndex++;
                    _secondsRemaining = 90;
                    _startTimer();
                    for (int i = 0; i < 5; i++) _completedSets[i] = false;
                  });
                } else {
                  _showWorkoutDone();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _currentExIndex < totalCount - 1 ? '${L10n.s(context, 'next_exercise')} →' : L10n.s(context, 'finish_session'),
                style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 16, letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutDone() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutDoneScreen()),
    );
  }
}

class WorkoutDoneScreen extends StatelessWidget {
  const WorkoutDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 80),
        child: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              L10n.s(context, 'session_complete'),
              style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 32, letterSpacing: 3, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            Text(
              L10n.s(context, 'session_done_msg'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.7),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(L10n.s(context, 'view_my_progress'), style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (route) => false,
                );
              },
              child: Text(L10n.s(context, 'back_to_home'), style: const TextStyle(color: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }
}
