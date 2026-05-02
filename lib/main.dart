import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'theme/app_colors.dart';
import 'screens/auth/splash_screen.dart';
import 'services/localization_service.dart';
import 'services/workout_provider.dart';
import 'services/subscription_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://zcbujmjqfozuujioxrio.supabase.co',
    anonKey: 'sb_publishable_p4PBU3piZ1SHgV6CfPAZGA_sinYhpUn',
  );
  
  // Initialize Notifications
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: AppColors.gold,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
    debug: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: const AthleteApp(),
    ),
  );
}

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _notificationsEnabled = true;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('darkMode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    final langCode = prefs.getString('languageCode') ?? 'en';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', enabled);
    
    if (enabled) {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    notifyListeners();
  }
}

class SmoothScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

class AthleteApp extends StatelessWidget {
  const AthleteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return MaterialApp(
      title: 'Athlete',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      scrollBehavior: SmoothScrollBehavior(),
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
        Locale('es'),
        Locale('pt'),
        Locale('de'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<QuizScreenState> _quizKey = GlobalKey<QuizScreenState>();
  final GlobalKey<ProgressScreenState> _progressKey = GlobalKey<ProgressScreenState>();
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(key: _homeKey),
      QuizScreen(key: _quizKey),
      ProgressScreen(key: _progressKey),
      ProfileScreen(key: _profileKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            selectedItemColor: AppColors.gold,
            unselectedItemColor: AppColors.muted,
            elevation: 0,
            onTap: (index) {
              if (_currentIndex == index) {
                switch (index) {
                  case 0:
                    _homeKey.currentState?.scrollToTop();
                    break;
                  case 1:
                    _quizKey.currentState?.scrollToTop();
                    break;
                  case 2:
                    _progressKey.currentState?.scrollToTop();
                    break;
                  case 3:
                    _profileKey.currentState?.scrollToTop();
                    break;
                }
              }
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined, size: 22), activeIcon: const Icon(Icons.home, size: 22), label: L10n.s(context, 'nav_home')),
              BottomNavigationBarItem(icon: const Icon(Icons.help_outline, size: 22), activeIcon: const Icon(Icons.help, size: 22), label: L10n.s(context, 'nav_quiz')),
              BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined, size: 22), activeIcon: const Icon(Icons.bar_chart, size: 22), label: L10n.s(context, 'nav_progress')),
              BottomNavigationBarItem(icon: const Icon(Icons.person_outline, size: 22), activeIcon: const Icon(Icons.person, size: 22), label: L10n.s(context, 'nav_profile')),
            ],
          ),
        ),
      ),
    );
  }
}
