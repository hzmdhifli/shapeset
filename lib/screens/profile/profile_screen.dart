import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';
import 'widgets/edit_profile_sheet.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _restTimer = prefs.getBool('restTimer') ?? true;
      });
    }
  }

  bool _restTimer = true;

  Future<void> _updateSetting(String key, bool value) async {
    await _prefs?.setBool(key, value);
    setState(() {
      if (key == 'restTimer') _restTimer = value;
    });
  }

  void _showTestNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'basic_channel',
        title: 'Notifications Activated! ⚡',
        body: 'You will now receive workout reminders and streak updates.',
        notificationLayout: NotificationLayout.Default,
      )
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _prefs?.setString('userPhoto', image.path);
      _refreshData();
    }
  }

  void _refreshData() {
    _loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    if (_prefs == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    final age = _prefs!.getString('userAge');
    final weight = _prefs!.getString('userWeight');
    final height = _prefs!.getString('userHeight');
    final gender = _prefs!.getString('userGender');
    final goal = _prefs!.getString('userGoal');
    final level = _prefs!.getString('userLevel');

    String personalSubtitle = 'Name';
    if (age != null && age.isNotEmpty) personalSubtitle += ', $age yrs';
    if (weight != null && weight.isNotEmpty) personalSubtitle += ', $weight kg';
    if (height != null && height.isNotEmpty) personalSubtitle += ', $height cm';
    if (gender != null && gender.isNotEmpty) personalSubtitle += ' ($gender)';
    if (personalSubtitle == 'Name') personalSubtitle = 'Name, age, weight, height';

    String goalsSubtitle = '';
    if (goal != null && goal.isNotEmpty) goalsSubtitle += goal;
    if (level != null && level.isNotEmpty) goalsSubtitle += (goalsSubtitle.isEmpty ? level : ' · $level');
    if (goalsSubtitle.isEmpty) goalsSubtitle = 'Muscle building · Fat loss · Endurance';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildAvatarSection(),
              _buildXPBar(),
              _buildSectionLabel('YOUR STATS'),
              _buildStatsGrid(),
              _buildSectionLabel('ACTIVE PROGRAM'),
              _buildActiveProgramRing(),
              _buildSectionLabel('WEEKLY ACTIVITY'),
              _buildWeeklyActivityChart(),
              _buildSectionLabel('THIS WEEK\'S STREAK'),
              _buildStreakSection(),
              _buildSectionLabel('ACHIEVEMENTS'),
              _buildAchievementsList(),
              _buildSectionLabel('ACCOUNT'),
              _buildSettingsGroup([
                _buildSettingRow(
                  onTap: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const EditProfileSheet(),
                    );
                    if (result == true) _refreshData();
                  },
                  icon: Icons.person_outline,
                  iconColor: AppColors.gold,
                  iconBg: AppColors.gold3,
                  title: 'Personal Info',
                  subtitle: personalSubtitle,
                ),
                _buildSettingRow(
                  onTap: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const EditProfileSheet(),
                    );
                    if (result == true) _refreshData();
                  },
                  icon: Icons.show_chart,
                  iconColor: AppColors.blueText,
                  iconBg: AppColors.blueBg,
                  title: 'Fitness Profile',
                  subtitle: goalsSubtitle,
                ),
                _buildSettingRow(
                  icon: Icons.verified_user_outlined,
                  iconColor: AppColors.greenText,
                  iconBg: AppColors.greenBg,
                  title: 'Subscription',
                  subtitle: 'ATHLÈTE Pro · Active',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Text(
                  'PREFERENCES',
                  style: TextStyle(
                    color: AppColors.dim,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              _buildSettingsGroup([
                _buildSettingRow(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('SELECT UNITS', style: TextStyle(fontFamily: 'Bebas Neue', color: AppColors.text)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('Metric (kg, cm)', style: TextStyle(color: AppColors.text)),
                              onTap: () => Navigator.pop(context),
                            ),
                            ListTile(
                              title: const Text('Imperial (lbs, ft)', style: TextStyle(color: AppColors.text)),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: Icons.straighten,
                  iconColor: AppColors.gold,
                  iconBg: AppColors.gold3,
                  title: 'Units',
                  subtitle: 'kg / lbs · cm / ft',
                ),
                _buildSettingRow(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.blueText,
                  iconBg: AppColors.blueBg,
                  title: 'Rest Timer',
                  subtitle: 'Auto-start between sets',
                  trailing: _buildToggle(_restTimer, (v) => _updateSetting('restTimer', v)),
                ),
                _buildSettingRow(
                  icon: Icons.notifications_none,
                  iconColor: AppColors.muted,
                  iconBg: AppColors.background3,
                  title: 'Notifications',
                  subtitle: 'Workout reminders & streaks',
                  trailing: Consumer<SettingsProvider>(
                    builder: (context, settings, _) => _buildToggle(
                      settings.notificationsEnabled,
                      (v) {
                        settings.toggleNotifications(v);
                        if (v) _showTestNotification();
                      }
                    ),
                  ),
                ),
                _buildSettingRow(
                  icon: Icons.dark_mode_outlined,
                  iconColor: AppColors.muted,
                  iconBg: AppColors.background3,
                  title: 'Dark Mode',
                  subtitle: 'Switch theme',
                  trailing: Consumer<SettingsProvider>(
                    builder: (context, settings, _) => _buildToggle(
                      settings.themeMode == ThemeMode.dark,
                      (v) => settings.toggleTheme(v),
                    ),
                  ),
                ),
                _buildSettingRow(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('PRIVACY SETTINGS', style: TextStyle(fontFamily: 'Bebas Neue', color: AppColors.text)),
                        content: const Text('Your profile is currently private. Only you can see your progress.', style: TextStyle(color: AppColors.muted)),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE', style: TextStyle(color: AppColors.gold)))],
                      ),
                    );
                  },
                  icon: Icons.lock_outline,
                  iconColor: AppColors.greenText,
                  iconBg: AppColors.greenBg,
                  title: 'Privacy',
                  subtitle: 'Who can see your progress',
                ),
              ]),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Text(
                  'SUPPORT',
                  style: TextStyle(
                    color: AppColors.dim,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              _buildSettingsGroup([
                _buildSettingRow(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('HELP CENTER', style: TextStyle(fontFamily: 'Bebas Neue', color: AppColors.text)),
                        content: const Text('Support: support@athlete.app\nFAQs available at athlete.app/help', style: TextStyle(color: AppColors.muted)),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: AppColors.gold)))],
                      ),
                    );
                  },
                  icon: Icons.help_outline,
                  iconColor: AppColors.blueText,
                  iconBg: AppColors.blueBg,
                  title: 'Help Center',
                  subtitle: 'FAQs & how-to guides',
                ),
                _buildSettingRow(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('SEND FEEDBACK', style: TextStyle(fontFamily: 'Bebas Neue', color: AppColors.text)),
                        content: const TextField(
                          maxLines: 3,
                          style: TextStyle(color: AppColors.text),
                          decoration: InputDecoration(
                            hintText: 'Tell us what you think...',
                            hintStyle: TextStyle(color: AppColors.muted),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border2)),
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: AppColors.muted))),
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('SEND', style: TextStyle(color: AppColors.gold))),
                        ],
                      ),
                    );
                  },
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppColors.muted,
                  iconBg: AppColors.background3,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve ATHLÈTE',
                ),
                _buildSettingRow(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('TERMS & PRIVACY', style: TextStyle(fontFamily: 'Bebas Neue', color: AppColors.text)),
                        content: const Text('By using ATHLÈTE, you agree to our Terms of Service and Privacy Policy.', style: TextStyle(color: AppColors.muted)),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE', style: TextStyle(color: AppColors.gold)))],
                      ),
                    );
                  },
                  icon: Icons.description_outlined,
                  iconColor: AppColors.muted,
                  iconBg: AppColors.background3,
                  title: 'Terms & Privacy',
                  subtitle: 'Legal & data policy',
                ),
              ]),
              const SizedBox(height: 24),
              _buildLogoutButton(),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'ATHLÈTE v1.0.0 · © 2025',
                  style: TextStyle(
                    color: AppColors.dim,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, right: 22, top: 20, bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MY PROFILE',
            style: GoogleFonts.bebasNeue(
              fontSize: 22,
              letterSpacing: 2.5,
              color: AppColors.text,
            ),
          ),
          InkWell(
            onTap: () async {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const EditProfileSheet(),
              );
              if (result == true) {
                _refreshData();
              }
            },
            borderRadius: BorderRadius.circular(100),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final name = _prefs?.getString('userName');
    final email = _prefs?.getString('userEmail');
    final displayName = (name != null && name.isNotEmpty) ? name : 'ALEX';
    final displayEmail = (email != null && email.isNotEmpty) ? email : 'alex_lifts@example.com';
    final photoUrl = _prefs?.getString('userPhoto');
    final initials = displayName.isNotEmpty ? displayName.substring(0, 1).toUpperCase() : 'A';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
      child: Row(
        children: [
          Stack(
            children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: photoUrl == null ? AppColors.surface2 : null,
                    image: photoUrl != null 
                        ? (photoUrl.startsWith('/') || photoUrl.contains(':\\'))
                            ? DecorationImage(image: FileImage(File(photoUrl)), fit: BoxFit.cover)
                            : DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover) 
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: photoUrl == null ? Text(
                    initials,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 26,
                      color: AppColors.gold,
                      letterSpacing: 1,
                    ),
                  ) : null,
                ),
              ),
            ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.star, size: 10, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.toUpperCase(),
                      style: GoogleFonts.bebasNeue(
                        fontSize: 26,
                        letterSpacing: 2,
                        color: AppColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      displayEmail,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold3,
                        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 10)),
                          const SizedBox(width: 5),
                          Text(
                            'Level 7 — Intermediate Athlete',
                            style: TextStyle(
                              color: AppColors.gold2,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildXPBar() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Level 7 → Level 8',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                Text(
                  '3,400 / 5,000 XP',
                  style: TextStyle(
                    color: AppColors.gold2,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background3,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.68,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.gold2],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '1,600 XP to next level',
                  style: TextStyle(color: AppColors.dim, fontSize: 10),
                ),
                Text(
                  '68%',
                  style: TextStyle(color: AppColors.dim, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.dim,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.8,
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: LayoutBuilder(builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: (constraints.maxWidth / 2 - 5) / 140,
          children: [
            _buildStatCard('🔥', '42', 'Sessions Done', '+6 this month', AppColors.redText, AppColors.redBg, AppColors.redText),
            _buildStatCard('⚡', '18', 'Day Streak', 'Personal best', AppColors.gold, AppColors.gold3, AppColors.gold2),
            _buildStatCard('⏱️', '76h', 'Total Training', '↑ 14% vs last mo.', AppColors.text, AppColors.blueBg, AppColors.blueText),
            _buildStatCard('🏋️', '9.4T', 'Volume Lifted', '↑ 8% this week', AppColors.text, AppColors.greenBg, AppColors.greenText),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String icon, String val, String label, String delta, Color valColor, Color deltaBg, Color deltaText) {
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
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            val,
            style: GoogleFonts.bebasNeue(
              fontSize: 28,
              letterSpacing: 1,
              color: valColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: deltaBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                delta,
                style: TextStyle(color: deltaText, fontSize: 10, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProgramRing() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: CircularProgressIndicator(
                        value: 0.75,
                        strokeWidth: 7,
                        color: AppColors.gold,
                        backgroundColor: AppColors.gold.withOpacity(0.1),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '75%',
                          style: GoogleFonts.bebasNeue(
                            fontSize: 16,
                            color: AppColors.gold2,
                            letterSpacing: 1,
                          ),
                        ),
                        const Text(
                          'done',
                          style: TextStyle(color: AppColors.muted, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cristiano Ronaldo Program',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Week 9 of 12 · Full Body Performance & Conditioning',
                    style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.55),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      _buildRingMetaItem('Week', '9/12'),
                      _buildRingMetaItem('Sessions', '54/72'),
                      _buildRingMetaItem('Left', '3 wks'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingMetaItem(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.muted, fontSize: 11),
        children: [
          TextSpan(text: '$label '),
          TextSpan(
            text: value,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityChart() {
    final data = [3, 5, 4, 6, 5, 6, 4];
    final labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];
    const maxVal = 6;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Sessions per week',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Last 7 weeks · goal 6/week',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildLegendItem('Done', AppColors.gold),
                    const SizedBox(width: 10),
                    _buildLegendItem('Goal', AppColors.border2),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 72,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              decoration: BoxDecoration(
                                color: AppColors.background3,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                              child: FractionallySizedBox(
                                heightFactor: data[index] / maxVal,
                                widthFactor: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: index == 6 ? AppColors.gold : AppColors.gold.withOpacity(0.3),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(labels[index], style: const TextStyle(color: AppColors.muted, fontSize: 9)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
      ],
    );
  }

  Widget _buildStreakSection() {
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final status = ['done', 'done', 'done', 'done', 'done', 'skip', 'today'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '18 🔥',
                      style: GoogleFonts.bebasNeue(
                        fontSize: 32,
                        color: AppColors.gold,
                        letterSpacing: 2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'day streak — keep it going',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Best streak', style: TextStyle(color: AppColors.muted, fontSize: 11)),
                    const SizedBox(height: 2),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.muted, fontSize: 11),
                        children: [
                          TextSpan(text: 'ever: '),
                          TextSpan(
                            text: '18 days',
                            style: TextStyle(color: AppColors.gold2, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: List.generate(7, (index) {
                final isDone = status[index] == 'done';
                final isToday = status[index] == 'today';
                final isSkip = status[index] == 'skip';

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 6 ? 0 : 5),
                    height: 32,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.gold
                          : isDone
                              ? AppColors.gold3
                              : AppColors.background3,
                      border: isToday
                          ? null
                          : Border.all(color: isDone ? AppColors.gold.withOpacity(0.25) : AppColors.border),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                        color: isToday
                            ? Colors.black
                            : isDone
                                ? AppColors.gold2
                                : AppColors.dim,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        children: [
          _buildAchievementItem('🏆', 'First Sweat', 'Completed your first session', 'Jan 12', true),
          _buildAchievementItem('🔥', 'On Fire', '7-day training streak', 'Feb 3', true),
          _buildAchievementItem('💪', 'Ironclad', 'Lifted 1 tonne in a single week', 'Feb 18', true),
          _buildAchievementItem('⚡', 'Half Way There', 'Completed 50% of a program', 'Mar 5', true),
          _buildAchievementItem('🥇', 'Champion', 'Complete a full 12-week program', '', false),
          _buildAchievementItem('🌟', 'Ronaldo Mode', 'Train 6 days in a row', '', false),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String icon, String name, String desc, String date, bool isUnlocked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnlocked ? AppColors.gold3 : AppColors.background3,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: isUnlocked ? AppColors.gold.withOpacity(0.25) : AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 1),
                    Text(desc, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                  ],
                ),
              ),
              if (isUnlocked)
                Text(date, style: const TextStyle(color: AppColors.dim, fontSize: 10))
              else
                Icon(Icons.lock_outline, color: AppColors.dim, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 1),
                      Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  const Icon(Icons.chevron_right, color: AppColors.dim, size: 16),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ],
    );
  }

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged) {
    return SizedBox(
      height: 20,
      width: 36,
      child: Transform.scale(
        scale: 0.7,
        child: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.gold,
          trackColor: AppColors.border2,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: InkWell(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear(); // Clear local data on logout
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.redText.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Text(
            'Log Out',
            style: TextStyle(
              color: AppColors.redText,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
