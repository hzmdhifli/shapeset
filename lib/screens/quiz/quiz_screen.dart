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
  final Map<int, int> _answers = {};

  List<QuizStep> _getSteps(BuildContext context) {
    // Initial Step: Gender Selection
    final genderStep = QuizStep(
      question: L10n.s(context, 'quiz_gender_q'),
      subtext: L10n.s(context, 'quiz_gender_sub'),
      options: [
        QuizOption(title: L10n.s(context, 'quiz_male'), sub: L10n.s(context, 'quiz_male_sub'), icon: "assets/images/male.png", values: ["male"]),
        QuizOption(title: L10n.s(context, 'quiz_female'), sub: L10n.s(context, 'quiz_female_sub'), icon: "assets/images/femaley.png", values: ["female"]),
      ],
    );

    if (!_answers.containsKey(0)) return [genderStep];

    final bool isMale = _answers[0] == 0;

    if (isMale) {
      return [
        genderStep,
        QuizStep(
          question: L10n.s(context, 'quiz_goal_q'),
          subtext: L10n.s(context, 'quiz_goal_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_goal_mass'), sub: L10n.s(context, 'quiz_goal_mass_sub'), icon: "🦍", values: ["ronnie", "bigramy", "arnold"]),
            QuizOption(title: L10n.s(context, 'quiz_goal_aesthetic'), sub: L10n.s(context, 'quiz_goal_aesthetic_sub'), icon: "💎", values: ["cbum", "jeffseid", "ulissesjr"]),
            QuizOption(title: L10n.s(context, 'quiz_goal_strength'), sub: L10n.s(context, 'quiz_goal_strength_sub'), icon: "💥", values: ["larrywheels", "franco", "mentzer"]),
            QuizOption(title: L10n.s(context, 'quiz_goal_symmetry'), sub: L10n.s(context, 'quiz_goal_symmetry_sub'), icon: "⚖️", values: ["flex", "dexter", "ryanterry"]),
            QuizOption(title: L10n.s(context, 'quiz_goal_classic'), sub: L10n.s(context, 'quiz_goal_classic_sub'), icon: "🏛️", values: ["arnold", "franco", "platz"]),
            QuizOption(title: L10n.s(context, 'quiz_goal_natural'), sub: L10n.s(context, 'quiz_goal_natural_sub'), icon: "🥗", values: ["alexeubank", "davidlaid", "stevecook"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_freq_q'),
          subtext: L10n.s(context, 'quiz_freq_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_days_3'), sub: L10n.s(context, 'quiz_days_3_sub'), icon: "🗓️", values: ["mentzer", "franco"]),
            QuizOption(title: L10n.s(context, 'quiz_days_4'), sub: L10n.s(context, 'quiz_days_4_sub'), icon: "📅", values: ["dexter", "mikethurston", "stevecook"]),
            QuizOption(title: L10n.s(context, 'quiz_days_5'), sub: L10n.s(context, 'quiz_days_5_sub'), icon: "📆", values: ["cbum", "philheath", "ryanterry"]),
            QuizOption(title: L10n.s(context, 'quiz_days_6'), sub: L10n.s(context, 'quiz_days_6_sub'), icon: "🔥", values: ["arnold", "ronnie", "jaycutler"]),
            QuizOption(title: L10n.s(context, 'quiz_days_7'), sub: L10n.s(context, 'quiz_days_7_sub'), icon: "⚡", values: ["bigramy", "jaycutler", "hadichoopan"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_muscle_q'),
          subtext: L10n.s(context, 'quiz_muscle_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_body_chest'), sub: L10n.s(context, 'quiz_goal_mass_sub'), icon: "👕", values: ["arnold", "cbum", "simeonpanda"]),
            QuizOption(title: L10n.s(context, 'quiz_body_legs'), sub: L10n.s(context, 'quiz_goal_strength_sub'), icon: "🦵", values: ["platz", "jaycutler", "ramon"]),
            QuizOption(title: L10n.s(context, 'quiz_body_shoulders'), sub: L10n.s(context, 'quiz_goal_aesthetic_sub'), icon: "🛡️", values: ["jeffseid", "ryanterry", "mikethurston"]),
            QuizOption(title: L10n.s(context, 'quiz_body_arms'), sub: L10n.s(context, 'quiz_goal_mass_sub'), icon: "🦾", values: ["philheath", "flex", "ulissesjr"]),
            QuizOption(title: L10n.s(context, 'quiz_body_symmetry'), sub: L10n.s(context, 'quiz_goal_symmetry_sub'), icon: "🎯", values: ["dexter", "flex", "terrenceruffin"]),
            QuizOption(title: L10n.s(context, 'quiz_body_back'), sub: L10n.s(context, 'quiz_goal_mass_sub'), icon: "🎒", values: ["ronnie", "hadichoopan", "bigramy"]),
            QuizOption(title: L10n.s(context, 'quiz_body_forearms'), sub: L10n.s(context, 'quiz_goal_strength_sub'), icon: "🕸️", values: ["ramon", "larrywheels"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_exp_q'),
          subtext: L10n.s(context, 'quiz_exp_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_exp_beg'), sub: L10n.s(context, 'quiz_exp_beg_sub'), icon: "🌱", values: ["stevecook", "alexeubank", "mikethurston"]),
            QuizOption(title: L10n.s(context, 'quiz_exp_int'), sub: L10n.s(context, 'quiz_exp_int_sub'), icon: "🏋️", values: ["cbum", "davidlaid", "jeffseid", "terrenceruffin"]),
            QuizOption(title: L10n.s(context, 'quiz_exp_adv'), sub: L10n.s(context, 'quiz_exp_adv_sub'), icon: "🦾", values: ["philheath", "dexter", "ryanterry"]),
            QuizOption(title: L10n.s(context, 'quiz_exp_vet'), sub: L10n.s(context, 'quiz_exp_vet_sub'), icon: "🏆", values: ["arnold", "ronnie", "mentzer"]),
            QuizOption(title: L10n.s(context, 'quiz_exp_pro'), sub: L10n.s(context, 'quiz_exp_pro_sub'), icon: "🐺", values: ["hadichoopan", "bigramy", "jaycutler"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_style_q'),
          subtext: L10n.s(context, 'quiz_style_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_style_vol'), sub: L10n.s(context, 'quiz_style_vol_sub'), icon: "🌊", values: ["arnold", "jaycutler", "ronnie"]),
            QuizOption(title: L10n.s(context, 'quiz_style_heavy'), sub: L10n.s(context, 'quiz_style_heavy_sub'), icon: "💣", values: ["mentzer", "larrywheels", "franco"]),
            QuizOption(title: L10n.s(context, 'quiz_style_mm'), sub: L10n.s(context, 'quiz_style_mm_sub'), icon: "🧠", values: ["philheath", "flex", "cbum"]),
            QuizOption(title: L10n.s(context, 'quiz_style_exp'), sub: L10n.s(context, 'quiz_style_exp_sub'), icon: "⚡", values: ["davidlaid", "larrywheels", "ramon"]),
            QuizOption(title: L10n.s(context, 'quiz_style_aes'), sub: L10n.s(context, 'quiz_style_aes_sub'), icon: "📸", values: ["jeffseid", "ryanterry", "terrenceruffin"]),
            QuizOption(title: L10n.s(context, 'quiz_style_cond'), sub: L10n.s(context, 'quiz_style_cond_sub'), icon: "🐺", values: ["hadichoopan", "ulissesjr", "dexter"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_era_q'),
          subtext: L10n.s(context, 'quiz_era_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_era_golden'), sub: L10n.s(context, 'quiz_era_golden_sub'), icon: "🏛️", values: ["arnold", "franco", "flex"]),
            QuizOption(title: L10n.s(context, 'quiz_era_mass'), sub: L10n.s(context, 'quiz_era_mass_sub'), icon: "🦍", values: ["ronnie", "jaycutler", "philheath"]),
            QuizOption(title: L10n.s(context, 'quiz_era_modern'), sub: L10n.s(context, 'quiz_era_modern_sub'), icon: "👟", values: ["cbum", "terrenceruffin", "dexter"]),
            QuizOption(title: L10n.s(context, 'quiz_era_aes'), sub: L10n.s(context, 'quiz_era_aes_sub'), icon: "📱", values: ["jeffseid", "davidlaid", "alexeubank"]),
            QuizOption(title: L10n.s(context, 'quiz_era_open'), sub: L10n.s(context, 'quiz_era_open_sub'), icon: "🧟", values: ["bigramy", "hadichoopan"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_diet_q'),
          subtext: L10n.s(context, 'quiz_diet_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_diet_bulk'), sub: L10n.s(context, 'quiz_diet_bulk_sub'), icon: "🍔", values: ["bigramy", "ronnie", "jaycutler"]),
            QuizOption(title: L10n.s(context, 'quiz_diet_clean'), sub: L10n.s(context, 'quiz_diet_clean_sub'), icon: "🥩", values: ["arnold", "cbum", "stevecook"]),
            QuizOption(title: L10n.s(context, 'quiz_diet_strict'), sub: L10n.s(context, 'quiz_diet_strict_sub'), icon: "⚖️", values: ["philheath", "hadichoopan", "ulissesjr"]),
            QuizOption(title: L10n.s(context, 'quiz_diet_intu'), sub: L10n.s(context, 'quiz_diet_intu_sub'), icon: "🧘", values: ["alexeubank", "mikethurston", "davidlaid"]),
            QuizOption(title: L10n.s(context, 'quiz_diet_cycle'), sub: L10n.s(context, 'quiz_diet_cycle_sub'), icon: "📉", values: ["dexter", "terrenceruffin", "ryanterry"]),
            QuizOption(title: L10n.s(context, 'quiz_diet_prot'), sub: L10n.s(context, 'quiz_diet_prot_sub'), icon: "🍗", values: ["franco", "mentzer", "larrywheels"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_moti_q'),
          subtext: L10n.s(context, 'quiz_moti_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_moti_dom'), sub: L10n.s(context, 'quiz_moti_dom_sub'), icon: "⚔️", values: ["ronnie", "larrywheels"]),
            QuizOption(title: L10n.s(context, 'quiz_moti_look'), sub: L10n.s(context, 'quiz_moti_look_sub'), icon: "✨", values: ["flex", "jeffseid", "ryanterry"]),
            QuizOption(title: L10n.s(context, 'quiz_moti_pr'), sub: L10n.s(context, 'quiz_moti_pr_sub'), icon: "🆙", values: ["larrywheels", "mentzer", "franco"]),
            QuizOption(title: L10n.s(context, 'quiz_moti_legacy'), sub: L10n.s(context, 'quiz_moti_legacy_sub'), icon: "👑", values: ["arnold", "philheath", "jaycutler"]),
            QuizOption(title: L10n.s(context, 'quiz_moti_inspire'), sub: L10n.s(context, 'quiz_moti_inspire_sub'), icon: "📣", values: ["simeonpanda", "alexeubank", "stevecook"]),
            QuizOption(title: L10n.s(context, 'quiz_moti_shred'), sub: L10n.s(context, 'quiz_moti_shred_sub'), icon: "🔪", values: ["hadichoopan", "ulissesjr", "dexter"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_type_q'),
          subtext: L10n.s(context, 'quiz_type_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_type_slim'), sub: L10n.s(context, 'quiz_type_slim_sub'), icon: "🥖", values: ["davidlaid", "alexeubank", "jeffseid"]),
            QuizOption(title: L10n.s(context, 'quiz_type_avg'), sub: L10n.s(context, 'quiz_type_avg_sub'), icon: "👔", values: ["cbum", "mikethurston", "terrenceruffin"]),
            QuizOption(title: L10n.s(context, 'quiz_type_stocky'), sub: L10n.s(context, 'quiz_type_stocky_sub'), icon: "🪵", values: ["ronnie", "bigramy", "jaycutler"]),
            QuizOption(title: L10n.s(context, 'quiz_type_ath'), sub: L10n.s(context, 'quiz_type_ath_sub'), icon: "🤺", values: ["ryanterry", "dexter", "flex"]),
            QuizOption(title: L10n.s(context, 'quiz_type_power'), sub: L10n.s(context, 'quiz_type_power_sub'), icon: "🧱", values: ["larrywheels", "franco", "mentzer"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_quote_q'),
          subtext: L10n.s(context, 'quiz_quote_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_quote_ronnie'), sub: "Ronnie Coleman", icon: "📣", values: ["ronnie"]),
            QuizOption(title: L10n.s(context, 'quiz_quote_arnold'), sub: "Arnold Schwarzenegger", icon: "📈", values: ["arnold"]),
            QuizOption(title: L10n.s(context, 'quiz_quote_alex'), sub: "Alex Eubank", icon: "❤️", values: ["alexeubank"]),
            QuizOption(title: L10n.s(context, 'quiz_quote_phil'), sub: "Phil Heath", icon: "🌟", values: ["philheath"]),
            QuizOption(title: L10n.s(context, 'quiz_quote_franco'), sub: "Franco Columbu", icon: "🛡️", values: ["franco"]),
            QuizOption(title: L10n.s(context, 'quiz_quote_ulisses'), sub: "Ulisses Jr", icon: "🔥", values: ["ulissesjr"]),
            QuizOption(title: L10n.s(context, 'quiz_quote_larry'), sub: "Larry Wheels", icon: "🔄", values: ["larrywheels"]),
            QuizOption(title: L10n.s(context, 'quiz_quote_jeff'), sub: "Jeff Seid", icon: "📸", values: ["jeffseid"]),
          ],
        ),
      ];
    } else {
      // FEMALE BRANCH
      return [
        genderStep,
        QuizStep(
          question: L10n.s(context, 'quiz_female_goal_q'),
          subtext: L10n.s(context, 'quiz_female_goal_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_female_goal_lean'), sub: L10n.s(context, 'quiz_female_goal_lean_sub'), icon: "🏃‍♀️", values: ["athletic_lean"]),
            QuizOption(title: L10n.s(context, 'quiz_female_goal_curvy'), sub: L10n.s(context, 'quiz_female_goal_curvy_sub'), icon: "👙", values: ["bikini_competition"]),
            QuizOption(title: L10n.s(context, 'quiz_female_goal_strong'), sub: L10n.s(context, 'quiz_female_goal_strong_sub'), icon: "🏋️‍♀️", values: ["powerlifter_female"]),
            QuizOption(title: L10n.s(context, 'quiz_female_goal_sculpt'), sub: L10n.s(context, 'quiz_female_goal_sculpt_sub'), icon: "🔥", values: ["sculpt_and_cardio"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_exp_q'),
          subtext: L10n.s(context, 'quiz_exp_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_exp_beg'), sub: L10n.s(context, 'quiz_exp_beg_sub'), icon: "🌱", values: ["sculpt_and_cardio"]),
            QuizOption(title: L10n.s(context, 'quiz_exp_int'), sub: L10n.s(context, 'quiz_exp_int_sub'), icon: "💪", values: ["athletic_lean"]),
            QuizOption(title: L10n.s(context, 'quiz_exp_adv'), sub: L10n.s(context, 'quiz_exp_adv_sub'), icon: "🏆", values: ["bikini_competition"]),
            QuizOption(title: L10n.s(context, 'quiz_exp_vet'), sub: L10n.s(context, 'quiz_exp_vet_sub'), icon: "⚡", values: ["powerlifter_female"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_freq_q'),
          subtext: L10n.s(context, 'quiz_freq_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_days_3'), sub: L10n.s(context, 'quiz_days_3_sub'), icon: "🗓️", values: ["athletic_lean", "bikini_competition", "powerlifter_female"]),
            QuizOption(title: L10n.s(context, 'quiz_days_5'), sub: L10n.s(context, 'quiz_days_5_sub'), icon: "🔥", values: ["sculpt_and_cardio"]),
          ],
        ),
        QuizStep(
          question: L10n.s(context, 'quiz_muscle_q'),
          subtext: L10n.s(context, 'quiz_muscle_sub'),
          options: [
            QuizOption(title: L10n.s(context, 'quiz_body_legs'), sub: L10n.s(context, 'quiz_female_goal_curvy_sub'), icon: "🍑", values: ["bikini_competition", "sculpt_and_cardio"]),
            QuizOption(title: L10n.s(context, 'quiz_goal_strength'), sub: L10n.s(context, 'quiz_female_goal_strong_sub'), icon: "👊", values: ["powerlifter_female"]),
            QuizOption(title: L10n.s(context, 'quiz_body_symmetry'), sub: L10n.s(context, 'quiz_female_goal_lean_sub'), icon: "🎾", values: ["athletic_lean"]),
          ],
        ),
      ];
    }
  }

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
        title: Text(L10n.s(context, 'matchmaker_title'), style: const TextStyle(fontFamily: 'Bebas Neue', letterSpacing: 3)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(steps.length),
            const SizedBox(height: 28),
            Text(step.question, style: TextStyle(fontFamily: 'Bebas Neue', fontSize: _res(context, 26), letterSpacing: 2, height: 1.15)),
            const SizedBox(height: 6),
            Text(step.subtext, style: TextStyle(color: AppColors.muted, fontSize: _res(context, 13), height: 1.6)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: step.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final opt = step.options[index];
                  final isSelected = _answers[_currentStep] == index;
                  return _buildOption(opt, isSelected, index);
                },
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          onPressed: () => setState(() => _currentStep--),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            L10n.s(context, 'back_btn'),
                            style: TextStyle(color: AppColors.muted, fontFamily: 'Bebas Neue', fontSize: _res(context, 13), letterSpacing: 2),
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
                        _currentStep == steps.length - 1 ? L10n.s(context, 'get_results') : L10n.s(context, 'continue_btn'),
                        style: TextStyle(fontFamily: 'Bebas Neue', fontSize: _res(context, 17), letterSpacing: 3),
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
      children: List.generate(totalSteps, (index) {
        final isDone = index < _currentStep;
        final isCurrent = index == _currentStep;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            height: 3,
            decoration: BoxDecoration(
              color: isDone || isCurrent ? AppColors.gold : AppColors.border2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOption(QuizOption opt, bool isSelected, int index) {
    // Custom colors for gender selection
    Color titleColor = AppColors.text;
    if (opt.title == L10n.s(context, 'quiz_male')) {
      titleColor = const Color(0xFF008ECC);
    } else if (opt.title == L10n.s(context, 'quiz_female')) {
      titleColor = const Color(0xFFFF77FF);
    } else if (isSelected) {
      titleColor = AppColors.gold;
    }

    return InkWell(
      onTap: () => setState(() => _answers[_currentStep] = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? titleColor.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? titleColor : AppColors.border2, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected ? titleColor.withOpacity(0.25) : AppColors.background3,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: opt.icon.contains('/') 
                  ? Image.asset(
                      opt.icon, 
                      width: 22, 
                      height: 22, 
                      fit: BoxFit.contain,
                      color: (opt.title == L10n.s(context, 'quiz_male') || opt.title == L10n.s(context, 'quiz_female')) ? titleColor : (isSelected ? AppColors.gold : Colors.white70),
                    )
                  : Text(opt.icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opt.title, 
                    style: TextStyle(
                      fontSize: _res(context, 14), 
                      fontWeight: FontWeight.bold, 
                      color: titleColor, 
                      height: 1.2,
                      letterSpacing: 1,
                    )
                  ),
                  const SizedBox(height: 2),
                  Text(opt.sub, style: TextStyle(fontSize: _res(context, 11), color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final steps = _getSteps(context);
    final bool isMale = _answers[0] == 0;
    
    // Choose the database to search within
    final sourcePrograms = isMale ? mockPrograms : mockFemalePrograms;

    // SCORING ENGINE
    final Map<String, int> scores = {};
    _answers.forEach((stepIdx, optIdx) {
      if (stepIdx == 0) return; // Skip the gender question for scoring
      
      // Ensure we don't crash if steps changed mid-flow
      if (stepIdx < steps.length && optIdx < steps[stepIdx].options.length) {
        final selectedIds = steps[stepIdx].options[optIdx].values;
        for (var id in selectedIds) {
          scores[id] = (scores[id] ?? 0) + 1;
        }
      }
    });

    // Sort to find top athlete/program
    final sortedResults = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Default to a safe fallback if no scores found
    final String winnerId = sortedResults.isNotEmpty 
        ? sortedResults.first.key 
        : (isMale ? 'arnold' : 'sculpt_and_cardio');
    
    final match = sourcePrograms.firstWhere(
      (p) => p.id == winnerId,
      orElse: () => sourcePrograms[0],
    );

    // Determine category description - localized!
    String category = L10n.s(context, 'quiz_res_aesthetic');
    if (isMale) {
      if (winnerId == 'arnold' || winnerId == 'franco' || winnerId == 'flex') category = L10n.s(context, 'quiz_res_golden');
      else if (winnerId == 'ronnie' || winnerId == 'jaycutler' || winnerId == 'bigramy') category = L10n.s(context, 'quiz_res_mass');
      else if (winnerId == 'larrywheels' || winnerId == 'mentzer' || winnerId == 'franco') category = L10n.s(context, 'quiz_res_strength');
      else if (winnerId == 'hadichoopan' || winnerId == 'dexter' || winnerId == 'ulissesjr') category = L10n.s(context, 'quiz_res_cond');
      else if (winnerId == 'alexeubank' || winnerId == 'davidlaid' || winnerId == 'stevecook') category = L10n.s(context, 'quiz_res_natural');
    } else {
      if (winnerId == 'bikini_competition') category = L10n.s(context, 'quiz_res_bikini');
      else if (winnerId == 'athletic_lean') category = L10n.s(context, 'quiz_res_athletic');
      else if (winnerId == 'powerlifter_female') category = L10n.s(context, 'quiz_res_power');
      else if (winnerId == 'sculpt_and_cardio') category = L10n.s(context, 'quiz_res_sculpt');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      match.imagePath,
                      height: 180,
                      width: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        width: 160,
                        color: AppColors.surface,
                        child: const Icon(Icons.person, color: AppColors.gold, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(category.toUpperCase(), style: TextStyle(fontSize: _res(context, 10), color: AppColors.muted, letterSpacing: 3, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  (L10n.s(context, 'program_${match.id}') != 'program_${match.id}' ? L10n.s(context, 'program_${match.id}') : match.name).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Bebas Neue', fontSize: _res(context, 32), color: AppColors.text, letterSpacing: 2, height: 1.1),
                ),
                const SizedBox(height: 12),
                Text(
                  "\"${L10n.s(context, 'quote_${match.id}') != 'quote_${match.id}' ? L10n.s(context, 'quote_${match.id}') : match.quote}\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gold, fontStyle: FontStyle.italic, fontSize: _res(context, 13)),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border2),
                  ),
                  child: Text(
                    L10n.s(context, 'quiz_analysis_result')
                      .replaceAll('{alias}', L10n.s(context, 'alias_${match.alias}') != 'alias_${match.alias}' ? L10n.s(context, 'alias_${match.alias}') : match.alias)
                      .replaceAll('{style}', L10n.s(context, 'style_${match.style}') != 'style_${match.style}' ? L10n.s(context, 'style_${match.style}') : match.style)
                      .replaceAll('{intensity}', L10n.s(context, 'intensity_${match.intensity}') != 'intensity_${match.intensity}' ? L10n.s(context, 'intensity_${match.intensity}') : match.intensity),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, fontSize: _res(context, 13), height: 1.6),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ProgramDetailScreen(program: match)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: AppColors.gold.withOpacity(0.3),
                    ),
                    child: Text(L10n.s(context, 'view_program'), style: TextStyle(fontFamily: 'Bebas Neue', fontSize: _res(context, 17), letterSpacing: 2.5)),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() {
                    _currentStep = 0;
                    _answers.clear();
                  }),
                  child: Text(
                    L10n.s(context, 'retake_quiz_btn'),
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
  final List<String> values;
  QuizOption({required this.title, required this.sub, required this.icon, required this.values});
}
