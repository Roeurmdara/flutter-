import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/providers/session_provider.dart';
import 'data/services/secure_storage_service.dart';

import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-initialize SharedPreferences globally for session loading
  final prefs = await SharedPreferences.getInstance();
  SessionNotifier.initializePrefs(prefs);

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
    final authToken = prefs.getString('auth_token');
    final legacyToken = prefs.getString(AppConstants.keyUserToken);

    setState(() {
      _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
      _hasSeenOnboarding =
          prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
      _isLoggedIn = (authToken != null && authToken.isNotEmpty) ||
          (legacyToken != null &&
              legacyToken.isNotEmpty &&
              legacyToken != 'token');
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
    setState(() {
      _isLoggedIn = true;
    });
  }

  // ─── Logout ─────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await SecureStorageService().clearAuthData();
    await prefs.remove('auth_token');
    await prefs.remove(AppConstants.keyUserToken);

    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: _buildHome(),
      ),
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
