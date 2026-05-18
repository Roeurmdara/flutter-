import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _hasSeenOnboarding = false;
  bool _isLoggedIn = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  // ─── Load saved data ─────────────────────────────────────────────────────
  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
      _hasSeenOnboarding =
          prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
      _isLoggedIn = prefs.getString(AppConstants.keyUserToken) != null;
      _initialized = true;
    });
  }

  // ─── Theme toggle ───────────────────────────────────────────────────────
  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, isDark);

    setState(() {
      _isDarkMode = isDark;
    });
  }

  // ─── Complete onboarding ────────────────────────────────────────────────
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);

    setState(() {
      _hasSeenOnboarding = true;
    });
  }

  // ─── Login success ───────────────────────────────────────────────────────
  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserToken, "token");

    setState(() {
      _isLoggedIn = true;
    });
  }

  // ─── Logout ─────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserToken);

    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,

      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: _buildHome(),
    );
  }

  // ─── Navigation logic ───────────────────────────────────────────────────
  Widget _buildHome() {
    if (!_hasSeenOnboarding) {
      return OnboardingScreen(
        onCompleted: _completeOnboarding,
      );
    }

    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: _login,
      );
    }

    return HomeScreen(
      isDarkMode: _isDarkMode,
      onThemeToggle: _toggleTheme,
      onLogout: _logout,
    );
  }
}