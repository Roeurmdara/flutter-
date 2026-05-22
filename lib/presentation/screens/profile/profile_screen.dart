import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/profile_provider.dart';
import 'edit_profile_form.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToSettings;

  const ProfileScreen({Key? key, this.onNavigateToSettings}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(profileProvider.notifier).fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    if (profileState.isLoading && profile == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: _buildAppBar(isDark, profile),
      );
    }

    return Scaffold(
  
      appBar: _buildAppBar(isDark, profile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            if (_isEditMode && profile != null)
              _buildCard(
                isDark: isDark,
                child: EditProfileForm(
                  profile: profile,
                  profileProvider: profileProvider,
                  onCancel: () => setState(() => _isEditMode = false),
                  onSaveSuccess: () {
                    setState(() => _isEditMode = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully')),
                    );
                  },
                ),
              )
            else if (profile != null) ...[
              _buildProfileHeader(profile, isDark, profileState.avatarVersion),
              const SizedBox(height: 16),
              _buildSectionTitle('Stats', isDark),
              const SizedBox(height: 10),
              _buildStatsRow(isDark),
              const SizedBox(height: 20),
              _buildSectionTitle('Quick Actions', isDark),
              const SizedBox(height: 10),
              _buildQuickActions(isDark),
            ] else
              _buildErrorWidget(isDark),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(bool isDark, dynamic profile) {
    return AppBar(
      title: const Text('Profile'),

      actions: [
        if (!_isEditMode && profile != null) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => setState(() => _isEditMode = true),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: widget.onNavigateToSettings ?? () {},
          ),
        ],
      ],
    );
  }

  // ── Shared flat card wrapper — same style as CommunityScreen ──────────────

  Widget _buildCard({required bool isDark, required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // ── Profile Header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader(dynamic profile, bool isDark, int avatarVersion) {
    final username = profile.username as String? ?? '';
    final bio = profile.bio as String?;
    final avatarUrl = profile.avatarUrl as String?;

    return _buildCard(
      isDark: isDark,
      child: Column(
        children: [
          Stack(alignment: Alignment.bottomRight, children: [
            _buildAvatarWidget(
              avatarUrl: avatarUrl,
              username: username,
              size: 80,
              cacheKey: avatarVersion,
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF22c55e),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  width: 2,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(
            username,
            style: AppTypography.titleLarge(isDark ? AppColors.darkText : AppColors.lightText),
          ),
          if (bio != null && bio.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              bio,
              style: AppTypography.bodySmall(
                isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
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
          placeholder: (_, __) => Shimmer.fromColors(
            baseColor: const Color(0xFFE0E0E0),
            highlightColor: const Color(0xFFF5F5F5),
            child: Container(width: size, height: size, color: const Color(0xFFE0E0E0)),
          ),
          errorWidget: (_, __, ___) => _buildInitialsAvatar(username, size),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryPurple,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTypography.titleLarge(isDark ? AppColors.darkText : AppColors.lightText),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(children: [
      _buildStatCard('∞', 'Streak', '🔥', isDark),
      const SizedBox(width: 10),
      _buildStatCard('∞', 'Habits', '📝', isDark),
      const SizedBox(width: 10),
      _buildStatCard('∞', 'Badges', '🏅', isDark),
    ]);
  }

  Widget _buildStatCard(String value, String label, String icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ]),
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────

  Widget _buildQuickActions(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: [
        _buildQuickActionItem(
          icon: Icons.refresh_rounded,
          title: 'Refresh Profile',
          isDark: isDark,
          onTap: () => ref.read(profileProvider.notifier).fetchUserProfile(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        _buildQuickActionItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          isDark: isDark,
          onTap: widget.onNavigateToSettings ?? () {},
        ),
      ]),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ]),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildErrorWidget(bool isDark) {
    return _buildCard(
      isDark: isDark,
      child: Column(children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.orange),
        const SizedBox(height: 12),
        Text(
          'Unable to load profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please ensure you are logged in and have a valid token.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}