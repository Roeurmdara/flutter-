import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_model.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/community_provider.dart';
import 'community_posts_feed_screen.dart';
import 'community_screen.dart' show communityColor;

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
  }

  @override
  void dispose() {
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
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(children: [
        // ── Purple header ──
        Container(
          width: double.infinity,
          color: AppColors.primaryPurple,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(children: [
            Text(
              widget.community.name,
              style: AppTypography.headlineLarge(Colors.white).copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2),
            ),
            const SizedBox(height: 6),
            Text(
              '${_fmtCount(widget.community.memberCount)} members',
              style: AppTypography.bodySmall(
                      Colors.white.withValues(alpha: 0.75))
                  .copyWith(fontSize: 13),
            ),
          ]),
        ),

        // ── Single Transform wrapping BOTH TabBar + TabBarView ──
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -16),
            child: Column(children: [
              // TabBar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: TabBar(
                    controller: _tab,
                    labelColor: AppColors.primaryPurple,
                    unselectedLabelColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    indicatorColor: AppColors.primaryPurple,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    splashBorderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    splashFactory: InkRipple.splashFactory,
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return AppColors.primaryPurple.withValues(alpha: 0.08);
                      }
                      return Colors.transparent;
                    }),
                    labelStyle:
                        AppTypography.bodyMedium(AppColors.primaryPurple)
                            .copyWith(
                                fontSize: 14, fontWeight: FontWeight.w600),
                    tabs: const [Tab(text: 'About'), Tab(text: 'Feed')],
                  ),
                ),
              ),

              // TabBarView — fills remaining space, NO second Transform.translate
              Expanded(
                child: TabBarView(controller: _tab, children: [
                  _AboutTab(
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
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  String _fmtCount(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k'
      : '$n';
}

// ─── About Tab ────────────────────────────────────────────────────────────────

class _AboutTab extends ConsumerWidget {
  final Community community;
  final bool isDark;
  final bool isJoined;
  final bool canJoin;
  final Color color;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _AboutTab({
    required this.community,
    required this.isDark,
    required this.isJoined,
    required this.canJoin,
    required this.color,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final detailActionColor = isJoined
        ? const Color(0xFFD32F2F)
        : canJoin
            ? AppColors.primaryPurple
            : Colors.grey;

    // Fetch creator profile
    final creatorAsync =
        ref.watch(userProfileByIdProvider(community.createdBy));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('About',
              style: AppTypography.bodyMedium(text)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          Text(community.description,
              style: AppTypography.bodySmall(sub)
                  .copyWith(height: 1.6, fontSize: 13.5)),
          const SizedBox(height: 14),
          Text('${community.memberCount} members',
              style: AppTypography.bodySmall(sub).copyWith(fontSize: 12)),
          const SizedBox(height: 12),
          Text('Created by',
              style: AppTypography.bodySmall(sub).copyWith(fontSize: 11)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showCreatorProfile(context, community, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: creatorAsync.when(
                data: (response) => Text(
                  _creatorDisplayName(response.data, community),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                loading: () => const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                error: (_, __) => Text(
                  _creatorFallbackName(community),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 20),

          // ── Join / Leave ──
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isJoined
                  ? onLeave
                  : canJoin
                      ? onJoin
                      : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: detailActionColor.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
              ),
              child: Text(
                isJoined
                    ? 'Leave community'
                    : canJoin
                        ? 'Join community'
                        : 'Community closed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: detailActionColor,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showCreatorProfile(
      BuildContext context, Community community, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, refInModal, child) {
          final creatorId = community.createdBy;
          final creatorAsync =
              refInModal.watch(userProfileByIdProvider(creatorId));
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creator',
                  style: AppTypography.headlineSmall(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 16),
                creatorAsync.when(
                  data: (response) {
                    final profile = response.data;
                    if (profile == null && community.creatorName == null) {
                      return _CreatorIdFallback(
                        displayName: _creatorFallbackName(community),
                        isDark: isDark,
                      );
                    }
                    return _CreatorAccountPreview(
                      username:
                          profile?.username ?? community.creatorName ?? 'Creator',
                      avatarUrl: profile?.avatarUrl ?? community.creatorAvatar,
                      bio: profile?.bio,
                      isDark: isDark,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => _CreatorIdFallback(
                    displayName: _creatorFallbackName(community),
                    isDark: isDark,
                    message: 'Creator profile is unavailable right now.',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CreatorAccountPreview extends StatelessWidget {
  final String username;
  final String? avatarUrl;
  final String? bio;
  final bool isDark;

  const _CreatorAccountPreview({
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
    final validAvatar = _validCreatorImageUrl(avatarUrl);
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
                      ? _CreatorInitial(displayName)
                      : Image.network(
                          validAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _CreatorInitial(displayName),
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

class _CreatorIdFallback extends StatelessWidget {
  final String displayName;
  final bool isDark;
  final String? message;

  const _CreatorIdFallback({
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

class _CreatorInitial extends StatelessWidget {
  final String name;

  const _CreatorInitial(this.name);

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

String? _validCreatorImageUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  return trimmed;
}

String _creatorDisplayName(UserProfile? profile, Community community) {
  final profileName = profile?.username.trim();
  if (profileName != null && profileName.isNotEmpty) return profileName;
  return _creatorFallbackName(community);
}

String _creatorFallbackName(Community community) {
  final embeddedName = community.creatorName?.trim();
  if (embeddedName != null && embeddedName.isNotEmpty) return embeddedName;
  return 'Creator';
}
