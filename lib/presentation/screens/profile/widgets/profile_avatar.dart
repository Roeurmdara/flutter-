import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final double size;
  final int cacheKey;

  const ProfileAvatar({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.size,
    this.cacheKey = 0,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = avatarUrl?.trim() ?? '';

    if (trimmed.isNotEmpty) {
      final bustedUrl = cacheKey > 0 ? '$trimmed?v=$cacheKey' : trimmed;

      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: bustedUrl,
          cacheKey: bustedUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
          placeholder: (_, __) {
            return Shimmer.fromColors(
              baseColor: AppColors.shimmerBaseLight,
              highlightColor: AppColors.shimmerHighlightLight,
              child: Container(
                width: size,
                height: size,
                color: AppColors.shimmerBaseLight,
              ),
            );
          },
          errorWidget: (_, __, ___) {
            return _buildInitialsAvatar(username, size);
          },
        ),
      );
    }

    return _buildInitialsAvatar(username, size);
  }

  Widget _buildInitialsAvatar(String username, double size) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
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
}
