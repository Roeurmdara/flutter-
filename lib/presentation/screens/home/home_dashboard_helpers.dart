import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/habit_model.dart';

// ── Text Helpers ──────────────────────────────────────────────────────────────

String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Morning';
  if (hour < 17) return 'Afternoon';
  return 'Evening';
}

// ── Habit Filtering ───────────────────────────────────────────────────────────

List<Habit> filterHabits(List<Habit> habits, String searchQuery) {
  final query = searchQuery.trim().toLowerCase();
  if (query.isEmpty) return habits;

  return habits.where((habit) {
    final title = habit.title.toLowerCase();
    final category = (habit.category ?? '').toLowerCase();
    final frequency = habit.frequency.toLowerCase();
    return title.contains(query) ||
        category.contains(query) ||
        frequency.contains(query);
  }).toList();
}

// ── Color Helper ──────────────────────────────────────────────────────────────

Color getCategoryColor(Habit habit) {
  final colorHex = habit.colorHex ?? habit.categoryColor;
  if (colorHex != null) {
    try {
      return Color(
          int.parse(colorHex.replaceFirst('#', ''), radix: 16) + 0xFF000000);
    } catch (_) {
      return AppColors.primaryPurple;
    }
  }
  return AppColors.primaryPurple;
}

// ── Streak Assets ─────────────────────────────────────────────────────────────

String getStreakGif(int streak) {
  if (streak >= 20) return 'assets/images/fire-flames.gif';
  if (streak >= 10) return 'assets/images/flame02.gif';
  return 'assets/images/flame.gif';
}

Map<String, dynamic> getFlameConfig(int streak) {
  if (streak >= 20) {
    return {
      'alignment': const Alignment(0.2, 0.0),
      'size': 120.0,
      'angle': 0.0,
    };
  } else if (streak >= 10) {
    return {
      'alignment': const Alignment(0.2, 0.1),
      'size': 120.0,
      'angle': 0.0,
    };
  } else {
    return {
      'alignment': const Alignment(-1.3, 0.1),
      'size': 100.0,
      'angle': 0.1,
    };
  }
}