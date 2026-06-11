import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/community_model.dart';
import '../../../../data/models/profile_model.dart';

class CreatorAccountPreview extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final String? bio;
  final bool isDark;

  const CreatorAccountPreview({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final validAvatar = validCreatorImageUrl(avatarUrl);
    final displayName = username.trim().isEmpty ? 'Unknown user' : username;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: validAvatar == null
                      ? CreatorInitial(displayName)
                      : Image.network(
                          validAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              CreatorInitial(displayName),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@$displayName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (bio != null && bio!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              bio!.trim(),
              style: AppTypography.bodySmall(subColor).copyWith(height: 1.45),
            ),
          ],
        ],
      ),
    );
  }
}

class CreatorIdFallback extends StatelessWidget {
  final String displayName;
  final bool isDark;
  final String? message;

  const CreatorIdFallback({
    super.key,
    required this.displayName,
    required this.isDark,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message != null) ...[
            Text(
              message!,
              style: AppTypography.bodySmall(subColor),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            displayName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}

class CreatorInitial extends StatelessWidget {
  final String name;

  const CreatorInitial(this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      color: AppColors.primaryPurple.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryPurple,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

String? validCreatorImageUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  return trimmed;
}

String creatorDisplayName(UserProfile? profile, Community community) {
  final profileName = profile?.username.trim();
  if (profileName != null && profileName.isNotEmpty) return profileName;
  return creatorFallbackName(community);
}

String creatorFallbackName(Community community) {
  final embeddedName = community.creatorName?.trim();
  if (embeddedName != null && embeddedName.isNotEmpty) return embeddedName;
  return 'Creator';
}
