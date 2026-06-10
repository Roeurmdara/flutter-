/// App Constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'HabitFlow';
  static const String appVersion = '1.0.0';

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // API Configuration
  static const String baseUrl = 'https://habit-api.rattanakmony.com/api/v1';
  static const String apiVersion = 'v1';

  // DB
  static const String dbFileName = 'habitflow.db';
  static const int dbVersion = 1;

  // Habit Categories
  static const List<String> habitCategories = [
    'Fitness',
    'Study',
    'Health',
    'Productivity',
    'Lifestyle',
    'Mindset',
  ];

  // Habit Frequencies
  static const List<String> habitFrequencies = [
    'Daily',
    'Weekly',
    'Monthly',
  ];

  // Reminder Times
  static const List<String> reminderTimes = [
    '6:00 AM',
    '8:00 AM',
    '12:00 PM',
    '3:00 PM',
    '6:00 PM',
    '9:00 PM',
  ];

  // Notification Settings Keys
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keySmartReminders = 'smart_reminders';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';

  // Shared Preference Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUsername = 'username';
  static const String keyOnboardingDone = 'onboarding_done';
}
