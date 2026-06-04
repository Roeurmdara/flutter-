import 'package:flutter/material.dart';

/// Typography Configuration
class AppTypography {
  static TextStyle _poppins({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required double height,
    required double letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required double height,
    required double letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Display Styles - Large Headlines
  static TextStyle displayLarge(Color color) {
    return _poppins(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.25,
      letterSpacing: -0.5,
    );
  }

  static TextStyle displayMedium(Color color) {
    return _poppins(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.3,
      letterSpacing: -0.3,
    );
  }

  static TextStyle displaySmall(Color color) {
    return _poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.35,
      letterSpacing: 0,
    );
  }

  // Headline Styles
  static TextStyle headlineLarge(Color color) {
    return _poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
      letterSpacing: 0,
    );
  }

  static TextStyle headlineMedium(Color color) {
    return _poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
      letterSpacing: 0,
    );
  }

  static TextStyle headlineSmall(Color color) {
    return _poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.4,
      letterSpacing: 0,
    );
  }

  // Title Styles
  static TextStyle titleLarge(Color color) {
    return _poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.5,
      letterSpacing: 0.15,
    );
  }

  static TextStyle titleMedium(Color color) {
    return _poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.5,
      letterSpacing: 0.1,
    );
  }

  static TextStyle titleSmall(Color color) {
    return _poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.5,
      letterSpacing: 0.1,
    );
  }

  // Body Styles
  static TextStyle bodyLarge(Color color) {
    return _inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
      letterSpacing: 0.5,
    );
  }

  static TextStyle bodyMedium(Color color) {
    return _inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
      letterSpacing: 0.25,
    );
  }

  static TextStyle bodySmall(Color color) {
    return _inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
      letterSpacing: 0.4,
    );
  }

  // Label Styles
  static TextStyle labelLarge(Color color) {
    return _poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.43,
      letterSpacing: 0.1,
    );
  }

  static TextStyle labelMedium(Color color) {
    return _poppins(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.5,
      letterSpacing: 0.5,
    );
  }

  static TextStyle labelSmall(Color color) {
    return _poppins(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.45,
      letterSpacing: 0.5,
    );
  }

  // Button Styles
  static TextStyle buttonLarge(Color color) {
    return _poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.5,
      letterSpacing: 0.15,
    );
  }

  static TextStyle buttonMedium(Color color) {
    return _poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.42,
      letterSpacing: 0.1,
    );
  }

  static TextStyle buttonSmall(Color color) {
    return _poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.33,
      letterSpacing: 0.5,
    );
  }
}
