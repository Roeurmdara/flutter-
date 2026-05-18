import 'package:flutter/material.dart';

/// App Colors - Purple + Green Gradient Theme
class AppColors {
  // Primary Colors - Purple Gradient
  static const Color primaryPurple = Color(0xFF7C3AED); // Vibrant Purple
  static const Color primaryPurpleDark = Color(0xFF6D28D9); // Dark Purple
  static const Color primaryPurpleLight = Color(0xFF9F7AEA); // Light Purple

  // Secondary Colors - Green
  static const Color secondaryGreen = Color(0xFF10B981); // Emerald Green
  static const Color secondaryGreenDark = Color(0xFF059669); // Dark Green
  static const Color secondaryGreenLight = Color(0xFF6EE7B7); // Light Green

  // Neutral Colors - Light Mode
  static const Color lightBackground = Color(0xFFFAFAFA); // Almost white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightText = Color(0xFF1F2937); // Dark gray
  static const Color lightTextSecondary = Color(0xFF6B7280); // Medium gray
  static const Color lightBorder = Color(0xFFE5E7EB); // Light gray

  // Neutral Colors - Dark Mode
  static const Color darkBackground = Color(0xFF0F172A); // Very dark blue
  static const Color darkSurface = Color(0xFF1E293B); // Dark blue-gray
  static const Color darkText = Color(0xFFF8FAFC); // Almost white
  static const Color darkTextSecondary = Color(0xFFA1A5B4); // Light gray
  static const Color darkBorder = Color(0xFF334155); // Dark gray

  // Accent Colors
  static const Color accentOrange = Color(0xFFF97316); // Orange
  static const Color accentRed = Color(0xFFEF4444); // Red
  static const Color accentBlue = Color(0xFF3B82F6); // Blue
  static const Color accentYellow = Color(0xFFFBBF24); // Amber

  // Status Colors
  static const Color success = Color(0xFF22C55E); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF0EA5E9); // Sky

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000); // 10% black
  static const Color shadowMedium = Color(0x26000000); // 15% black
  static const Color shadowDark = Color(0x4D000000); // 30% black

  // Gradient Colors
  static const List<Color> purpleGradient = [
    primaryPurple,
    primaryPurpleDark,
  ];

  static const List<Color> greenGradient = [
    secondaryGreen,
    secondaryGreenDark,
  ];

  static const List<Color> mixedGradient = [
    primaryPurple,
    secondaryGreen,
  ];

  // Get colors based on brightness
  static AppColorsScheme light() => AppColorsScheme.light();
  static AppColorsScheme dark() => AppColorsScheme.dark();
}

/// Color Scheme for Light/Dark modes
class AppColorsScheme {
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color border;
  final Color primary;
  final Color secondary;

  AppColorsScheme({
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.border,
    required this.primary,
    required this.secondary,
  });

  factory AppColorsScheme.light() => AppColorsScheme(
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        text: AppColors.lightText,
        textSecondary: AppColors.lightTextSecondary,
        border: AppColors.lightBorder,
        primary: AppColors.primaryPurple,
        secondary: AppColors.secondaryGreen,
      );

  factory AppColorsScheme.dark() => AppColorsScheme(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        text: AppColors.darkText,
        textSecondary: AppColors.darkTextSecondary,
        border: AppColors.darkBorder,
        primary: AppColors.primaryPurple,
        secondary: AppColors.secondaryGreen,
      );
}
