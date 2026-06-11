import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_model.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/community_provider.dart';
import 'community_posts_feed_screen.dart';
import 'community_screen.dart' show communityColor;
import 'widgets/about_tab.dart';
import 'widgets/community_card_stack.dart';

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

  void _showCommunityOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final isJoined = ref
        .watch(sessionProvider)
        .joinedCommunityIds
        .contains(widget.community.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Community Options',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('View Guidelines'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guidelines: Be respectful and post content related to the community topic.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              if (isJoined)
                ListTile(
                  leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
                  title: const Text('Leave Community', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLeaveCommunity();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showMembersBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, refInSheet, child) {
            final membersAsyncInSheet = refInSheet.watch(communityMembersProvider(
              CommunityMembersPaginationParams(
                communityId: widget.community.id,
                page: 1,
                perPage: 100,
              ),
            ));

            return Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Members (${widget.community.memberCount})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: membersAsyncInSheet.when(
                      data: (response) {
                        final list = response.members;
                        if (list.isEmpty) {
                          return const Center(child: Text('No members found'));
                        }
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => Divider(
                            color: isDark ? Colors.white10 : Colors.grey[200],
                            height: 1,
                          ),
                          itemBuilder: (context, idx) {
                            final member = list[idx];
                            final displayName = member.username;
                            final avatarUrl = member.avatar;
                            final isCreator = member.userId == widget.community.createdBy;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: SizedBox(
                                      width: 38,
                                      height: 38,
                                      child: avatarUrl == null || avatarUrl.trim().isEmpty
                                          ? Container(
                                              color: AppColors.primaryPurple.withValues(alpha: 0.12),
                                              alignment: Alignment.center,
                                              child: Text(
                                                displayName.isEmpty ? '?' : displayName[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: AppColors.primaryPurple,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : Image.network(
                                              avatarUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: AppColors.primaryPurple.withValues(alpha: 0.12),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  displayName.isEmpty ? '?' : displayName[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: AppColors.primaryPurple,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
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
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: text,
                                          ),
                                        ),
                                        if (member.role == 'admin' || isCreator) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            isCreator ? 'Owner' : 'Admin',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primaryPurple,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (err, _) => Center(
                        child: Text(
                          'Error loading members: $err',
                          style: TextStyle(color: sub),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, Color detailActionColor, bool isJoined) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isJoined
                  ? _confirmLeaveCommunity
                  : widget.community.isActive
                      ? _joinCommunity
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: detailActionColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isJoined
                    ? 'Leave community'
                    : widget.community.isActive
                        ? 'Join community'
                        : 'Community closed',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
              Icons.share_outlined,
              color: isDark ? AppColors.darkText : Colors.black.withValues(alpha: 0.7),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share link copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            padding: EdgeInsets.zero,
            splashRadius: 24,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isJoined = ref
        .watch(sessionProvider)
        .joinedCommunityIds
        .contains(widget.community.id);
    final color = communityColor(widget.community);
    final text = isDark ? AppColors.darkText : AppColors.lightText;

    const forestGreen = Color(0xFF1B3D2F);
    final detailActionColor = isJoined
        ? const Color(0xFFD32F2F)
        : widget.community.isActive
            ? forestGreen
            : Colors.grey;

    return AnimatedBuilder(
      animation: _tab,
      builder: (context, child) {
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
            titleSpacing: 0,
            title: Text(
              _tab.index == 0 ? 'Community' : widget.community.name,
              style: GoogleFonts.poppins(
                fontSize: _tab.index == 0 ? 22 : 18,
                fontWeight: FontWeight.w700,
                color: text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: text,
                  size: 28,
                ),
                onPressed: () => _showCommunityOptions(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                if (_tab.index == 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // Avatar Card Stack
                          CommunityCardStack(
                            community: widget.community,
                            color: color,
                            isDark: isDark,
                            onMembersTap: () => _showMembersBottomSheet(context),
                          ),

                          const SizedBox(height: 24),

                          // Action Buttons Row
                          _buildActionButtons(context, detailActionColor, isJoined),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    child: Container(
                      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tab,
              children: [
                AboutTab(
                  community: widget.community,
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
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
