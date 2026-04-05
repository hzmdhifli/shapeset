import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_colors.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _gender;
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String? _goal;
  String? _level;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('userName') ?? '';
      _ageCtrl.text = prefs.getString('userAge') ?? '';
      
      final savedGender = prefs.getString('userGender');
      _gender = (savedGender != null && savedGender.isNotEmpty) ? savedGender : null;
      
      _heightCtrl.text = prefs.getString('userHeight') ?? '';
      _weightCtrl.text = prefs.getString('userWeight') ?? '';
      
      final savedGoal = prefs.getString('userGoal');
      _goal = (savedGoal != null && savedGoal.isNotEmpty) ? savedGoal : null;
      
      final savedLevel = prefs.getString('userLevel');
      _level = (savedLevel != null && savedLevel.isNotEmpty) ? savedLevel : null;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_nameCtrl.text.isNotEmpty) await prefs.setString('userName', _nameCtrl.text);
    if (_ageCtrl.text.isNotEmpty) await prefs.setString('userAge', _ageCtrl.text);
    if (_gender != null) await prefs.setString('userGender', _gender!);
    if (_heightCtrl.text.isNotEmpty) await prefs.setString('userHeight', _heightCtrl.text);
    if (_weightCtrl.text.isNotEmpty) await prefs.setString('userWeight', _weightCtrl.text);
    if (_goal != null) await prefs.setString('userGoal', _goal!);
    if (_level != null) await prefs.setString('userLevel', _level!);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('EDIT PROFILE', style: GoogleFonts.bebasNeue(fontSize: 22, letterSpacing: 2, color: AppColors.text)),
            const SizedBox(height: 20),
            
            _buildField('Full Name', _nameCtrl, Icons.person_outline),
            _buildField('Age', _ageCtrl, Icons.calendar_today_outlined, keyboardType: TextInputType.number),
            
            _buildDropdown('Gender', _gender, ['Male', 'Female', 'Other', 'Prefer not to say'], (v) => setState(() => _gender = v), Icons.people_outline),
            
            Row(
              children: [
                Expanded(child: _buildField('Height (cm)', _heightCtrl, Icons.height, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Weight (kg)', _weightCtrl, Icons.fitness_center, keyboardType: TextInputType.number)),
              ],
            ),
            
            _buildDropdown('Fitness Goal', _goal, ['Build Muscle', 'Lose Fat', 'Endurance', 'Performance', 'General Fitness'], (v) => setState(() => _goal = v), Icons.flag_outlined),
            _buildDropdown('Experience Level', _level, ['Beginner', 'Intermediate', 'Advanced'], (v) => setState(() => _level = v), Icons.leaderboard_outlined),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.border2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.gold,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('SAVE CHANGES', style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 16, letterSpacing: 2, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.text, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.dim, size: 18),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: value,
            dropdownColor: AppColors.surface2,
            icon: const Icon(Icons.expand_more, color: AppColors.dim),
            style: const TextStyle(color: AppColors.text, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.dim, size: 18),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.gold)),
            ),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
