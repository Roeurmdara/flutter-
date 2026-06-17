import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../community_helpers.dart';
import '../../../../data/models/community_model.dart';

typedef CommunityTap = void Function();

class CommunityCard extends StatelessWidget {
  final Community community;
  final bool isDark;
  final CommunityTap onTap;

  const CommunityCard(
      {required this.community, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = communityColor(community);
    final emoji = communityEmoji(community);
    final nameColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final description = community.description.trim();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                color: color.withValues(alpha: 0.08),
                child: community.coverImage != null &&
                        community.coverImage!.isNotEmpty
                    ? Image.network(
                        community.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(emoji,
                              style: const TextStyle(fontSize: 20)),
                        ),
                        loadingBuilder: (_, child, progress) =>
                            progress == null
                                ? child
                                : const Center(
                                    child: SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1.5),
                                    ),
                                  ),
                      )
                    : Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 20)),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + description + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: nameColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                  
                  const SizedBox(height: 3),
                  Text(
                    community.isActive ? 'Active' : 'Closed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: community.isActive
                          ? AppColors.accentBlue
                          : subColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: subColor.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(int n) =>
    n >= 1000 ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k' : '$n';