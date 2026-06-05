import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'app_colors.dart';

// Shadcn light theme configuration
final appShadcnLightTheme = ShadThemeData(
  brightness: Brightness.light,
  colorScheme: const ShadSlateColorScheme.light(
    primary: AppColors.primaryPurple,
    background: AppColors.lightBackground,
    card: AppColors.lightSurface,
    border: AppColors.lightBorder,
    foreground: AppColors.lightText,
    mutedForeground: AppColors.lightTextSecondary,
  ),
);

// Shadcn dark theme configuration
final appShadcnDarkTheme = ShadThemeData(
  brightness: Brightness.dark,
  colorScheme: const ShadSlateColorScheme.dark(
    primary: AppColors.primaryPurple,
    background: AppColors.darkBackground,
    card: AppColors.darkSurface,
    border: AppColors.darkBorder,
    foreground: AppColors.darkText,
    mutedForeground: AppColors.darkTextSecondary,
  ),
);
