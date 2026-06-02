import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:io';
// ── Color Picker Bottom Sheet ────────────────────────────────────────────────
void showHabitColorPicker({
  required BuildContext context,
  required bool isDark,
  required Color currentColor,
  required ValueChanged<Color> onColorSelected,
}) {
  final colors = [
    AppColors.primaryPurple,
    AppColors.accentRed,
    AppColors.accentOrange,
    AppColors.accentYellow,
    AppColors.secondaryGreen,
    AppColors.secondaryGreenLight,
    AppColors.accentBlue,
    AppColors.accentOrange,
    const Color(0xFFEC4899), // Pink
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF6366F1), // Indigo
  ];

  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Color',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color.value == currentColor.value;

              return GestureDetector(
                onTap: () {
                  onColorSelected(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

// ── Emoji Picker Bottom Sheet ────────────────────────────────────────────────
void showHabitEmojiPicker({
  required BuildContext context,
  required bool isDark,
  required String currentEmoji,
  required Color currentColor,
  required ValueChanged<String> onEmojiSelected,
}) {
  final emojis = [
    '✨', '⭐', '🌟', '💫', '🔥', '⚡', '💎', '🎯',
    '🏆', '🎉', '🎊', '🎈', '💪', '🚀', '🌈', '🎨',
    '💚', '❤️', '💙', '💛', '🧡', '🤍', '🖤', '💜',
    '😊', '😍', '🤔', '😎', '🥳', '🚀', '👑', '🎁',
    '📚', '🎓', '🏃', '🧘', '🏋️', '🤸', '⛹️', '🚴',
    '🎵', '🎶', '🎤', '🎧', '🎮', '🎲', '🃏', '🎭',
    '🍎', '🍊', '🍋', '🍌', '🍉', '🥗', '🍱', '☕',
    '🌺', '🌸', '🌼', '🌻', '🌷', '🌹', '🥀', '🎀',
  ];

  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Emoji',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              final emoji = emojis[index];
              final isSelected = emoji == currentEmoji;

              return GestureDetector(
                onTap: () {
                  onEmojiSelected(emoji);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected
                        ? currentColor.withOpacity(0.2)
                        : (isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.03)),
                    border: Border.all(
                      color: isSelected
                          ? currentColor
                          : (isDark ? Colors.white12 : Colors.black12),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}