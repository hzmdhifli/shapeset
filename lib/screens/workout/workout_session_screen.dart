import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../../main.dart';
import '../../services/localization_service.dart';
import '../../models/mock_data.dart';
import '../../services/workout_provider.dart';
import 'package:provider/provider.dart';
import '../../services/asset_resolver.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final List<WorkoutExercise> exercises;
  final String sessionTitle;
  final String programId;
  final String dayId;

  const WorkoutSessionScreen({
    super.key, 
    required this.exercises,
    required this.sessionTitle,
    required this.programId,
    required this.dayId,
  });

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
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
  late PageController _pageController;
  int _waterIntakeMl = 750;

  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentExIndex);
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (!_isPaused && (_isExerciseRunning || _isResting)) {
        _togglePause();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
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
        if (_activeSetIndex >= 0 && _activeSetIndex < _completedSets.length) {
          _completedSets[_activeSetIndex] = true;
        }
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
      if (_currentExIndex < widget.exercises.length - 1) {
        _updateExerciseIndex(_currentExIndex + 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.s(context, 'starting_ex').replaceAll('{name}', (L10n.s(context, 'exercise_${widget.exercises[_currentExIndex].name}') != 'exercise_${widget.exercises[_currentExIndex].name}' ? L10n.s(context, 'exercise_${widget.exercises[_currentExIndex].name}') : widget.exercises[_currentExIndex].name))),
            backgroundColor: AppColors.gold,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showWorkoutDone();
      }
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
      final setsMatch = RegExp(r'(\d+)\s*set').firstMatch(detail.toLowerCase());
      if (setsMatch != null) return int.parse(setsMatch.group(1)!);
      
      final xMatch = RegExp(r'(\d+)\s*[x×]\s*').firstMatch(detail.toLowerCase());
      if (xMatch != null) return int.parse(xMatch.group(1)!);
      
      return 4;
    } catch (_) {
      return 4;
    }
  }

  String _parseReps(String detail) {
    try {
      if (detail.contains('·')) return detail.split('·')[1].trim();
      if (detail.contains('/')) return detail.split('/')[1].trim();
      
      final xMatch = RegExp(r'\d+\s*[x×]\s*(.*)').firstMatch(detail);
      if (xMatch != null) return xMatch.group(1)!.trim();
      
      return detail;
    } catch (_) {
      return detail;
    }
  }

  Future<void> _launchURL(String url) async {
    if (!_isPaused && (_isExerciseRunning || _isResting)) {
      _togglePause();
    }

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
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _flashController.dispose();
    super.dispose();
  }

  void _showWorkoutDone() {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final Set<String> muscles = widget.exercises.map((ex) => _getMuscleGroup(ex.name)).toSet();

    workoutProvider.completeSession(CompletedSession(
      programId: widget.programId,
      dayId: widget.dayId,
      dayName: widget.sessionTitle,
      date: DateTime.now(),
      musclesTrained: muscles.toList(),
    ));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutDoneScreen()),
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

  String _getLocalizedDetail(String detail) {
    if (Localizations.localeOf(context).languageCode != 'ar') return detail;
    
    String result = detail;

    if (widget.programId == 'franco') {
      result = result.replaceAll(RegExp(r'supersets?:?\s*', caseSensitive: false), 'مجموعة شاملة من\n');
    } else {
      result = result.replaceAll(RegExp(r'supersets?:?\s*', caseSensitive: false), 'مجموعات ');
    }
    
    result = result.replaceAll(RegExp(r'To failure', caseSensitive: false), 'حتى الفشل العضلي');
    result = result.replaceAll(RegExp(r'100m Sprints', caseSensitive: false), 'سبرنت 100 متر');
    result = result.replaceAll(RegExp(r'1min HIIT', caseSensitive: false), '1 دقيقة HIIT');
    result = result.replaceAll(RegExp(r'45s/side', caseSensitive: false), '45 ثانية لكل جانب');
    result = result.replaceAll(RegExp(r'/leg', caseSensitive: false), ' لكل جانب');
    
    result = result.replaceAll(RegExp(r'\bsets?\b', caseSensitive: false), 'مجموعات');
    result = result.replaceAll(RegExp(r'\breps?\b', caseSensitive: false), 'تكرارًا');
    result = result.replaceAll(RegExp(r'\bto\b', caseSensitive: false), 'إلى');
    result = result.replaceAll(RegExp(r'failure', caseSensitive: false), 'فشل عضلي');
    result = result.replaceAll(RegExp(r'static hold', caseSensitive: false), 'ثبات استاتيكي');
    result = result.replaceAll(RegExp(r'dropset|drop set', caseSensitive: false), 'مجموعة تناقصية');
    result = result.replaceAll(RegExp(r'active recovery', caseSensitive: false), 'استشفاء نشط');
    result = result.replaceAll(RegExp(r'recovery', caseSensitive: false), 'استشفاء');
    result = result.replaceAll(RegExp(r'each side', caseSensitive: false), 'لكل جانب');
    result = result.replaceAll(RegExp(r'per side', caseSensitive: false), 'لكل جانب');
    result = result.replaceAll(RegExp(r'bodyweight', caseSensitive: false), 'وزن الجسم');
    result = result.replaceAll(RegExp(r'sec\.?', caseSensitive: false), 'ثانية');
    result = result.replaceAll(RegExp(r'\bmins?\b|minutes?', caseSensitive: false), 'دقيقة');
    result = result.replaceAll(RegExp(r'\brounds?\b', caseSensitive: false), 'جولات');
    result = result.replaceAll(RegExp(r'cardio', caseSensitive: false), 'كارديو');
    result = result.replaceAll(RegExp(r'to max', caseSensitive: false), 'إلى الحد الأقصى');
    
    if (result.contains(RegExp(r'\d+x\d+'))) {
      result = result.replaceAll('x', ' × ');
    }
    
    return result;
  }

  double _res(BuildContext context, double original) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 375.0;
    if (scale < 0.85) scale = 0.85;
    if (scale > 1.25) scale = 1.25;
    return original * scale;
  }

  String _getLocalizedDayName(BuildContext context, String dayName) {
    final nameLow = dayName.toLowerCase();
    
    if (nameLow.contains('chest') && nameLow.contains('tricep')) return L10n.s(context, 'workout_chest_triceps');
    if (nameLow.contains('back') && nameLow.contains('bicep')) return L10n.s(context, 'workout_back_biceps');
    if (nameLow.contains('chest') && nameLow.contains('back')) return L10n.s(context, 'workout_chest_back');
    if (nameLow.contains('leg')) return L10n.s(context, 'workout_legs');
    if (nameLow.contains('shoulder')) return L10n.s(context, 'workout_shoulders');
    if (nameLow.contains('push')) return L10n.s(context, 'workout_push');
    if (nameLow.contains('pull')) return L10n.s(context, 'workout_pull');
    if (nameLow.contains('upper')) return L10n.s(context, 'workout_upper');
    if (nameLow.contains('lower')) return L10n.s(context, 'workout_lower');
    if (nameLow.contains('full body')) return L10n.s(context, 'workout_full_body');
    if (nameLow.contains('glute')) return L10n.s(context, 'workout_glute_shaping');
    if (nameLow.contains('squat')) return L10n.s(context, 'workout_squat_day');
    if (nameLow.contains('deadlift')) return L10n.s(context, 'workout_deadlift_day');
    if (nameLow.contains('strength accessory')) return L10n.s(context, 'workout_strength_accessory');
    if (nameLow.contains('arm')) return L10n.s(context, 'workout_arm_day');
    if (nameLow.contains('rest')) return L10n.s(context, 'workout_rest_day');

    final key = 'workout_${dayName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_| _ $'), '')}';
    final localized = L10n.s(context, key);
    return localized != key ? localized : dayName;
  }

  bool get _isFemaleProgram {
    return [
      // Female Special Programs
      'athletic_lean', 'bikini_competition', 'powerlifter_female', 'sculpt_and_cardio',
      // Six Packs XY XX Programs
      'six_pack_foundation', 'six_pack_iron_serpent', 'six_pack_gravity_rebels',
      'six_pack_machine_uprising', 'six_pack_decline_conquer',
    ].contains(widget.programId);
  }

  void _updateExerciseIndex(int index) {
    if (index >= 0 && index < widget.exercises.length) {
      setState(() {
        _currentExIndex = index;
        _resetPhase();
      });
      if (_pageController.hasClients && _pageController.page!.round() != index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    if (index != _currentExIndex) {
      setState(() {
        _currentExIndex = index;
        _resetPhase();
      });
    }
  }

  void _nextExercise() {
    if (_currentExIndex < widget.exercises.length - 1) {
      _updateExerciseIndex(_currentExIndex + 1);
    } else {
      _showWorkoutDone();
    }
  }

  void _prevExercise() {
    if (_currentExIndex > 0) {
      _updateExerciseIndex(_currentExIndex - 1);
    }
  }

  Widget _buildFemaleWorkoutScreen(BuildContext context) {
    final exercises = widget.exercises;
    final exercise = exercises[_currentExIndex];
    final int setsCount = _parseSets(exercise.detail);
    final String muscleGroup = _getMuscleGroup(exercise.name);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildFemaleHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFemaleExerciseTitleRow(exercise),
                      const SizedBox(height: 16),
                      _buildFemaleExerciseMediaCard(exercises, muscleGroup),
                      const SizedBox(height: 20),
                      _buildStatusBanner(exercise, setsCount),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _buildRestTimerCard()),
                          const SizedBox(width: 14),
                          Expanded(child: _buildHydrationCard()),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPrimaryActionButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFemaleHeader(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.muted, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getLocalizedDayName(context, widget.sessionTitle).toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.bebasNeue(
                  fontSize: 18,
                  letterSpacing: 2,
                  color: AppColors.text,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 38),
          ],
        ),
      ),
    );
  }

  Widget _buildFemaleExerciseTitleRow(WorkoutExercise exercise) {
    final sets = _parseSets(exercise.detail);
    final reps = _parseReps(exercise.detail);
    final String cleanDayId = widget.dayId.toLowerCase().replaceAll('day', '').trim();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "WORKOUT DAY $cleanDayId".toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.muted,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (L10n.s(context, 'exercise_${exercise.name}') != 'exercise_${exercise.name}' 
                    ? L10n.s(context, 'exercise_${exercise.name}') 
                    : exercise.name).toUpperCase(),
                style: GoogleFonts.bebasNeue(
                  fontSize: 26,
                  color: AppColors.text,
                  letterSpacing: 1.5,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3DE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$sets x $reps",
            style: GoogleFonts.bebasNeue(
              color: const Color(0xFF27500A),
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFemaleExerciseMediaCard(List<WorkoutExercise> exercises, String muscleGroup) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: exercises.length,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, idx) {
              return ExerciseMediaWidget(
                exercise: exercises[idx],
                muscleGroup: muscleGroup,
                isFemaleProgram: true,
                // Female special program now opens straight into the form media.
                showVideoDirectly: true,
              );
            },
          ),
          if (_currentExIndex > 0)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _prevExercise,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.keyboard_arrow_left_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          if (_currentExIndex < exercises.length - 1)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _nextExercise,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(exercises.length, (idx) {
                final bool isCurrent = idx == _currentExIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: isCurrent ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: isCurrent ? Colors.white : Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendExerciseMediaCard(List<WorkoutExercise> exercises, String muscleGroup) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: exercises.length,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, idx) {
              return ExerciseMediaWidget(
                exercise: exercises[idx],
                muscleGroup: muscleGroup,
                isFemaleProgram: false,
              );
            },
          ),
          if (_currentExIndex > 0)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _prevExercise,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.keyboard_arrow_left_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          if (_currentExIndex < exercises.length - 1)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _nextExercise,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(exercises.length, (idx) {
                final bool isCurrent = idx == _currentExIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: isCurrent ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: isCurrent ? AppColors.gold : Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(WorkoutExercise exercise, int setsCount) {
    final int currentSet = _activeSetIndex + 1;
    String statusTitle = "Ready to start";
    String statusTime = "0:00";
    double progress = 1.0;
    Color progressColor = AppColors.gold;

    if (_isPaused) {
      statusTitle = "Paused";
      statusTime = '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}';
      progress = _maxSeconds > 0 ? (_secondsRemaining / _maxSeconds) : 0.0;
      progressColor = AppColors.gold;
    } else if (_isResting) {
      statusTitle = "Resting";
      statusTime = '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}';
      progress = _maxSeconds > 0 ? (_secondsRemaining / _maxSeconds) : 0.0;
      progressColor = Colors.blue.shade400;
    } else if (_isExerciseRunning) {
      statusTitle = "Performing Set $currentSet / $setsCount";
      statusTime = '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}';
      progress = _maxSeconds > 0 ? (_secondsRemaining / _maxSeconds) : 0.0;
      progressColor = AppColors.gold;
    } else if (currentSet > 0) {
      statusTitle = "Set $currentSet / $setsCount Complete";
      statusTime = "Done";
      progress = 1.0;
      progressColor = AppColors.gold;
    } else {
      statusTitle = "Start Set 1 / $setsCount";
      statusTime = "Ready";
      progress = 0.0;
      progressColor = AppColors.gold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: progressColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusTitle.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                statusTime,
                style: GoogleFonts.bebasNeue(
                  fontSize: 16,
                  color: progressColor,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimerCard() {
    final double value = _maxSeconds > 0 ? _secondsRemaining / _maxSeconds : 0.0;
    final String timerText = '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}';
    
    return GestureDetector(
      onTap: () {
        if (_isExerciseRunning || _isResting) {
          _togglePause();
        } else {
          _startSet();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.s(context, 'rest_timer') != 'rest_timer' ? L10n.s(context, 'rest_timer').toUpperCase() : 'REST TIMER',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppColors.muted,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isResting ? Colors.blue.shade400 : AppColors.gold
                        ),
                      ),
                    ),
                    Icon(
                      _isPaused || (!_isExerciseRunning && !_isResting)
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      color: _isResting ? Colors.blue.shade400 : AppColors.gold,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (_isExerciseRunning || _isResting) ? timerText : '00:00',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 22,
                          color: AppColors.text,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        _isPaused ? 'paused' : (_isResting ? 'resting' : 'idle'),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHydrationCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _waterIntakeMl += 250;
          if (_waterIntakeMl > 2000) _waterIntakeMl = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.s(context, 'hydration') != 'hydration' ? L10n.s(context, 'hydration').toUpperCase() : 'HYDRATION',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppColors.muted,
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 44 * (_waterIntakeMl / 2000.0).clamp(0.0, 1.0),
                        width: double.infinity,
                        color: Colors.blue.shade400,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_waterIntakeMl',
                        style: GoogleFonts.bebasNeue(
                          fontSize: 22,
                          color: AppColors.text,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'ml',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton() {
    final String label = _isResting 
        ? L10n.s(context, 'skip_rest_btn').toUpperCase() 
        : (_isExerciseRunning 
            ? L10n.s(context, 'complete_set_btn').toUpperCase() 
            : L10n.s(context, 'start_set').toUpperCase());
            
    final Color buttonColor = _isResting 
        ? Colors.blue.shade600 
        : AppColors.gold;
        
    final Color textColor = _isResting 
        ? Colors.white 
        : Colors.black;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          if (!_isExerciseRunning && !_isResting) {
            _startSet();
          } else {
            _handleTimerFinished();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.bebasNeue(
            fontSize: 18,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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

    if (_isFemaleProgram) {
      return _buildFemaleWorkoutScreen(context);
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
            // Top Bar Header
            Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_rounded, color: AppColors.muted, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            L10n.s(context, 'end_session') != 'end_session' ? L10n.s(context, 'end_session').toUpperCase() : 'FIN DE SESSION',
                            style: GoogleFonts.bebasNeue(color: AppColors.muted, fontSize: _res(context, 14), letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.sessionTitle.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bebasNeue(
                          fontSize: _res(context, 16), 
                          letterSpacing: 2, 
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),
            
            // Progress Indicator Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Exercice ${_currentExIndex + 1} sur ${exercises.length}', style: TextStyle(color: AppColors.muted, fontSize: _res(context, 11))),
                      Text('${_elapsedSeconds ~/ 60}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')} écoulé', style: TextStyle(color: AppColors.muted, fontSize: _res(context, 11))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Scrollable Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: [
                      // Video Media Component with navigation arrows
                      _buildLegendExerciseMediaCard(exercises, muscleGroup),
                      const SizedBox(height: 16),

                      // Status & Rest Timer Banner
                      _buildStatusBanner(exercise, setsCount),
                      const SizedBox(height: 16),
                      
                      // Two Yellow Action Buttons Row (start/pause/resume ▶ | hydration 💧 water)
                      _buildTopYellowButtonsRow(context),
                      const SizedBox(height: 18),
                      
                      // Lower Exercise Detail Card
                      _buildLowerExerciseCard(context, exercise, setsCount, muscleGroup),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopYellowButtonsRow(BuildContext context) {
    String buttonText = 'START';
    IconData buttonIcon = Icons.play_arrow_rounded;

    if (_isPaused) {
      buttonText = 'RESUME';
      buttonIcon = Icons.play_arrow_rounded;
    } else if (_isExerciseRunning || _isResting) {
      buttonText = 'PAUSE';
      buttonIcon = Icons.pause_rounded;
    } else {
      buttonText = 'START';
      buttonIcon = Icons.play_arrow_rounded;
    }

    return Row(
      children: [
        // Left Yellow Button: start / pause / resume
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (!_isExerciseRunning && !_isResting) {
                _startSet();
              } else {
                _togglePause();
              }
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonText,
                    style: GoogleFonts.bebasNeue(
                      color: Colors.black,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    buttonIcon,
                    color: Colors.black,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Right Yellow Button: hydration 💧 water
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _waterIntakeMl += 250;
                if (_waterIntakeMl > 2000) _waterIntakeMl = 0;
              });
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'HYDRATION',
                    style: GoogleFonts.bebasNeue(
                      color: Colors.black,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.water_drop_rounded,
                    color: Colors.black,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_waterIntakeMl}ML',
                    style: GoogleFonts.dmSans(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLowerExerciseCard(BuildContext context, WorkoutExercise exercise, int setsCount, String muscleGroup) {
    final String cleanDayId = widget.dayId.toLowerCase().replaceAll('day', '').trim();
    final repsStr = _getLocalizedDetail(_parseReps(exercise.detail));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "WORKOUT DAY $cleanDayId · $muscleGroup".toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.muted,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isExerciseRunning)
                const Icon(Icons.flash_on, color: AppColors.gold, size: 14),
            ],
          ),
          const SizedBox(height: 6),

          // Exercise Title & Play Button
          Row(
            children: [
              Expanded(
                child: Text(
                  (L10n.s(context, 'exercise_${exercise.name}') != 'exercise_${exercise.name}' 
                      ? L10n.s(context, 'exercise_${exercise.name}') 
                      : exercise.name).toUpperCase(),
                  style: GoogleFonts.bebasNeue(
                    fontSize: 24,
                    color: AppColors.text,
                    letterSpacing: 1.5,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (!_isExerciseRunning && !_isResting) {
                    _startSet();
                  } else {
                    _togglePause();
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                  ),
                  child: Icon(
                    (_isExerciseRunning || _isResting) && !_isPaused
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.gold,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Metric Stat Boxes (SÉRIES, REPS, REPOS)
          Row(
            children: [
              Expanded(child: _buildMetricBox(setsCount.toString(), 'SÉRIES')),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricBox(repsStr, 'REPS')),
              const SizedBox(width: 8),
              Expanded(child: _buildMetricBox('90s', 'REPOS')),
            ],
          ),
          const SizedBox(height: 18),

          // Sets list
          Column(
            children: List.generate(setsCount, (index) {
              final bool isActive = _activeSetIndex == index;
              final bool isDone = _completedSets[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.gold.withOpacity(0.1) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: isActive ? Border.all(color: AppColors.gold.withOpacity(0.4)) : null,
                ),
                child: Row(
                  children: [
                    Text(
                      'SÉRIE ${index + 1}',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 14,
                        color: isActive ? AppColors.gold : AppColors.muted,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        repsStr,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _completedSets[index] = !_completedSets[index];
                        });
                      },
                      child: isDone
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 22)
                          : Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.muted, width: 1.5),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 18),

          // Full-width SUIVANT → Next Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _nextExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentExIndex < widget.exercises.length - 1 ? 'SUIVANT' : 'FIN DE SESSION',
                    style: GoogleFonts.bebasNeue(
                      fontSize: 18,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.bebasNeue(
              fontSize: 18,
              color: AppColors.text,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: AppColors.muted,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
          Icon(Icons.fitness_center, color: AppColors.gold, size: _res(context, 14)),
          const SizedBox(width: 8),
          Text(
            (L10n.s(context, 'muscle_${muscle.toLowerCase()}') != 'muscle_${muscle.toLowerCase()}' 
                ? L10n.s(context, 'muscle_${muscle.toLowerCase()}') 
                : (L10n.s(context, muscle) != muscle ? L10n.s(context, muscle) : muscle)).toUpperCase(),
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: 'Bebas Neue',
              fontSize: _res(context, 16),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Directionality(
                  textDirection: TextDirection.ltr,
                  child: Icon(Icons.arrow_back, color: AppColors.muted, size: 20),
                ),
                  const SizedBox(width: 6),
                  Text(L10n.s(context, 'end_session'), style: TextStyle(color: AppColors.muted, fontSize: _res(context, 12))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: (() {
                final String displayTitle = (widget.sessionTitle.toLowerCase().contains('day') && !widget.sessionTitle.contains(' ')) 
                    ? L10n.s(context, 'day_label').replaceAll('{num}', widget.sessionTitle.replaceAll(RegExp(r'[^0-9]'), '')).toUpperCase()
                    : _getLocalizedDayName(context, widget.sessionTitle).toUpperCase();
                
                return Text(
                  displayTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Bebas Neue', 
                    fontSize: _res(context, displayTitle.length > 20 ? 12 : (displayTitle.length > 15 ? 14 : 16)), 
                    letterSpacing: displayTitle.length > 18 ? 1.0 : 2, 
                    color: AppColors.text,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                );
              })(),
            ),
            SizedBox(width: _res(context, 80)), // Keep for visual balance
          ],
        ),
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
              Text('${L10n.s(context, 'exercise')} ${_currentExIndex + 1} ${L10n.s(context, 'of')} $total', style: TextStyle(color: AppColors.muted, fontSize: _res(context, 11))),
              Text('0:00 ${L10n.s(context, 'elapsed')}', style: TextStyle(color: AppColors.muted, fontSize: _res(context, 11))),
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
                  L10n.s(context, 'water_reminder'),
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
                      width: _res(context, 140),
                      height: _res(context, 140),
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
                              Icon(Icons.play_arrow, color: AppColors.gold, size: _res(context, 30)),
                            Text(
                              '${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontFamily: 'Bebas Neue',
                                fontSize: _res(context, _isPaused ? 32 : 42),
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
                            padding: EdgeInsets.all(_res(context, 32)),
                          ),
                          child: Text(
                            L10n.s(context, 'start_set'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: 'Bebas Neue', color: Colors.black, fontSize: _res(context, 14), letterSpacing: 1),
                          ),
                        ),
                  ],
                ),
              ),
              if (_isExerciseRunning || _isResting) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _handleTimerFinished,
                  icon: Icon(Icons.skip_next, color: _isResting ? Colors.blue : AppColors.gold, size: 20),
                  label: Text(
                    (_isExerciseRunning ? L10n.s(context, 'complete_set_btn') : L10n.s(context, 'skip_rest_btn')).toUpperCase(),
                    style: GoogleFonts.bebasNeue(
                      color: _isResting ? Colors.blue : AppColors.gold,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    backgroundColor: (_isResting ? Colors.blue : AppColors.gold).withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],
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
              Text('${widget.sessionTitle} · ${L10n.s(context, 'muscle_${muscleGroup.toLowerCase()}') != 'muscle_${muscleGroup.toLowerCase()}' ? L10n.s(context, 'muscle_${muscleGroup.toLowerCase()}') : muscleGroup}'.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: 1.5)),
              if (_isExerciseRunning)
                const Icon(Icons.flash_on, color: AppColors.gold, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: (exercise.formGifUrl != null && exercise.formGifUrl!.isNotEmpty)
                ? () => _launchURL(exercise.formGifUrl!)
                : null,
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    (L10n.s(context, 'exercise_${exercise.name}') != 'exercise_${exercise.name}' ? L10n.s(context, 'exercise_${exercise.name}') : exercise.name).toUpperCase(), 
                    style: TextStyle(
                      fontFamily: 'Bebas Neue', 
                      fontSize: _res(context, Localizations.localeOf(context).languageCode == 'ar' ? 20 : 18), 
                      color: AppColors.text, 
                      letterSpacing: Localizations.localeOf(context).languageCode == 'ar' ? 0.5 : 1.5,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
          _buildTip(L10n.s(context, 'focus_muscle_tip').replaceAll('{muscle}', L10n.s(context, 'muscle_${muscleGroup.toLowerCase()}') != 'muscle_${muscleGroup.toLowerCase()}' ? L10n.s(context, 'muscle_${muscleGroup.toLowerCase()}') : muscleGroup)),
        ],
      ),
    );
  }

  Widget _buildSimpleFormButton(String url) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: AppColors.gold,
        size: _res(context, 22),
      ),
    );
  }

  Widget _buildExerciseStats(BuildContext context, WorkoutExercise exercise, int setsCount) {
    return Row(
      children: [
        Expanded(child: _buildExStatBox(setsCount.toString(), L10n.s(context, 'sets'))),
        const SizedBox(width: 8),
        Expanded(child: _buildExStatBox(_getLocalizedDetail(_parseReps(exercise.detail)), L10n.s(context, 'reps'))),
        const SizedBox(width: 8),
        Expanded(child: _buildExStatBox(Localizations.localeOf(context).languageCode == 'ar' ? '90 ثانية' : '90s', L10n.s(context, 'rest'))),
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
          Text(
            value, 
            style: (Localizations.localeOf(context).languageCode == 'ar' ? GoogleFonts.dmSans() : GoogleFonts.bebasNeue()).copyWith(
              fontSize: _res(context, Localizations.localeOf(context).languageCode == 'ar' ? 14 : 18), 
              color: AppColors.text, 
              letterSpacing: 1,
            ),
          ),
          Text(
            label, 
            style: TextStyle(
              fontSize: _res(context, 9), 
              color: AppColors.muted,
              fontWeight: Localizations.localeOf(context).languageCode == 'ar' ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsList(BuildContext context, WorkoutExercise exercise, int setsCount) {
    final reps = _getLocalizedDetail(_parseReps(exercise.detail));
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
                  fontSize: _res(context, 11), 
                  color: isActive ? AppColors.gold : AppColors.dim,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                )
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(reps, style: TextStyle(fontSize: _res(context, Localizations.localeOf(context).languageCode == 'ar' ? 10 : 12), fontWeight: FontWeight.bold, color: AppColors.text))),
              if (_completedSets[index])
                Icon(Icons.check_circle, size: _res(context, 20), color: AppColors.gold)
              else if (isActive)
                SizedBox(
                  width: _res(context, 16),
                  height: _res(context, 16),
                  child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold)),
                )
              else
                Container(
                  width: _res(context, 20),
                  height: _res(context, 20),
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
      child: Text(tip, style: TextStyle(fontSize: _res(context, 11), color: AppColors.muted, height: 1.6)),
    );
  }

}

class ExerciseMediaWidget extends StatefulWidget {
  final WorkoutExercise exercise;
  final String muscleGroup;
  final bool isFemaleProgram;
  /// When true, skips the static-image/swipe-to-GIF UI and plays video directly.
  final bool showVideoDirectly;
  
  const ExerciseMediaWidget({
    super.key,
    required this.exercise,
    required this.muscleGroup,
    this.isFemaleProgram = false,
    this.showVideoDirectly = false,
  });

  @override
  State<ExerciseMediaWidget> createState() => _ExerciseMediaWidgetState();
}

class _ExerciseMediaWidgetState extends State<ExerciseMediaWidget> {
  bool _showGif = false;

  static const Map<String, String> _gifToPicMap = {
    '45_SIDE_BEND': '45_SIDE_BEND_pic.jpg',
    'ABS_HIP_THRU': 'ABS_HIP_THRU_pic.jpg',
    'ARNOLD_DB_PRESS': 'ARNOLD_DB_PRESS_pic.jpg',
    'BB_BSQT': 'PAUSE_SQT_pic.jpg',
    'BB_DL': 'BB_DL_pic.jpg',
    'BB_FSQ-1': 'BB_FSQ_pic.jpg',
    'BB_PRESS': 'BB_PRESS_pic.jpg',
    'BB_SPLIT_SQT': 'BB_SPLIT_SQT_pic.jpg',
    'CABLE_DONK_KICK': 'CABLE_DONK_KICK_pic.jpg',
    'CABLE_PULL_THRU': 'CABLE_PULL_THRU_pic.jpg',
    'CLIMB_STAIRS': 'CLIMB_STAIRS_pic.jpg',
    'DB_BO_LAT_RAISE': 'DB_BO_LAT_RAISE_pic.jpg',
    'DB_BULSPLIT_SQT': 'DB_BULSPLIT_SQT_pic.jpg',
    'DB_LAT_RAISE-1': 'DB_LAT_RAISE_pic.webp',
    'DB_LUNGE-2': 'DB_LUNGE-2_pic.jpg',
    'DB_RM_DL': 'RM_BB_DL_pic.jpg',
    'DB_SM_DL': 'KB_SM_DL_pic.jpg',
    'DB_STIFF_DL': 'DB_STIFF_DL_pic.jpg',
    'DONK_KICK': 'DONK_KICK_pic.jpg',
    'FACE_PULL-1': 'FACE_PULL_pic.jpg',
    'GLUTE_BRDG': 'GLUTE_BRDG_pic.jpg',
    'GLUTE_KB_MC': 'GLUTE_KB_MC_pic.jpg',
    'GOBLET_SQT': 'GOBLET_SQT_pic.jpg',
    'GOBLET_SQUAT': 'GOBLET_SQT_pic.jpg',
    'DUMBBELL_GOBLET_SQUAT': 'GOBLET_SQT_pic.jpg',
    'KETTLEBELL_GOBLET_SQUAT': 'GOBLET_SQT_pic.jpg',
    'HANG_LEG_RAIGE-1': 'HANG_LEG_RAIGE_pic.jpg',
    'HIP_ABD_MC': 'HIP_ABD_MC_pic.jpg',
    'HIP_THRUST_MAC': 'HIP_THRUST_MAC_pic.jpg',
    'JUMP_SQT': 'JUMP_SQT_pic.jpg',
    'JUMP_SQUAT': 'JUMP_SQT_pic.jpg',
    'BARBELL_JUMP_SQUAT': 'JUMP_SQT_pic.jpg',
    'KB_SM_DL': 'KB_SM_DL_pic.jpg',
    'KETTLEBELL_SUMO_DEADLIFT': 'KB_SM_DL_pic.jpg',
    'DUMBBELL_SUMO_DEADLIFT': 'KB_SM_DL_pic.jpg',
    'LAND_PRESS': 'LAND_PRESS_pic.jpg',
    'LEG_CURL': 'LEG_CURL_pic.jpg',
    'LEG_PRESS-1': 'LEG_PRESS_pic.jpg',
    'LYING_HIP_ABD': 'LYING_HIP_ABD_pic.jpg',
    'PAUSE_SQT': 'PAUSE_SQT_pic.jpg',
    'PISTOL_BOX_SQT': 'PISTOL_BOX_SQT_pic.jpg',
    'REV_LAT_PULL_DOWN': 'REV_LAT_PULL_DOWN_pic.jpg',
    'RM_BB_DL': 'RM_BB_DL_pic.jpg',
    'ROMANIAN_DEADLIFT': 'RM_BB_DL_pic.jpg',
    'DUMBBELL_ROMANIAN_DEADLIFT': 'RM_BB_DL_pic.jpg',
    'SIDE_CRUNCH': 'SIDE_CRUNCH_pic.jpg',
    'SIDE_LYING_CLAM': 'SIDE_LYING_CLAM_pic.png',
    'SIDE_PLANK': 'SIDE_PLANK_pic.jpg',
    'SL_GLUTE_BRDG': 'SL_GLUTE_BRDG_pic.jpg',
    'SM_BB_DL': 'SM_BB_DL_pic.jpg',
    'TRAP_DL-1': 'TRAP_DL_pic.jpg',
    'WEI_DEC_CRUNCH': 'WEI_DEC_CRUNCH_pic.jpg',
    'WEI_HIP_THRUST': 'WEI_HIP_THRUST_pic.jpg',
    'WEI_STEP_UP': 'WEI_STEP_UP_pic.jpg',
    'WEIGHTED_STEP_UP': 'WEI_STEP_UP_pic.jpg',
  };

  @override
  void didUpdateWidget(covariant ExerciseMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exercise.name != widget.exercise.name) {
      _showGif = false;
    }
  }

  String _getStaticImageForMuscle(String muscle) {
    switch (muscle.toLowerCase()) {
      case 'quads':
      case 'hamstrings':
      case 'legs':
      case 'leg':
      case 'glutes':
        return 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=800&auto=format&fit=crop';
      case 'biceps':
      case 'triceps':
      case 'arms':
      case 'arm':
        return 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=800&auto=format&fit=crop';
      case 'shoulder':
      case 'shoulders':
      case 'traps':
        return 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=800&auto=format&fit=crop';
      case 'chest':
        return 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=800&auto=format&fit=crop';
      case 'abs':
      case 'core':
        return 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop';
      case 'back':
        return 'https://images.unsplash.com/photo-1603387129239-01f4640156d9?q=80&w=800&auto=format&fit=crop';
      case 'cardio':
        return 'https://images.unsplash.com/photo-1538805060514-97d9cc17730c?q=80&w=800&auto=format&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?q=80&w=800&auto=format&fit=crop';
    }
  }

  Widget _buildMultiCandidateVideo({
    required List<String> candidateUrls,
    required Widget fallbackWidget,
  }) {
    return SmartExerciseVideoPlayer(
      candidateUrls: candidateUrls,
      fallbackWidget: fallbackWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String muscle = widget.muscleGroup;
    final String? gifUrl = widget.exercise.formGifUrl;

    String? gifFilename;
    String? picFilename;
    String? localPicAsset;
    String? localGifAsset;

    final String cleanExName = widget.exercise.name.toUpperCase().replaceAll(' ', '_').replaceAll('-', '_');
    if (gifUrl != null && gifUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(gifUrl);
        gifFilename = uri.pathSegments.last;
        if (gifFilename.isNotEmpty) {
          localGifAsset = 'assets/images/$gifFilename';
          final baseName = gifFilename.replaceAll(RegExp(r'\.(gif|mp4|webm)$', caseSensitive: false), '');
          final cleanBaseName = baseName.replaceAll(RegExp(r'-\d+$'), '');
          picFilename = _gifToPicMap[baseName] ?? _gifToPicMap[cleanBaseName] ?? _gifToPicMap[cleanExName] ?? '${cleanBaseName}_pic.jpg';
          localPicAsset = 'assets/images/$picFilename';
        }
      } catch (_) {}
    }

    if (gifFilename == null || gifFilename.isEmpty) {
      gifFilename = '$cleanExName.gif';
      picFilename = _gifToPicMap[cleanExName] ?? '${cleanExName}_pic.jpg';
      localGifAsset = 'assets/images/$gifFilename';
      localPicAsset = 'assets/images/$picFilename';
    }

    // Female Special Program: keep exact original static picture + swipe for gif behavior
    // Six Pack programs skip this and go straight to video (showVideoDirectly = true)
    if (widget.isFemaleProgram && !widget.showVideoDirectly) {
      Widget localOrMuscleFallbackPic;
      if (localPicAsset != null) {
        localOrMuscleFallbackPic = Image.asset(
          localPicAsset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.network(
            _getStaticImageForMuscle(muscle),
            headers: AssetResolver.supabaseHeaders,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Image.asset('assets/images/loading.gif', fit: BoxFit.cover);
            },
            errorBuilder: (context, error, stackTrace) => const NoInternetMediaWidget(),
          ),
        );
      } else {
        localOrMuscleFallbackPic = Image.network(
          _getStaticImageForMuscle(muscle),
          headers: AssetResolver.supabaseHeaders,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Image.asset('assets/images/loading.gif', fit: BoxFit.cover);
          },
          errorBuilder: (context, error, stackTrace) => const NoInternetMediaWidget(),
        );
      }

      final picCandidates = AssetResolver.getSupabasePicCandidates(picFilename ?? '${cleanExName}_pic.jpg');
      final Widget staticImageWidget = _buildMultiCandidateVideo(
        candidateUrls: picCandidates,
        fallbackWidget: localOrMuscleFallbackPic,
      );

      Widget gifWidget;
      Widget localOrMuscleFallbackGif;
      if (localGifAsset != null) {
        localOrMuscleFallbackGif = Image.asset(
          localGifAsset,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) {
            if (gifUrl != null && gifUrl.isNotEmpty) {
              return Image.network(
                gifUrl,
                headers: AssetResolver.supabaseHeaders,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Image.asset('assets/images/loading.gif', fit: BoxFit.cover);
                },
                errorBuilder: (c, e, s) => const NoInternetMediaWidget(),
              );
            }
            return const NoInternetMediaWidget();
          },
        );
      } else if (gifUrl != null && gifUrl.isNotEmpty) {
        localOrMuscleFallbackGif = Image.network(
          gifUrl,
          headers: AssetResolver.supabaseHeaders,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Image.asset('assets/images/loading.gif', fit: BoxFit.cover);
          },
          errorBuilder: (c, e, s) => const NoInternetMediaWidget(),
        );
      } else {
        localOrMuscleFallbackGif = const NoInternetMediaWidget();
      }

      final gifCandidates = AssetResolver.getSupabaseGifCandidates(gifFilename ?? '$cleanExName.gif', originalUrl: gifUrl);
      gifWidget = _buildMultiCandidateVideo(
        candidateUrls: gifCandidates,
        fallbackWidget: localOrMuscleFallbackGif,
      );

      return GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -200) {
              if (gifUrl != null && gifUrl.isNotEmpty) {
                setState(() {
                  _showGif = true;
                });
              }
            } else if (details.primaryVelocity! > 200) {
              setState(() {
                _showGif = false;
              });
            }
          }
        },
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              staticImageWidget,
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.fastOutSlowIn,
                left: 0,
                right: 0,
                top: _showGif ? 0 : 320,
                bottom: _showGif ? 0 : -320,
                child: gifUrl != null && gifUrl.isNotEmpty
                    ? Container(
                        color: Colors.black,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            gifWidget,
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.transparent,
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.5),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showGif ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                            color: _showGif ? Colors.blue.shade300 : AppColors.gold,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showGif ? "SWIPE DOWN FOR IMAGE" : "SWIPE UP FOR FORM GIF",
                            style: GoogleFonts.dmSans(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1F5EE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF085041).withOpacity(0.3)),
                  ),
                  child: Text(
                    muscle.toUpperCase(),
                    style: GoogleFonts.bebasNeue(
                      color: const Color(0xFF085041),
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Legendary Athletes & general programs: Direct video playback from Supabase
    final String effectiveFilename = gifFilename.isNotEmpty
        ? gifFilename
        : '$cleanExName.gif';

    final candidateUrls = AssetResolver.getSupabaseVideoCandidates(effectiveFilename, originalUrl: gifUrl);

    Widget videoFallback = SmartFallbackWidget(exerciseName: widget.exercise.name);

    Widget videoWidget = _buildMultiCandidateVideo(
      candidateUrls: candidateUrls,
      fallbackWidget: videoFallback,
    );

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          videoWidget,
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5EE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF085041).withOpacity(0.3)),
              ),
              child: Text(
                muscle.toUpperCase(),
                style: GoogleFonts.bebasNeue(
                  color: const Color(0xFF085041),
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutDoneScreen extends StatefulWidget {
  const WorkoutDoneScreen({super.key});

  @override
  State<WorkoutDoneScreen> createState() => _WorkoutDoneScreenState();
}

class _WorkoutDoneScreenState extends State<WorkoutDoneScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Cubic(0.34, 1.56, 0.64, 1.0)),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _navigateWithFade(Widget destination) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.1),
            radius: 0.85,
            colors: [
              Color(0xFF141F30),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/shapeset_gold_logo.png',
                                    height: 105,
                                    fit: BoxFit.contain,
                                    errorBuilder: (ctx, err, st) => Image.asset('shapeset_gold_logo.png', height: 105, errorBuilder: (c, e, s) => const SizedBox.shrink()),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🏆', style: TextStyle(fontSize: 22)),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Builder(
                                            builder: (ctx) {
                                              final langCode = Localizations.localeOf(ctx).languageCode;
                                              final isNonLatin = ['ar', 'hi', 'zh', 'ja', 'ko', 'ru'].contains(langCode);
                                              return ShaderMask(
                                                shaderCallback: (bounds) => const LinearGradient(
                                                  colors: [Color(0xFF8B6914), Color(0xFFC9A84C), Color(0xFFE8C87A), Color(0xFFC9A84C)],
                                                ).createShader(bounds),
                                                child: Text(
                                                  L10n.s(ctx, 'session_complete'),
                                                  style: (isNonLatin ? GoogleFonts.dmSans() : GoogleFonts.bebasNeue()).copyWith(
                                                    fontSize: isNonLatin ? 22 : 30,
                                                    letterSpacing: isNonLatin ? 0.5 : 3,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text('🏆', style: TextStyle(fontSize: 22)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Builder(
                              builder: (ctx) {
                                final langCode = Localizations.localeOf(ctx).languageCode;
                                final isNonLatin = ['ar', 'hi', 'zh', 'ja', 'ko', 'ru'].contains(langCode);
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: () => _navigateWithFade(const MainScreen(initialIndex: 2)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFC9A84C),
                                          foregroundColor: Colors.black,
                                          elevation: 8,
                                          shadowColor: const Color(0xFFC9A84C).withOpacity(0.4),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: Text(
                                          L10n.s(ctx, 'view_my_progress'),
                                          style: (isNonLatin ? GoogleFonts.dmSans() : GoogleFonts.bebasNeue()).copyWith(
                                            fontSize: isNonLatin ? 16 : 18,
                                            letterSpacing: isNonLatin ? 0.5 : 3,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 46,
                                      child: OutlinedButton(
                                        onPressed: () => _navigateWithFade(const MainScreen()),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.muted,
                                          side: const BorderSide(color: Colors.white24),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        ),
                                        child: Text(
                                          L10n.s(ctx, 'back_to_home').toUpperCase(),
                                          style: TextStyle(fontSize: 13, letterSpacing: isNonLatin ? 0.5 : 1.5, color: AppColors.muted),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SmartExerciseVideoPlayer extends StatefulWidget {
  final List<String> candidateUrls;
  final Widget fallbackWidget;

  const SmartExerciseVideoPlayer({
    super.key,
    required this.candidateUrls,
    required this.fallbackWidget,
  });

  @override
  State<SmartExerciseVideoPlayer> createState() => _SmartExerciseVideoPlayerState();
}

class _SmartExerciseVideoPlayerState extends State<SmartExerciseVideoPlayer> {
  VideoPlayerController? _controller;
  int _currentCandidateIndex = 0;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _tryNextCandidate();
  }

  @override
  void didUpdateWidget(covariant SmartExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.candidateUrls, widget.candidateUrls)) {
      _currentCandidateIndex = 0;
      _tryNextCandidate();
    }
  }

  Future<void> _tryNextCandidate() async {
    _disposeController();

    // Skip non-video (gif/image) candidates — they are handled by _buildImageCandidates.
    // This ensures all .mp4 candidates are tried before falling back to image display.
    while (_currentCandidateIndex < widget.candidateUrls.length) {
      final url = widget.candidateUrls[_currentCandidateIndex];
      final isVideo = url.endsWith('.mp4') || url.endsWith('.webm') || url.contains('/videos/');
      if (isVideo) break;
      _currentCandidateIndex++;
    }

    if (_currentCandidateIndex >= widget.candidateUrls.length) {
      // No more video candidates — fall through to image/gif display.
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
      return;
    }

    final url = widget.candidateUrls[_currentCandidateIndex];

    if (mounted) {
      setState(() {
        _isInitializing = true;
      });
    }

    try {
      final videoHeaders = url.contains('supabase.co')
          ? AssetResolver.supabaseHeaders
          : <String, String>{'User-Agent': 'Mozilla/5.0'};
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: videoHeaders,
      );
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();

      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitializing = false;
        });
      } else {
        controller.dispose();
      }
    } catch (e) {
      debugPrint('Video candidate failed ($url): $e');
      _currentCandidateIndex++;
      _tryNextCandidate();
    }
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candidateUrls.isEmpty) {
      return widget.fallbackWidget;
    }

    // A video is currently playing — show it.
    if (_controller != null && _controller!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }

    // A video candidate is being initialised — show loading indicator.
    if (_isInitializing) {
      return SizedBox.expand(
        child: Image.asset(
          'assets/images/loading.gif',
          fit: BoxFit.cover,
        ),
      );
    }

    // All video candidates exhausted (or none exist) — try image/gif candidates.
    // Always start from 0 so every gif/image candidate in the list is considered.
    return _buildImageCandidates(0);
  }

  Widget _buildImageCandidates(int startIndex) {
    Widget currentFallback = widget.fallbackWidget;
    for (int i = widget.candidateUrls.length - 1; i >= startIndex; i--) {
      final url = widget.candidateUrls[i];
      if (url.endsWith('.mp4') || url.endsWith('.webm')) continue;

      // Only send Supabase auth headers for Supabase URLs.
      // External hosts like burnfit.io will reject requests with unknown auth headers.
      final httpHeaders = url.contains('supabase.co')
          ? AssetResolver.supabaseHeaders
          : <String, String>{'User-Agent': 'Mozilla/5.0'};

      final nextFallback = currentFallback;
      currentFallback = CachedNetworkImage(
        imageUrl: url,
        httpHeaders: httpHeaders,
        fit: BoxFit.cover,
        placeholder: (context, u) => SizedBox.expand(
          child: Image.asset(
            'assets/images/loading.gif',
            fit: BoxFit.cover,
          ),
        ),
        errorWidget: (context, u, err) => nextFallback,
      );
    }
    return currentFallback;
  }
}

class SmartFallbackWidget extends StatelessWidget {
  final String exerciseName;
  const SmartFallbackWidget({super.key, required this.exerciseName});

  Future<bool> _checkConnection() async {
    if (kIsWeb) return true;
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkConnection(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: const Color(0xFF141824),
            child: Center(
              child: Image.asset('assets/images/loading.gif', fit: BoxFit.cover),
            ),
          );
        }
        final bool isOnline = snapshot.data ?? false;
        if (!isOnline) {
          return const NoInternetMediaWidget();
        }
        return FormDemoPlaceholderWidget(exerciseName: exerciseName);
      },
    );
  }
}

class FormDemoPlaceholderWidget extends StatelessWidget {
  final String exerciseName;
  const FormDemoPlaceholderWidget({super.key, required this.exerciseName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141824),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.gold,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              exerciseName.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Form Video Demo',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: Colors.white60,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoInternetMediaWidget extends StatelessWidget {
  const NoInternetMediaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141824),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.redAccent,
                size: 36,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              (L10n.s(context, 'no_internet_title') != 'no_internet_title'
                  ? L10n.s(context, 'no_internet_title')
                  : 'NO INTERNET CONNECTION').toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.bebasNeue(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              L10n.s(context, 'no_internet_desc') != 'no_internet_desc'
                  ? L10n.s(context, 'no_internet_desc')
                  : 'Please check your internet connection to view exercise media',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: Colors.white60,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
