import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'profile_avatar.dart';

class ProfileStatsCard extends StatelessWidget {
  final String username;
  final String? bio;
  final String? avatarUrl;
  final int avatarVersion;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final VoidCallback onFollowersTap;
  final VoidCallback onFollowingTap;

  const ProfileStatsCard({
    super.key,
    required this.username,
    required this.bio,
    required this.avatarUrl,
    required this.avatarVersion,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.onFollowersTap,
    required this.onFollowingTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // The Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 45),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.35),
                      AppColors.primaryPurpleDark.withValues(alpha: 0.18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.primaryPurple.withValues(alpha: 0.12),
                      AppColors.primaryPurpleDark.withValues(alpha: 0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.primaryPurple.withValues(alpha: 0.25)
                  : AppColors.primaryPurple.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            children: [
              // User Name & Role Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      username,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Member',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              if (bio != null && bio!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bio!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildStatColumn(
                      label: 'Followers',
                      count: followersCount,
                      isDark: isDark,
                      onTap: onFollowersTap,
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.08),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      label: 'Following',
                      count: followingCount,
                      isDark: isDark,
                      onTap: onFollowingTap,
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.08),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      label: 'Posts',
                      count: postsCount,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Floating Avatar
        Positioned(
          top: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkBackground : Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ProfileAvatar(
              avatarUrl: avatarUrl,
              username: username,
              size: 90,
              cacheKey: avatarVersion,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required String label,
    required int count,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final labelColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280);
    final countColor = isDark ? AppColors.darkText : AppColors.lightText;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: countColor,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}