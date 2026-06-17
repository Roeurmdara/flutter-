import 'package:flutter/material.dart';
import '../../../data/models/community_model.dart';

Color communityColor(Community c) {
  if (c.customColor != null) {
    try {
      return Color(
          int.parse('FF${c.customColor!.replaceAll('#', '')}', radix: 16));
    } catch (_) {}
  }
  const fallback = {
    'fitness': Color(0xFFFF6B6B),
    'health': Color(0xFF10B981),
    'productivity': Color(0xFF3B82F6),
    'learning': Color(0xFF8B5CF6),
    'mindfulness': Color(0xFFFBBF24),
    'nutrition': Color(0xFF06B6D4),
    'social': Color(0xFFEC4899),
    'work': Color(0xFF6366F1),
  };
  return fallback[c.categoryId.toLowerCase()] ?? const Color(0xFF7C3AED);
}

String communityEmoji(Community c) {
  if (c.customEmoji != null && c.customEmoji!.isNotEmpty) return c.customEmoji!;
  const fallback = {
    'fitness': '💪',
    'health': '🏥',
    'productivity': '⚡',
    'learning': '📚',
    'mindfulness': '🧘',
    'nutrition': '🥗',
    'social': '👥',
    'work': '💼',
    'hobby': '🎨',
    'gaming': '🎮',
    'sports': '⚽',
    'music': '🎵',
  };
  return fallback[c.categoryId.toLowerCase()] ?? '🌟';
}

String fmtCount(int n) =>
    n >= 1000 ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k' : '$n';
