import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/profile_provider.dart';

class OtherUserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends ConsumerState<OtherUserProfileScreen> {
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  int _followersCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFollowStats();
    });
  }

  Future<void> _loadFollowStats() async {
    try {
      final service = ref.read(userProfileServiceProvider);
      final stats = await service.getFollowStats(widget.userId);
      if (stats != null && mounted) {
        setState(() {
          _isFollowing = stats['is_following'] == true;
          _followersCount = (stats['followers_count'] as num?)?.toInt() ?? 0;
          _followingCount = (stats['following_count'] as num?)?.toInt() ?? 0;
        });
      }
    } catch (_) {
      // Stats are non-critical; profile displays without them.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final profileAsync = ref.watch(userProfileByIdProvider(widget.userId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: profileAsync.when(
        data: (response) {
          final profile = response.data;
          if (profile == null) {
            return Center(
              child: Text('User not found', style: TextStyle(color: sub)),
            );
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(profile, isDark),
                  const SizedBox(height: 24),
                  _buildFollowButton(isDark),
                  const SizedBox(height: 24),
                  _buildStatsRow(isDark),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.accentOrange),
                const SizedBox(height: 12),
                Text('Could not load profile', style: TextStyle(color: sub)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic profile, bool isDark) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final avatarUrl = profile.avatarUrl;
    final username = profile.username as String? ?? 'User';
    final bio = profile.bio;

    return Column(
      children: [
        ClipOval(
          child: SizedBox(
            width: 80,
            height: 80,
            child: avatarUrl != null && avatarUrl.trim().isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _buildInitialAvatar(username),
                  )
                : _buildInitialAvatar(username),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: text,
          ),
        ),
        if (bio != null && bio.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            bio.trim(),
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall(sub).copyWith(height: 1.45),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(bool isDark) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('$_followersCount', 'Followers', text, sub),
          Container(width: 1, height: 30, color: isDark ? Colors.white12 : Colors.black12),
          _statItem('$_followingCount', 'Following', text, sub),
        ],
      ),
    );
  }

  Widget _statItem(String count, String label, Color text, Color sub) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: sub),
        ),
      ],
    );
  }

  Widget _buildFollowButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: _isFollowLoading
          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          : ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.transparent : AppColors.primaryPurple,
                foregroundColor: _isFollowing ? AppColors.primaryPurple : Colors.white,
                side: _isFollowing ? const BorderSide(color: AppColors.primaryPurple) : null,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                _isFollowing ? 'Unfollow' : 'Follow',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  Widget _buildInitialAvatar(String name) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      color: AppColors.primaryPurple.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryPurple,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Future<void> _toggleFollow() async {
    setState(() => _isFollowLoading = true);
    try {
      final service = ref.read(userProfileServiceProvider);
      if (_isFollowing) {
        await service.unfollowUser(widget.userId);
        setState(() {
          _isFollowing = false;
          _followersCount = (_followersCount - 1).clamp(0, 999999);
        });
      } else {
        await service.followUser(widget.userId);
        setState(() {
          _isFollowing = true;
          _followersCount += 1;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isFollowing ? 'Failed to unfollow' : 'Failed to follow')),
        );
      }
    } finally {
      setState(() => _isFollowLoading = false);
    }
  }
}
