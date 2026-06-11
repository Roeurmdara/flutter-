import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_model.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/community_provider.dart';
import 'community_posts_feed_screen.dart';
import 'community_screen.dart' show communityColor;
import 'widgets/about_tab.dart';

class CommunityDetailScreen extends ConsumerStatefulWidget {
  final Community community;
  final bool isJoined;

  const CommunityDetailScreen({
    super.key,
    required this.community,
    required this.isJoined,
  });

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tab.removeListener(_handleTabChange);
    _tab.dispose();
    super.dispose();
  }

  Future<void> _joinCommunity() async {
    if (!widget.community.isActive) {
      _showError('${widget.community.name} is not accepting new members.');
      return;
    }

    try {
      await ref
          .read(communityOperationsProvider.notifier)
          .joinCommunity(widget.community.id);
      ref.invalidate(
        communitiesProvider(
          const CommunityPaginationParams(page: 1, perPage: 100),
        ),
      );
      ref.invalidate(communityDetailProvider(widget.community.id));
      ref.invalidate(
        communityPostsProvider(
          PostPaginationParams(
            communityId: widget.community.id,
            page: 1,
            perPage: 10,
          ),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Joined ${widget.community.name}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to join: ${_errorMessage(e)}');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _errorMessage(Object error) {
    if (error is ApiException && error.data is Map<String, dynamic>) {
      final data = error.data as Map<String, dynamic>;
      final apiError = data['error'];
      if (apiError is Map<String, dynamic> && apiError['message'] != null) {
        return apiError['message'].toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    return error.toString();
  }

  Future<void> _confirmLeaveCommunity() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Leave community?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'You will no longer see posts from ${widget.community.name}.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(true),
            child: const Text(
              'Leave',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    try {
      await ref
          .read(communityOperationsProvider.notifier)
          .leaveCommunity(widget.community.id);
      ref.invalidate(
        communitiesProvider(
          const CommunityPaginationParams(page: 1, perPage: 100),
        ),
      );
      ref.invalidate(communityDetailProvider(widget.community.id));
      ref.invalidate(
        communityPostsProvider(
          PostPaginationParams(
            communityId: widget.community.id,
            page: 1,
            perPage: 10,
          ),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Left ${widget.community.name}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to leave: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isJoined = ref
        .watch(sessionProvider)
        .joinedCommunityIds
        .contains(widget.community.id);
    final color = communityColor(widget.community);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // TabBar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
            ),
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.primaryPurple,
              unselectedLabelColor: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              indicatorColor: AppColors.primaryPurple,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: AppTypography.bodyMedium(AppColors.primaryPurple)
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'About'), Tab(text: 'Feed')],
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                AboutTab(
                  community: widget.community,
                  isDark: isDark,
                  isJoined: isJoined,
                  canJoin: widget.community.isActive,
                  color: color,
                  onJoin: _joinCommunity,
                  onLeave: _confirmLeaveCommunity,
                ),
                CommunityPostsFeedScreen(
                  communityId: widget.community.id,
                  communityName: widget.community.name,
                  showAppBar: false,
                  canCreatePosts: isJoined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
