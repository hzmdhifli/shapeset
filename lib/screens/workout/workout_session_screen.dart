import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../../main.dart';
import '../../services/localization_service.dart';
import '../../models/mock_data.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final List<WorkoutExercise> exercises;
  final String sessionTitle;

  const WorkoutSessionScreen({
    super.key, 
    required this.exercises,
    required this.sessionTitle,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> with SingleTickerProviderStateMixin {
  int _currentExIndex = 0;
  int _secondsRemaining = 0;
  int _maxSeconds = 60;
  Timer? _timer;
  late List<bool> _completedSets;
  
  bool _isExerciseRunning = false;
  bool _isResting = false;
  int _activeSetIndex = -1; // -1 means no set started yet
  bool _isFlashing = false;
  bool _isPaused = false;
  late AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _completedSets = List.filled(10, false);
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _flashController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _flashController.forward();
        }
      });
  }

  void _startTimer() {
    _timer?.cancel();
    _isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
          if (_isExerciseRunning && _secondsRemaining <= 10) {
            _isFlashing = true;
            if (!_flashController.isAnimating) _flashController.forward();
          } else {
            _isFlashing = false;
          }
        });
      } else {
        _timer?.cancel();
        _handleTimerFinished();
      }
    });
  }

  void _handleTimerFinished() {
    if (_isExerciseRunning) {
      setState(() {
        _isExerciseRunning = false;
        _completedSets[_activeSetIndex] = true;
        _isResting = true;
        _isFlashing = false;
        _flashController.stop();
        _maxSeconds = 90;
        _secondsRemaining = 90;
      });
      _startTimer();
    } else if (_isResting) {
      setState(() {
        _isResting = false;
        _isFlashing = false;
        _flashController.stop();
        _secondsRemaining = 0;
      });
      _showReadyDialog();
    }
  }

  void _togglePause() {
    if (!_isExerciseRunning && !_isResting) return;
    
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _timer?.cancel();
        _flashController.stop();
      } else {
        _startTimer();
        if (_isFlashing) _flashController.forward();
      }
    });
  }

  void _startSet() {
    setState(() {
      _isPaused = false;
      if (_activeSetIndex < 0) _activeSetIndex = 0;
      _isExerciseRunning = true;
      _isResting = false;
      _isFlashing = false;
      _maxSeconds = 60; 
      _secondsRemaining = 60;
    });
    _startTimer();
  }

  void _showReadyDialog() {
    final int nextSet = _activeSetIndex + 2;
    final int setsCount = _parseSets(widget.exercises[_currentExIndex].detail);

    if (nextSet > setsCount) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise Complete! Click next to continue.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          L10n.s(context, 'rest_over'),
          style: GoogleFonts.bebasNeue(color: AppColors.gold, fontSize: 24, letterSpacing: 2),
        ),
        content: Text(
          L10n.s(context, 'ready_for_set').replaceAll('{num}', nextSet.toString()),
          style: const TextStyle(color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _activeSetIndex++);
              _startSet();
            },
            child: Text(L10n.s(context, 'yes_start_set'), style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  int _parseSets(String detail) {
    try {
      // Handles "3 sets / 8-12 reps" or "3 sets · 8-12 reps"
      final setsMatch = RegExp(r'(\d+)\s*set').firstMatch(detail.toLowerCase());
      if (setsMatch != null) return int.parse(setsMatch.group(1)!);
      
      // Handles "3x8-12"
      final xMatch = RegExp(r'(\d+)\s*[x×]\s*').firstMatch(detail.toLowerCase());
      if (xMatch != null) return int.parse(xMatch.group(1)!);
      
      return 4;
    } catch (_) {
      return 4;
    }
  }

  String _parseReps(String detail) {
    try {
      // Handles "3 sets · 8-12 reps" -> "8-12 reps"
      if (detail.contains('·')) return detail.split('·')[1].trim();
      if (detail.contains('/')) return detail.split('/')[1].trim();
      
      // Handles "3x8-12" -> "8-12"
      final xMatch = RegExp(r'\d+\s*[x×]\s*(.*)').firstMatch(detail);
      if (xMatch != null) return xMatch.group(1)!.trim();
      
      return detail;
    } catch (_) {
      return detail;
    }
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

  @override
  void dispose() {
    _timer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.exercises;
    if (exercises.isEmpty || _currentExIndex >= exercises.length) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            L10n.s(context, 'no_athletes'), 
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
      );
    }
    
    final exercise = exercises[_currentExIndex];
    final progress = (_currentExIndex + 1) / exercises.length;
    final int setsCount = _parseSets(exercise.detail);
    final String muscleGroup = _getMuscleGroup(exercise.name);

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
                    _buildMuscleIndicator(muscleGroup),
                    _buildTimerSection(),
                    _buildExerciseCard(context, exercise, setsCount, muscleGroup),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Container(
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
                                      color: Colors.white.withOpacity(0.8),
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
                    ),
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

  String _getMuscleGroup(String exerciseName) {
    return exerciseToMuscle[exerciseName] ?? 'Strength';
  }

  Widget _buildMuscleIndicator(String muscle) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fitness_center, color: AppColors.gold, size: 14),
          const SizedBox(width: 8),
          Text(
            muscle.toUpperCase(),
            style: const TextStyle(
              color: AppColors.gold,
              fontFamily: 'Bebas Neue',
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back, color: AppColors.muted, size: 20),
                const SizedBox(width: 6),
                Text(L10n.s(context, 'end_session'), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.sessionTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Bebas Neue', 
                fontSize: 16, 
                letterSpacing: 2, 
                color: AppColors.text,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 80), // Keep for visual balance, or better use a dummy invisible back button
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
    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        final double opacity = _isFlashing ? _flashController.value : 1.0;
        final Color timerColor = _isFlashing ? Colors.red : (_isResting ? Colors.blue : AppColors.gold);
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Text(
                _isPaused 
                    ? L10n.s(context, 'paused').toUpperCase()
                    : (_isResting ? L10n.s(context, 'resting') : (_isExerciseRunning ? L10n.s(context, 'performing_set') : L10n.s(context, 'ready_to_start'))),
                style: GoogleFonts.bebasNeue(
                  fontSize: 16,
                  color: _isPaused ? AppColors.gold : (_isResting ? Colors.blue : AppColors.muted),
                  letterSpacing: 2,
                ),
              ),
              if (_isResting) ...[
                const SizedBox(height: 4),
                Text(
                  "Hey, Get some water",
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.blue.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _togglePause,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: _maxSeconds > 0 ? _secondsRemaining / _maxSeconds : 0,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isPaused ? AppColors.gold.withOpacity(0.3) : timerColor.withOpacity(opacity)
                        ),
                      ),
                    ),
                    _isExerciseRunning || _isResting
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isPaused)
                              const Icon(Icons.play_arrow, color: AppColors.gold, size: 30),
                            Text(
                              '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontFamily: 'Bebas Neue',
                                fontSize: _isPaused ? 32 : 42,
                                color: _isPaused ? AppColors.gold : timerColor.withOpacity(opacity),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: _startSet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(32),
                          ),
                          child: Text(
                            L10n.s(context, 'start_set'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontFamily: 'Bebas Neue', color: Colors.black, fontSize: 14, letterSpacing: 1),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseCard(BuildContext context, WorkoutExercise exercise, int setsCount, String muscleGroup) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.sessionTitle} · $muscleGroup'.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: 1.5)),
              if (_isExerciseRunning)
                const Icon(Icons.flash_on, color: AppColors.gold, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: (exercise.formGifUrl != null && exercise.formGifUrl!.isNotEmpty)
                ? () => _launchURL(exercise.formGifUrl!)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name.toUpperCase(), 
                    style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 26, color: AppColors.text, letterSpacing: 2)
                  ),
                ),
                if (exercise.formGifUrl != null && exercise.formGifUrl!.isNotEmpty)
                  _buildSimpleFormButton(exercise.formGifUrl!),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildExerciseStats(context, exercise, setsCount),
          const SizedBox(height: 18),
          _buildSetsList(context, exercise, setsCount),
          const SizedBox(height: 18),
          _buildTip('Focus on your $muscleGroup muscles. Ensure controlled movement throughout the entire range of motion.'),
        ],
      ),
    );
  }

  Widget _buildSimpleFormButton(String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill, color: AppColors.gold, size: 14),
          const SizedBox(width: 6),
          Text(
            'FORM',
            style: GoogleFonts.bebasNeue(
              color: AppColors.gold,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStats(BuildContext context, WorkoutExercise exercise, int setsCount) {
    return Row(
      children: [
        Expanded(child: _buildExStatBox(setsCount.toString(), L10n.s(context, 'sets'))),
        const SizedBox(width: 8),
        Expanded(child: _buildExStatBox(_parseReps(exercise.detail), L10n.s(context, 'reps'))),
        const SizedBox(width: 8),
        Expanded(child: _buildExStatBox('90s', L10n.s(context, 'rest'))),
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
          Text(value, style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 18, color: AppColors.text, letterSpacing: 1)),
          Text(label, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _buildSetsList(BuildContext context, WorkoutExercise exercise, int setsCount) {
    final reps = _parseReps(exercise.detail);
    return Column(
      children: List.generate(setsCount, (index) {
        final bool isActive = _activeSetIndex == index;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.gold.withOpacity(0.1) : AppColors.background3,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: AppColors.gold.withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              Text('${L10n.s(context, 'set')} ${index + 1}', 
                style: TextStyle(
                  fontSize: 11, 
                  color: isActive ? AppColors.gold : AppColors.dim,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                )
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(reps, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.text))),
              if (_completedSets[index])
                const Icon(Icons.check_circle, size: 20, color: AppColors.gold)
              else if (isActive)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold)),
                )
              else
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border2, width: 1.5),
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
      child: Text(tip, style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.6)),
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
                  _resetPhase();
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
                    _resetPhase();
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

  void _resetPhase() {
    _timer?.cancel();
    _isExerciseRunning = false;
    _isResting = false;
    _activeSetIndex = -1;
    _secondsRemaining = 0;
    _isFlashing = false;
    _flashController.stop();
    _isPaused = false;
    _completedSets.fillRange(0, _completedSets.length, false);
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
