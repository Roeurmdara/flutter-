import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/providers/habit_provider.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import 'edit_profile_form.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToSettings;

  const ProfileScreen({
    super.key,
    this.onNavigateToSettings,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(profileProvider.notifier).fetchUserProfile();
        ref.read(followersProvider.notifier).fetchFollowers();
        ref.read(followingProvider.notifier).fetchFollowing();
        ref.read(habitsProvider.notifier).loadHabits();
      }
    });
  }

  void _openEditProfileSheet(dynamic profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: EditProfileForm(
              profile: profile,
              profileProvider: profileProvider,
              onCancel: () => Navigator.pop(context),
              onSaveSuccess: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                  ),
                );
                ref.read(profileProvider.notifier).fetchUserProfile();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: profileState.isLoading && profile == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : profile != null
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Profile',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.settings_outlined,
                                  color: isDark ? AppColors.darkText : AppColors.lightText,
                                  size: 28,
                                ),
                                onPressed: widget.onNavigateToSettings ?? () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // 2. Avatar Card Stack
                          _buildProfileCardStack(profile, isDark, profileState.avatarVersion),

                          const SizedBox(height: 24),

                          // 3. Action Buttons Row
                          _buildActionButtons(profile, isDark),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildErrorWidget(isDark),
                  ),
      ),
    );
  }

  Widget _buildProfileCardStack(
    dynamic profile,
    bool isDark,
    int avatarVersion,
  ) {
    final username = profile.username as String? ?? '';
    final bio = profile.bio as String?;
    final avatarUrl = profile.avatarUrl as String?;

    final followersState = ref.watch(followersProvider);
    final followingState = ref.watch(followingProvider);
    final habitState = ref.watch(habitsProvider);

    final cardBgColor = isDark ? AppColors.darkSurface : const Color(0xFFE8F1FF);
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // The Light Blue Card
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 45), // space for avatar overlap
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
              if (bio != null && bio.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  bio,
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
                      count: followersState.meta.total,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FollowersScreen(),
                          ),
                        );
                      },
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
                      count: followingState.meta.total,
                      isDark: isDark,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FollowingScreen(),
                          ),
                        );
                      },
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
                      count: habitState.habits.length,
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
            child: _buildAvatarWidget(
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

  Widget _buildActionButtons(dynamic profile, bool isDark) {
    const forestGreen = Color(0xFF1B3D2F);

    return Row(
      children: [
        // Forest green "Edit Profile" button
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => _openEditProfileSheet(profile),
              style: ElevatedButton.styleFrom(
                backgroundColor: forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Secondary icon button (envelope in mockup, edit icon for edit profile here)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.edit_note_rounded,
              color: isDark ? AppColors.darkText : Colors.black.withValues(alpha: 0.7),
            ),
            onPressed: () => _openEditProfileSheet(profile),
            padding: EdgeInsets.zero,
            splashRadius: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWidget({
    required String? avatarUrl,
    required String username,
    required double size,
    int cacheKey = 0,
  }) {
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
            return _buildInitialsAvatar(
              username,
              size,
            );
          },
        ),
      );
    }

    return _buildInitialsAvatar(username, size);
  }

  Widget _buildInitialsAvatar(
    String username,
    double size,
  ) {
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

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load profile',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please ensure you are logged in and have a valid token.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
