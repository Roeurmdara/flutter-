import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_card.dart';
import '../../../core/theme/app_colors.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? leadingEmoji;
  final List<String> tags;
  final String? statusLabel;
  final Color? statusColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingEmoji,
    this.tags = const [],
    this.statusLabel,
    this.statusColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        // Tightened vertical padding keeps the overall card height short
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left icon/emoji
            if (leadingEmoji != null) ...[
              Container(
                width: 30, // Compacted diameter
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.primaryPurple.withValues(alpha: 0.08),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Text(
                    leadingEmoji!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Content Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 3), // Reduced gap to pull tags closer
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2, // Tiny padding to save vertical space
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : AppColors.primaryPurple.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.primaryPurple,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing / Status section
            if (trailing != null || statusLabel != null) ...[
              const SizedBox(width: 10),
              if (trailing != null)
                trailing!
              else if (statusLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5, // Shorter badge padding
                  ),
                  decoration: BoxDecoration(
                    color: (statusColor ?? AppColors.primaryPurple)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    statusLabel!,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: statusColor ?? AppColors.primaryPurple,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}