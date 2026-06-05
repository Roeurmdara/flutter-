import 'package:flutter/material.dart';

/// App Colors - Purple + Green Gradient Theme (Enhanced)
class AppColors {
  // Primary Colors - Purple Gradient
  static const Color primaryPurple = Color(0xFF7C3AED); // Vibrant Purple
  static const Color primaryPurpleDark = Color(0xFF6D28D9); // Dark Purple
  static const Color primaryPurpleLight = Color(0xFF9F7AEA); // Light Purple
  static const Color primaryPurpleDeep = Color(0xFF5B21B6); // Deep Purple

  // Secondary Colors - Green
  static const Color secondaryGreen = Color(0xFF10B981); // Emerald Green
  static const Color secondaryGreenDark = Color(0xFF059669); // Dark Green
  static const Color secondaryGreenLight = Color(0xFF6EE7B7); // Light Green

  // Neutral Colors - Light Mode
  static const Color lightBackground = Color(0xFFF8F7FC); // Soft purple tint
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightSurfaceElevated = Color(0xFFFDFCFF); // Slightly lifted
  static const Color lightText = Color(0xFF1A1625); // Deep purple-black
  static const Color lightTextSecondary = Color(0xFF6E6A7C); // Muted purple-gray
  static const Color lightBorder = Color(0xFFEAE6F2); // Soft purple border
  static const Color lightInputFill = Color(0xFFF4F2F9); // Subtle input bg

  // Neutral Colors - Dark Mode
  static const Color darkBackground = Color(0xFF0E0B1A); // Deep dark purple
  static const Color darkSurface = Color(0xFF1A1628); // Dark purple surface
  static const Color darkSurfaceElevated = Color(0xFF211D32); // Lifted surface
  static const Color darkText = Color(0xFFF4F0FF); // Soft white
  static const Color darkTextSecondary = Color(0xFF9B95AE); // Muted lavender
  static const Color darkBorder = Color(0xFF2E2842); // Dark purple border

  // Accent Colors
  static const Color accentOrange = Color(0xFFF97316); // Orange
  static const Color accentRed = Color(0xFFEF4444); // Red
  static const Color accentBlue = Color(0xFF3B82F6); // Blue
  static const Color accentYellow = Color(0xFFFBBF24); // Amber

  // Status Colors
  static const Color success = Color(0xFF22C55E); // Green
  static const Color successSoft = Color(0xFFDCFCE7); // Green tint
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorSoft = Color(0xFFFEE2E2); // Red tint
  static const Color info = Color(0xFF0EA5E9); // Sky

  // Shadow Colors
  static const Color shadowLight = Color(0x0D7C3AED); // Purple-tinted 5%
  static const Color shadowMedium = Color(0x1A7C3AED); // Purple-tinted 10%
  static const Color shadowDark = Color(0x337C3AED); // Purple-tinted 20%
  static const Color shadowCard = Color(0x0A000000); // Neutral 4%

  // Glassmorphism
  static const Color glassBorderLight = Color(0x20FFFFFF); // White 12%
  static const Color glassBorderDark = Color(0x15FFFFFF); // White 8%
  static const Color glassOverlayLight = Color(0x08FFFFFF); // White 3%
  static const Color glassOverlayDark = Color(0x0DFFFFFF); // White 5%

  // Shimmer
  static const Color shimmerBaseLight = Color(0xFFEDE8F5);
  static const Color shimmerHighlightLight = Color(0xFFF8F6FC);
  static const Color shimmerBaseDark = Color(0xFF2A2540);
  static const Color shimmerHighlightDark = Color(0xFF332E4A);

  // Gradient Colors
  static const List<Color> purpleGradient = [
    primaryPurple,
    primaryPurpleDark,
  ];

  static const List<Color> heroGradient = [
    Color(0xFF7C3AED),
    Color(0xFF6366F1), // Indigo blend
  ];

  static const List<Color> heroGradientDark = [
    Color(0xFF5B21B6),
    Color(0xFF4338CA),
  ];

  static const List<Color> greenGradient = [
    secondaryGreen,
    secondaryGreenDark,
  ];

  static const List<Color> mixedGradient = [
    primaryPurple,
    secondaryGreen,
  ];

  static const List<Color> cardGlow = [
    Color(0x0D7C3AED), // 5% purple
    Color(0x00000000), // transparent
  ];

  // Get colors based on brightness
  static AppColorsScheme light() => AppColorsScheme.light();
  static AppColorsScheme dark() => AppColorsScheme.dark();
}

/// Color Scheme for Light/Dark modes
class AppColorsScheme {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color text;
  final Color textSecondary;
  final Color border;
  final Color primary;
  final Color secondary;

  AppColorsScheme({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.text,
    required this.textSecondary,
    required this.border,
    required this.primary,
    required this.secondary,
  });

  factory AppColorsScheme.light() => AppColorsScheme(
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        surfaceElevated: AppColors.lightSurfaceElevated,
        text: AppColors.lightText,
        textSecondary: AppColors.lightTextSecondary,
        border: AppColors.lightBorder,
        primary: AppColors.primaryPurple,
        secondary: AppColors.secondaryGreen,
      );

  factory AppColorsScheme.dark() => AppColorsScheme(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfaceElevated: AppColors.darkSurfaceElevated,
        text: AppColors.darkText,
        textSecondary: AppColors.darkTextSecondary,
        border: AppColors.darkBorder,
        primary: AppColors.primaryPurple,
        secondary: AppColors.secondaryGreen,
      );
}
