import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../main.dart'; // To navigate to MainScreen
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _selectedGoal;
  String? _selectedLevel;
  String? _selectedDays;
  bool _isMetric = true;
  String? _selectedGender;
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgress(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) => setState(() => _currentPage = page),
                children: [
                  _buildGoalStep(),
                  _buildLevelStep(),
                  _buildMetricsStep(),
                  _buildDaysStep(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index == 3 ? 0 : 5),
              decoration: BoxDecoration(
                color: index <= _currentPage ? AppColors.gold : AppColors.border2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepHeader(String step, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.toUpperCase(), style: const TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.bebasNeue(fontSize: 30, letterSpacing: 2, height: 1.1, color: AppColors.text),
          ),
          const SizedBox(height: 6),
          Text(sub, style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.65)),
        ],
      ),
    );
  }

  // --- Step 1: Goal ---
  Widget _buildGoalStep() {
    final goals = [
      {'icon': '💪', 'name': 'Build Muscle', 'desc': 'Mass & strength gain'},
      {'icon': '🔥', 'name': 'Lose Fat', 'desc': 'Cut & get shredded'},
      {'icon': '🏃', 'name': 'Endurance', 'desc': 'Cardio & stamina'},
      {'icon': '⚡', 'name': 'Performance', 'desc': 'Speed & athleticism'},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 1 of 4', 'WHAT\'S YOUR\nMAIN GOAL?', 'We\'ll personalize your program recommendations around this.'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final g = goals[index];
              final isSelected = _selectedGoal == g['name'];
              return _buildOptCard(g['icon']!, g['name']!, g['desc']!, isSelected, () {
                setState(() => _selectedGoal = g['name']);
              });
            },
          ),
        ),
      ],
      ),
    );
  }

  // --- Step 2: Level ---
  Widget _buildLevelStep() {
    final levels = [
      {'icon': '🌱', 'name': 'Beginner', 'sub': 'Under 1 year of training', 'color': const Color(0x1F5AAD7E)},
      {'icon': '🏋️', 'name': 'Intermediate', 'sub': '1–3 years of consistent training', 'color': AppColors.gold3},
      {'icon': '🦾', 'name': 'Advanced', 'sub': '3+ years — serious athlete', 'color': const Color(0x1FE85C4A)},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 2 of 4', 'YOUR TRAINING\nEXPERIENCE', 'This sets the intensity and complexity of your program.'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: levels.map((l) {
              final isSelected = _selectedLevel == l['name'];
              return _buildLevelItem(l['icon'] as String, l['name'] as String, l['sub'] as String, l['color'] as Color, isSelected, () {
                setState(() => _selectedLevel = l['name'] as String);
              });
            }).toList(),
          ),
        ),
      ],
      ),
    );
  }

  // --- Step 3: Metrics ---
  Widget _buildMetricsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader('Step 3 of 4', 'YOUR BODY\nMETRICS', 'Used to tailor your nutrition plan and track your transformation.'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUnitToggle(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildMetricInput('Weight (${_isMetric ? 'kg' : 'lbs'})', _isMetric ? '75' : '165', _weightCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMetricInput('Height (${_isMetric ? 'cm' : 'ft'})', _isMetric ? '180' : '5\'11', _heightCtrl)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMetricInput('Age', '25', _ageCtrl),
                const SizedBox(height: 16),
                const Text('Biological Sex', style: TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGender,
                      isExpanded: true,
                      dropdownColor: AppColors.surface,
                      hint: const Text('Select...', style: TextStyle(color: AppColors.dim, fontSize: 14)),
                      icon: const Icon(Icons.expand_more, color: AppColors.dim),
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male', style: TextStyle(color: AppColors.text, fontSize: 14))),
                        DropdownMenuItem(value: 'Female', child: Text('Female', style: TextStyle(color: AppColors.text, fontSize: 14))),
                      ],
                      onChanged: (v) => setState(() => _selectedGender = v),
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

  // --- Step 4: Days ---
  Widget _buildDaysStep() {
    final days = [
      {'icon': '📅', 'name': '3 Days', 'desc': 'Full body focus'},
      {'icon': '📆', 'name': '4 Days', 'desc': 'Upper/lower split'},
      {'icon': '🗓️', 'name': '5 Days', 'desc': 'Classic PPL split'},
      {'icon': '🔥', 'name': '6 Days', 'desc': 'Full commitment'},
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('Step 4 of 4', 'HOW MANY DAYS\nPER WEEK?', 'Consistency beats intensity. Choose what you can realistically commit to.'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final d = days[index];
              final isSelected = _selectedDays == d['name'];
              return _buildOptCard(d['icon']!, d['name']!, d['desc']!, isSelected, () {
                setState(() => _selectedDays = d['name']);
              });
            },
          ),
        ),
      ],
      ),
    );
  }

  // --- Sub-widgets ---
  Widget _buildOptCard(String icon, String name, String desc, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold3 : AppColors.surface,
          border: Border.all(color: selected ? AppColors.gold : AppColors.border2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 26, color: selected ? AppColors.gold : AppColors.muted)),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(desc, style: const TextStyle(fontSize: 10, color: AppColors.muted), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelItem(String icon, String name, String sub, Color bgColor, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold3 : AppColors.surface,
          border: Border.all(color: selected ? AppColors.gold : AppColors.border2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.gold : Colors.transparent,
                border: Border.all(color: selected ? AppColors.gold : AppColors.border2, width: 1.5),
              ),
              child: selected ? const Icon(Icons.check, size: 11, color: Colors.black) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppColors.border2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitBtn('KG / CM', _isMetric, () => setState(() => _isMetric = true)),
          _buildUnitBtn('LBS / FT', !_isMetric, () => setState(() => _isMetric = false)),
        ],
      ),
    );
  }

  Widget _buildUnitBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(color: active ? AppColors.gold : Colors.transparent, borderRadius: BorderRadius.circular(100)),
        child: Text(
          label,
          style: TextStyle(color: active ? Colors.black : AppColors.muted, fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildMetricInput(String label, String hint, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.dim),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold)),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            if (_currentPage < 3) {
              _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
            } else {
              _finishSetup();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            _currentPage < 3 ? 'CONTINUE →' : 'FINISH SETUP →',
            style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3, color: Colors.black),
          ),
        ),
      ),
    );
  }

  void _finishSetup() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save onboarding data
    await prefs.setString('userGoal', _selectedGoal ?? '');
    await prefs.setString('userLevel', _selectedLevel ?? '');
    await prefs.setString('userGender', _selectedGender ?? '');
    await prefs.setString('userWeight', _weightCtrl.text);
    await prefs.setString('userHeight', _heightCtrl.text);
    await prefs.setString('userAge', _ageCtrl.text);
    await prefs.setBool('isMetric', _isMetric);
    await prefs.setString('userDays', _selectedDays ?? '');
    await prefs.setBool('onboardingComplete', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SuccessScreen()),
      );
    }
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.gold3,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: const Icon(Icons.check, color: AppColors.gold, size: 36),
              ),
              const SizedBox(height: 24),
              FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  final name = snapshot.data?.getString('userName')?.toUpperCase() ?? 'ALEX';
                  return Text(
                    'WELCOME,\n$name',
                    style: GoogleFonts.bebasNeue(fontSize: 36, letterSpacing: 3, height: 1.1, color: AppColors.text),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Your profile is set up and your personalized\nprogram recommendations are ready.',
                style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.7),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _Badge('Build Muscle'),
                  _Badge('Intermediate'),
                  _Badge('5 Days/Week'),
                ],
              ),
              const SizedBox(height: 36),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('START TRAINING →', style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 17, letterSpacing: 3, color: Colors.black)),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold3,
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: const TextStyle(color: AppColors.gold2, fontSize: 11)),
    );
  }
}
