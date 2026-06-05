import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/profile_provider.dart';

class FollowersScreen extends ConsumerStatefulWidget {
  const FollowersScreen({super.key});

  @override
  ConsumerState<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends ConsumerState<FollowersScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(followersProvider.notifier).fetchFollowers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(followersProvider.notifier).loadMoreFollowers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final followersState = ref.watch(followersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(followersProvider.notifier).refreshFollowers();
            },
          ),
        ],
      ),
      body: followersState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : followersState.error != null
              ? _buildErrorWidget(isDark, followersState.error!)
              : followersState.followers.isEmpty
                  ? _buildEmptyWidget(isDark)
                  : _buildFollowersList(context, followersState),
    );
  }

  Widget _buildFollowersList(BuildContext context, followersState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Total Followers',
                style: AppTypography.bodyMedium(textColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${followersState.meta.total}',
                  style: AppTypography.labelLarge(AppColors.primaryPurple),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: followersState.followers.length +
                (followersState.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == followersState.followers.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final follower = followersState.followers[index];
              return _buildFollowerItem(isDark, follower);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFollowerItem(bool isDark, dynamic follower) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPurple.withValues(alpha: 0.2),
            ),
            child: follower.avatar != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: follower.avatar!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Shimmer.fromColors(
                          baseColor: const Color(0xFFE0E0E0),
                          highlightColor: const Color(0xFFF5F5F5),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return _buildInitialsAvatar(follower.username);
                      },
                    ),
                  )
                : _buildInitialsAvatar(follower.username),
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  follower.username,
                  style: AppTypography.labelLarge(textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (follower.bio != null && follower.bio!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      follower.bio!,
                      style: AppTypography.bodySmall(secondaryColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action button
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.primaryPurple,
              ),
              onPressed: () {
                // Navigate to follower profile
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('View profile of ${follower.username}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String username) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(bool isDark) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No followers yet',
            style: AppTypography.titleMedium(textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your profile to get followers',
            style: AppTypography.bodySmall(secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark, String error) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load followers',
            style: AppTypography.titleMedium(textColor),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: AppTypography.bodySmall(secondaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(followersProvider.notifier).refreshFollowers();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
