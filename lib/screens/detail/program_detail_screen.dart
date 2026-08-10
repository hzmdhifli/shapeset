import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' as gestures;
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../workout/workout_session_screen.dart';
import '../../services/localization_service.dart';
import '../../models/mock_data.dart';
import '../../services/workout_provider.dart';
import '../../services/subscription_provider.dart';
import '../subscription/paywall_screen.dart';
import '../auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProgramDetailScreen extends StatefulWidget {
  final Program program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  State<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends State<ProgramDetailScreen> {
  int _selectedSplitIndex = 0;
  late ScrollController _scrollController;
  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0);
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 500; // Estimated baseline
  ScrollHoldController? _hold;
  gestures.Drag? _drag;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _initCaches();
    
    // Get actual header height after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_headerKey.currentContext != null) {
        final box = _headerKey.currentContext!.findRenderObject() as RenderBox;
        setState(() {
          _headerHeight = box.size.height;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollOffsetNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _scrollOffsetNotifier.value = _scrollController.offset;
    }
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
    return exerciseToMuscle[exName] ?? 'other';
  }

  String _getLocalizedDetail(String detail) {
    if (Localizations.localeOf(context).languageCode != 'ar') return detail;
    
    String result = detail;

    // Special handling for Franco's "shamel" (comprehensive) style
    if (widget.program.id == 'franco') {
      result = result.replaceAll(RegExp(r'supersets?:?\s*', caseSensitive: false), 'مجموعة شاملة من\n');
    } else {
      // Standard simple terminology for other programs
      result = result.replaceAll(RegExp(r'supersets?:?\s*', caseSensitive: false), 'مجموعات ');
    }
    
    // Ronaldo & General Specifics
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
    
    // Localize the 'x' in 4x12
    if (result.contains(RegExp(r'\d+x\d+'))) {
      result = result.replaceAll('x', ' × ');
    }
    
    return result;
  }

  void _showBadgeExplanation() {
    final badge = widget.program.badge;
    String title = badge.toUpperCase();
    String description = "";

    // Training Style Dictionary
    final Map<String, String> styleDescriptions = {
      'FST-7': "Fascia Stretch Training 7: A hypertrophy-focused style involving 7 high-volume sets with minimal rest (30-45s) at the end of a workout to stretch muscle fascia and promote growth.",
      'High Intensity': "Mike Mentzer's 'Heavy Duty' philosophy. Training with maximum effort on a single set to absolute failure, followed by extended recovery periods to trigger explosive growth.",
      'Longevity & Detail': "The Dexter Jackson approach: using precise machine movements and high-tension isolation to maintain joint health while carving out deep muscle separation.",
      'Flow & Symmetry': "Flex Wheeler's aesthetic priority: balancing all muscle groups proportionally to create a flowing, artful silhouette rather than just chasing sheer mass.",
      'Golden Era / Mass': "The 1970s Arnold style: high-frequency, high-volume sessions using basic heavy compound movements to build classic thickness and density.",
      'Modern Classic': "Ramon Dino's contemporary standard: focusing on the vacuum-ready midsection, deep separation, and full, rounded muscles required for modern Classic Physique.",
      'Hardcore Power': "Ronnie Coleman's methodology: mixing limit-strength powerlifting with high-volume bodybuilding. Maximum weight for maximum results.",
      'High Volume': "Jay Cutler's workload strategy: using high set counts and intense volume to force muscle expansion through sheer metabolic stress and endurance.",
      'Squat King': "Tom Platz's legendary leg training: extreme rep ranges and unmatched intensity on squats to forge lower body size and mental resilience.",
      'Dual Split · Power-Physique': "Franco Columbu's double-split: training twice per day to separate heavy strength sessions from higher-volume aesthetic refinement.",
      'V-Taper': "The aesthetic ideal: heavy focus on shoulder width and back thickness combined with a tight waist to create the ultimate V-shaped frame.",
      'DUP Mastery': "Daily Undulating Periodization: shifting rep ranges and intensity throughout the week to train strength, power, and hypertrophy in one cycle.",
      'Classic Bodybuilding / PPL': "Steve Cook's hybrid: using Push-Pull-Legs organization combined with classic aesthetic principles for a balanced, functional physique.",
      'Modern Aesthetic / PPL': "The contemporary standard: high-frequency refined PPL training focused on social-media-ready aesthetics and natural muscle maturity.",
      'Powerbuilding': "Larry Wheels' hybrid approach: focusing on raw powerlifting strength (Big 3) combined with high-volume bodybuilding isolation to maximize both size and performance.",
      'Classic Physique / High Volume': "Terrence Ruffin's methodology: high-volume training focused on muscle maturity, flawless presentation, and peak contractions to maintain an artful classic silhouette.",
      'Men\'s Physique / High Volume': "Ryan Terry's world-class routine: high-volume training with heavy emphasis on core stability and V-taper aesthetics through intense frequency.",
    };

    description = styleDescriptions[badge] ?? widget.program.description;

    if (Localizations.localeOf(context).languageCode == 'ar') {
      final key = 'desc_$badge';
      final localizedDesc = L10n.s(context, key);
      if (localizedDesc != key) {
        description = localizedDesc;
      }
      
      final badgeKey = 'badge_${widget.program.id}';
      final localizedTitle = L10n.s(context, badgeKey);
      if (localizedTitle != badgeKey) {
        title = localizedTitle.toUpperCase();
      }
    }

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
                    title,
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
              description,
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
                    L10n.s(context, 'got_it'),
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

    return Consumer<SubscriptionProvider>(
      builder: (context, sub, child) {
        final bool isPro = sub.isPro;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Hero Header
                  SliverToBoxAdapter(
                    key: _headerKey,
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
                                          L10n.s(context, 'training_tip'),
                                          style: GoogleFonts.bebasNeue(
                                            fontSize: 14,
                                            color: AppColors.gold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          L10n.s(context, 'tip_details'),
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
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final day = days[index];
                          final workoutProvider = Provider.of<WorkoutProvider>(context);
                          final isCompleted = workoutProvider.isDayCompleted(widget.program.id, day.dayNumber);
                          
                          // Determine active day
                          bool isActive = false;
                          if (day.isTraining && !isCompleted) {
                            final firstUncompleted = days.firstWhere((d) => d.isTraining && !workoutProvider.isDayCompleted(widget.program.id, d.dayNumber), orElse: () => days.last);
                            isActive = (firstUncompleted.dayNumber == day.dayNumber);
                          }
                          return _buildDayCard(day, isActive, isCompleted);
                        },
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
                          _buildMentzerSpecialButton(context),
                          _buildCBumFocusButton(context),
                          _buildSupersetSpecialButton(context),
                          const SizedBox(height: 32),
                          _buildCTA(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Paywall Blur Gate (Scroll Triggered)
              if (!isPro)
                ValueListenableBuilder<double>(
                  valueListenable: _scrollOffsetNotifier,
                  builder: (context, offset, _) {
                    return _buildPaywallGate(context, offset);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaywallGate(BuildContext context, double offset) {
    const double threshold = 150.0; // Distance to reach full blur
    final double progress = (offset / threshold).clamp(0.0, 1.0);
    final double sigma = progress * 25.0; // Deep progressive blur
    
    // Calculate header visibility to anchor the blur layer
    // The header never blurs, so the blur layer starts right at its bottom
    final double currentHeaderVisibleHeight = (_headerHeight - offset).clamp(0.0, _headerHeight);

    return Stack(
      children: [
        // 1. Progressive Blur Layer
        if (progress > 0.01)
          Positioned(
            top: currentHeaderVisibleHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    color: AppColors.background.withOpacity(progress * 0.6),
                  ),
                ),
              ),
            ),
          ),

        // 2. Centered Sticky Overlay (Fades in at full intensity)
        Positioned.fill(
          top: currentHeaderVisibleHeight,
          child: IgnorePointer(
            ignoring: progress < 1.0, // Only capture taps when fully visible
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: progress >= 1.0 ? 1.0 : 0.0,
              curve: Curves.easeIn,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {}, // Swallow taps to prevent them from passing through to underlying buttons
                onVerticalDragStart: (details) {
                  if (_scrollController.hasClients) {
                    _hold = _scrollController.position.hold(() {});
                    _drag = _scrollController.position.drag(details, () {
                      _drag = null;
                    }) as gestures.Drag;
                  }
                },
                onVerticalDragUpdate: (details) {
                  _drag?.update(details);
                },
                onVerticalDragEnd: (details) {
                  _drag?.end(details);
                  _hold?.cancel();
                },
                onVerticalDragCancel: () {
                  _drag?.cancel();
                  _hold?.cancel();
                },
                child: Center(
                  child: _buildPaywallCard(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaywallCard(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.gold,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              L10n.s(context, 'unlock_program_title').toUpperCase(),
              style: GoogleFonts.bebasNeue(
                fontSize: 32,
                color: AppColors.text,
                letterSpacing: 2,
                height: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              L10n.s(context, 'unlock_program_subtext'),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.muted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        L10n.s(context, 'month_price').split(' / ')[0],
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        L10n.s(context, 'month_price').split(' / ')[1].toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: AppColors.muted,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  Column(
                    children: [
                      Text(
                        L10n.s(context, 'year_price').split(' / ')[0],
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        L10n.s(context, 'year_price').split(' / ')[1].toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: AppColors.muted,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaywallScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  elevation: 8,
                  shadowColor: AppColors.gold.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  L10n.s(context, 'subscribe_now').toUpperCase(),
                  style: GoogleFonts.bebasNeue(
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(fontSize: 14),
                  children: [
                    TextSpan(
                      text: "${L10n.s(context, 'already_subscribed')} ",
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    TextSpan(
                      text: L10n.s(context, 'sign_in'),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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
            child: Consumer<SubscriptionProvider>(
              builder: (context, sub, child) {
                final isLocked = !sub.isPro && idx > 0;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        split.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.black : (isLocked ? AppColors.muted.withOpacity(0.5) : AppColors.muted),
                        ),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.lock_outline_rounded, size: 10, color: AppColors.muted),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    if (isLocked) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaywallScreen()),
                      );
                      return;
                    }
                    if (val) setState(() => _selectedSplitIndex = idx);
                  },
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? AppColors.gold : AppColors.border),
                  ),
                  showCheckmark: false,
                );
              },
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
            final workoutProvider = Provider.of<WorkoutProvider>(context);
            final isCompleted = workoutProvider.isDayCompleted(widget.program.id, day.dayNumber);
            
            bool isActive = false;
            if (day.isTraining && !isCompleted) {
              final firstUncompleted = split.days.firstWhere((d) => d.isTraining && !workoutProvider.isDayCompleted(widget.program.id, d.dayNumber), orElse: () => split.days.last);
              isActive = (firstUncompleted.dayNumber == day.dayNumber);
            }
            return _buildDayCard(day, isActive, isCompleted);
          },
        ),
      ],
    );
  }

  // Legacy _buildDayCard removed

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
      alignment: Alignment.topLeft,
      children: [
        // Background Image with Blur
        Container(
          height: 380,
          width: double.infinity,
          decoration: const BoxDecoration(color: AppColors.surface),
          child: ColorFiltered(
            colorFilter: ui.ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              ui.BlendMode.darken,
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
        
        // Back and Export Buttons
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 20),
                    ),
                  ),
                ),
                if (!mockFemalePrograms.any((p) => p.id == widget.program.id) && !mockSixPackPrograms.any((p) => p.id == widget.program.id))
                  Consumer<SubscriptionProvider>(
                    builder: (context, sub, child) {
                      final isLocked = !sub.isPro;
                      return InkWell(
                        onTap: () {
                          if (isLocked) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PaywallScreen()),
                            );
                          } else {
                            // Handle Export
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Exporting program as PDF...')),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isLocked ? Icons.lock_outline_rounded : Icons.ios_share_rounded,
                            color: isLocked ? AppColors.muted : Colors.black,
                            size: 20,
                          ),
                        ),
                      );
                    }
                  ),
              ],
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
                L10n.s(context, 'program_${widget.program.id}') != 'program_${widget.program.id}' 
                    ? L10n.s(context, 'program_${widget.program.id}') 
                    : widget.program.name,
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.bebasNeue(
                fontSize: 22,
                color: AppColors.gold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleBadge() {
    final badge = widget.program.badge;
    final bool hasExplanation = [
      'FST-7', 'High Intensity', 'Longevity & Detail', 'Flow & Symmetry',
      'Golden Era / Mass', 'Modern Classic', 'Hardcore Power', 'High Volume',
      'Squat King', 'Dual Split · Power-Physique', 'V-Taper', 'DUP Mastery',
      'Classic Bodybuilding / PPL', 'Modern Aesthetic / PPL', 'Powerbuilding',
      'Classic Physique / High Volume', 'Men\'s Physique / High Volume'
    ].contains(badge);

    final bool isFST7 = badge == 'FST-7';
    final Color badgeColor = isFST7 ? const Color(0xFF008ECC) : AppColors.gold;
    final Color badgeBg = isFST7 ? const Color(0xFF008ECC).withOpacity(0.1) : AppColors.gold3;

    return GestureDetector(
      onTap: hasExplanation ? _showBadgeExplanation : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isFST7 ? badgeColor : AppColors.gold.withOpacity(0.25),
            width: isFST7 ? 1.5 : 1.0,
          ),
          boxShadow: isFST7 ? [
            BoxShadow(
              color: badgeColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                L10n.s(context, 'badge_${widget.program.id}') != 'badge_${widget.program.id}'
                  ? L10n.s(context, 'badge_${widget.program.id}')
                  : badge,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: isFST7 ? AppColors.gold : AppColors.gold2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasExplanation) const SizedBox(width: 6),
            if (hasExplanation) const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.gold),
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
        L10n.s(context, 'quote_${widget.program.id}') != 'quote_${widget.program.id}'
          ? L10n.s(context, 'quote_${widget.program.id}')
          : widget.program.quote,
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
                  L10n.s(context, 'exercise_${ex.name}') != 'exercise_${ex.name}' 
                      ? L10n.s(context, 'exercise_${ex.name}') 
                      : ex.name,
                  style: GoogleFonts.dmSans(
                    fontSize: Localizations.localeOf(context).languageCode == 'ar' ? 13 : 11.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getLocalizedDetail(ex.detail),
                  style: GoogleFonts.dmSans(
                    fontSize: Localizations.localeOf(context).languageCode == 'ar' ? 10 : 11,
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
    final bool isHardcorePower = label == 'Hardcore Power';
    final bool isFST7 = label == 'FST-7';
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final bool isRonnie = widget.program.id == 'ronnie';
    
    // Specifically make Hardcore Power a button for Ronnie (illustrates his style as requested)
    final bool isInteractive = isHardcorePower && isRonnie;

    String translatedLabel = label;
    if (isArabic) {
      final key = 'tag_$label';
      final localized = L10n.s(context, key);
      if (localized != key) {
        translatedLabel = localized;
      }
    }

    final Color primaryColor = isFST7 ? const Color(0xFF008ECC) : (isHardcorePower ? AppColors.gold : AppColors.border2);
    final Color bgColor = isFST7 ? const Color(0xFF008ECC).withOpacity(0.12) : (isHardcorePower ? AppColors.gold.withOpacity(0.12) : AppColors.background3);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isInteractive ? _showBadgeExplanation : null,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isFST7 ? const Color(0xFF008ECC) : (isHardcorePower ? AppColors.gold : AppColors.border2),
              width: isInteractive ? 1.5 : 1.0,
            ),
            boxShadow: isInteractive ? [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                translatedLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: isFST7 ? const Color(0xFF008ECC) : (isHardcorePower ? AppColors.gold : AppColors.muted),
                  fontWeight: (isInteractive || isFST7) ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isInteractive) ...[
                const SizedBox(width: 4),
                const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.gold),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTA(BuildContext context) {
    return const SizedBox.shrink(); // Per-day buttons used instead
  }

  Widget _buildDayCard(ScheduleDay day, bool isActive, bool isCompleted) {
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
        border: Border.all(
          color: isActive ? AppColors.gold.withOpacity(0.5) : AppColors.border,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ] : null,
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
                    color: isCompleted ? AppColors.muted.withOpacity(0.1) : (isActive ? AppColors.gold : AppColors.gold.withOpacity(0.12)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isActive ? Colors.transparent : AppColors.gold.withOpacity(0.2)),
                  ),
                  child: (() {
                    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
                    final String localizedName = _getLocalizedDayName(context, day.name);
                    String badgeText = (day.dayNumber.toLowerCase().contains('day') 
                        ? L10n.s(context, 'day_label').replaceAll('{num}', int.tryParse(day.dayNumber.replaceAll(RegExp(r'[^0-9]'), ''))?.toString() ?? day.dayNumber)
                        : L10n.s(context, 'day_label').replaceAll('{num}', int.tryParse(day.dayNumber)?.toString() ?? day.dayNumber)).toUpperCase();
                    
                    // Special case for Day 1 in Arabic to show the focus area if requested
                    if (isAr && day.dayNumber == 'Day 1' && !['cbum', 'jaycutler', 'platz', 'jeffseid'].contains(widget.program.id) && (day.name.contains('Quads') || day.name.contains('Legs') || day.name.contains('Calves'))) {
                      badgeText = localizedName.toUpperCase();
                    }

                    return Consumer<SubscriptionProvider>(
                      builder: (context, sub, child) {
                        final isLocked = !sub.canAccessDay(day.dayNumber);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              badgeText,
                              style: GoogleFonts.bebasNeue(
                                fontSize: badgeText.length > 15 ? 10 : 15,
                                color: isCompleted ? AppColors.muted : (isActive ? Colors.black : AppColors.gold),
                                letterSpacing: badgeText.length > 15 ? 0.5 : 1.2,
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 14,
                                color: isActive ? Colors.black : AppColors.gold,
                              ),
                            ],
                          ],
                        );
                      }
                    );
                  })(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (() {
                        final String localizedName = _getLocalizedDayName(context, day.name);
                        return Text(
                          localizedName.toUpperCase(),
                          style: GoogleFonts.bebasNeue(
                            fontSize: localizedName.length > 20 ? 14 : (localizedName.length > 15 ? 16 : 20),
                            color: isCompleted ? AppColors.muted : AppColors.text,
                            letterSpacing: localizedName.length > 18 ? 1.0 : 1.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      })(),
                      if (isActive)
                        Text(
                          L10n.s(context, 'ready_next_session'),
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: AppColors.gold, size: 20),
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

              return Opacity(
                opacity: isCompleted ? 0.6 : 1.0,
                child: Column(
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
                          (L10n.s(context, 'muscle_${muscle.toLowerCase()}') != 'muscle_${muscle.toLowerCase()}' 
                              ? L10n.s(context, 'muscle_${muscle.toLowerCase()}') 
                              : muscle).toUpperCase(),
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

                      return Container(
                        padding: EdgeInsetsDirectional.only(
                          start: Localizations.localeOf(context).languageCode == 'ar' ? 8 : 18,
                          end: Localizations.localeOf(context).languageCode == 'ar' ? 8 : 18,
                          top: 6,
                          bottom: 6,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              child: Text(
                                '${idx + 1}',
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 14,
                                  color: AppColors.dim,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: Localizations.localeOf(context).languageCode == 'ar' ? 4 : 5,
                              child: Text(
                                L10n.s(context, 'exercise_${ex.name}') != 'exercise_${ex.name}' 
                                    ? L10n.s(context, 'exercise_${ex.name}') 
                                    : ex.name,
                                style: GoogleFonts.dmSans(
                                  fontSize: Localizations.localeOf(context).languageCode == 'ar' ? 12 : 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.text,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: Localizations.localeOf(context).languageCode == 'ar' ? 5 : 4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _getLocalizedDetail(ex.detail),
                                      textAlign: TextAlign.end,
                                      style: GoogleFonts.dmSans(
                                        fontSize: Localizations.localeOf(context).languageCode == 'ar' ? 9.5 : 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.muted,
                                        height: 1.1,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.visible, // Changed to visible to encourage wrapping
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
            
            // Per-day Action Button
            Padding(
              padding: const EdgeInsets.all(18),
              child: isCompleted 
                ? Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.muted.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 18, color: AppColors.muted),
                                const SizedBox(width: 8),
                                Text(
                                  L10n.s(context, 'done'),
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 18,
                                    letterSpacing: 2,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<WorkoutProvider>(context, listen: false)
                                  .resetSession(widget.program.id, day.dayNumber);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                                L10n.s(context, 'reset').toUpperCase(),
                                style: GoogleFonts.bebasNeue(
                                  fontSize: 15,
                                  letterSpacing: 2,
                                ),
                              ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Consumer<SubscriptionProvider>(
                    builder: (context, sub, child) {
                      final isLocked = !sub.canAccessDay(day.dayNumber);
                      
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isLocked) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PaywallScreen()),
                              );
                              return;
                            }
                            // Set this program as active
                            Provider.of<WorkoutProvider>(context, listen: false)
                                .setActiveProgram(widget.program.id);
                                
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutSessionScreen(
                                  exercises: day.exercises,
                                  sessionTitle: day.name,
                                  programId: widget.program.id,
                                  dayId: day.dayNumber,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isLocked ? AppColors.surface : AppColors.gold,
                            foregroundColor: isLocked ? AppColors.muted : Colors.black,
                            elevation: isActive ? 4 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isLocked ? const BorderSide(color: AppColors.border) : BorderSide.none,
                            ),
                          ),
                          child: Text(
                            (isLocked ? L10n.s(context, 'go_pro_btn') : L10n.s(context, 'start_session')).toUpperCase(),
                            style: GoogleFonts.bebasNeue(
                              fontSize: 18,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ] else 
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  L10n.s(context, 'workout_rest_day').toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  String _getLocalizedDayName(BuildContext context, String dayName) {
    final nameLow = dayName.toLowerCase();
    
    if (nameLow.contains('chest') && nameLow.contains('tricep')) return L10n.s(context, 'workout_chest_triceps');
    if (nameLow.contains('back') && nameLow.contains('bicep')) return L10n.s(context, 'workout_back_biceps');
    if (nameLow.contains('chest') && nameLow.contains('back')) return L10n.s(context, 'workout_chest_back');
    if (nameLow.contains('shoulder') && nameLow.contains('chest')) return L10n.s(context, 'workout_shoulders_and_chest');
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

    final key = 'workout_${dayName.toLowerCase().replaceAll(' ', '_').replaceAll('&', 'and')}';
    final localized = L10n.s(context, key);
    return localized != key ? localized : dayName;
  }

  void _showStaticHoldExplanation() {
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
                  child: const Icon(Icons.timer_outlined, color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    L10n.s(context, 'title_static_hold'),
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
              L10n.s(context, 'desc_static_hold'),
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.text.withOpacity(0.8),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentzerSpecialButton(BuildContext context) {
    if (widget.program.id != 'mentzer' || Localizations.localeOf(context).languageCode != 'ar') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: _showStaticHoldExplanation,
          icon: const Icon(Icons.info_outline, size: 18),
          label: Text(
            L10n.s(context, 'btn_static_hold').toUpperCase(),
            style: GoogleFonts.bebasNeue(
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: BorderSide(color: AppColors.gold.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  bool _hasSupersets() {
    // Check badge
    if (widget.program.badge.toLowerCase().contains('superset')) return true;
    
    // Check description
    if (widget.program.description.toLowerCase().contains('superset')) return true;
    
    // Check schedule
    final List<ScheduleDay> days = widget.program.splits != null && widget.program.splits!.isNotEmpty
        ? widget.program.splits!.expand((s) => s.days).toList()
        : widget.program.schedule;
        
    for (var day in days) {
      if (day.description.toLowerCase().contains('superset')) return true;
      for (var ex in day.exercises) {
        if (ex.detail.toLowerCase().contains('superset')) return true;
      }
    }
    
    return false;
  }

  void _showSupersetExplanation() {
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
                  child: const Icon(Icons.bolt_outlined, color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    L10n.s(context, 'title_superset'),
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
              L10n.s(context, 'desc_superset'),
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
                    L10n.s(context, 'got_it'),
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

  Widget _buildSupersetSpecialButton(BuildContext context) {
    if (Localizations.localeOf(context).languageCode != 'ar' || !_hasSupersets()) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: _showSupersetExplanation,
          icon: const Icon(Icons.info_outline, size: 18),
          label: Text(
            L10n.s(context, 'btn_superset').toUpperCase(),
            style: GoogleFonts.bebasNeue(
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: BorderSide(color: AppColors.gold.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildCBumFocusButton(BuildContext context) {
    if (widget.program.id != 'cbum' || Localizations.localeOf(context).languageCode != 'ar') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: _showCBumFocusExplanation,
          icon: const Icon(Icons.star_outline, size: 18),
          label: Text(
            L10n.s(context, 'badge_cbum').toUpperCase(),
            style: GoogleFonts.bebasNeue(
              fontSize: 16,
              letterSpacing: 1.5,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: BorderSide(color: AppColors.gold.withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _showCBumFocusExplanation() {
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
                  child: const Icon(Icons.star_border_rounded, color: AppColors.gold, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    L10n.s(context, 'title_cbum_special'),
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
              L10n.s(context, 'desc_cbum_special'),
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
                    L10n.s(context, 'got_it'),
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
}
