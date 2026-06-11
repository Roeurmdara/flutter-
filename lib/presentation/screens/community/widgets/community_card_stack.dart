import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/community_model.dart';

class CommunityCardStack extends StatelessWidget {
  final Community community;
  final Color color;
  final bool isDark;
  final VoidCallback onMembersTap;

  const CommunityCardStack({
    super.key,
    required this.community,
    required this.color,
    required this.isDark,
    required this.onMembersTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final cardBgColor = isDark ? AppColors.darkSurface : const Color(0xFFE8F1FF);

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // The card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 45),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              // Community Name & Join Type Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      community.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    community.joinType.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildStatColumn(
                      label: 'Members',
                      count: community.memberCount.toString(),
                      isDark: isDark,
                      onTap: onMembersTap,
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.08),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      label: 'Join Type',
                      count: community.joinType.toUpperCase(),
                      isDark: isDark,
                    ),
                  ),
                  Container(
                    height: 32,
                    width: 1,
                    color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.08),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      label: 'Status',
                      count: community.status.toUpperCase(),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Floating Avatar (Custom Emoji, Cover Image or Initial)
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
            child: _buildAvatarWidget(size: 90),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWidget({required double size}) {
    // 1. Cover Image
    if (community.coverImage != null && community.coverImage!.trim().isNotEmpty) {
      return ClipOval(
        child: Image.network(
          community.coverImage!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _buildEmojiOrInitialAvatar(size),
        ),
      );
    }
    return _buildEmojiOrInitialAvatar(size);
  }

  Widget _buildEmojiOrInitialAvatar(double size) {
    // 2. Custom Emoji
    if (community.customEmoji != null && community.customEmoji!.trim().isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.15),
        ),
        alignment: Alignment.center,
        child: Text(
          community.customEmoji!,
          style: TextStyle(fontSize: size * 0.45),
        ),
      );
    }

    // 3. Initial
    final initial = community.name.isNotEmpty ? community.name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required String label,
    required String count,
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
          count,
          style: GoogleFonts.poppins(
            fontSize: 16,
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
