import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_model.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/session_provider.dart';
import 'community_detail_screen.dart';
import 'community_screen.dart' show communityColor, communityEmoji;

// ─── Community Search Screen ──────────────────────────────────────────────────

class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  ConsumerState<CommunitySearchScreen> createState() =>
      _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends ConsumerState<CommunitySearchScreen> {
  final _ctrl = TextEditingController();
  bool _isNavigating = false; // 👈 guard flag

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _navigateTo(Community c, bool isJoined) {
    if (_isNavigating) return; // 👈 prevent double push
    _isNavigating = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(
          community: c,
          isJoined: isJoined,
        ),
      ),
    ).then((_) => _isNavigating = false); // 👈 reset after returning
  }

  Future<void> _joinCommunity(Community community) async {
    if (!community.isActive) {
      _showError('${community.name} is not accepting new members.');
      return;
    }

    try {
      await ref
          .read(communityOperationsProvider.notifier)
          .joinCommunity(community.id);
      ref.invalidate(
        communitiesProvider(
          const CommunityPaginationParams(page: 1, perPage: 100),
        ),
      );
      ref.invalidate(communityDetailProvider(community.id));
      ref.invalidate(
        communityPostsProvider(
          PostPaginationParams(communityId: community.id, page: 1, perPage: 10),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Joined ${community.name}',
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

  Future<void> _confirmLeaveCommunity(Community community) async {
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
          'You will no longer see posts from ${community.name}.',
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
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    try {
      await ref
          .read(communityOperationsProvider.notifier)
          .leaveCommunity(community.id);
      ref.invalidate(
        communitiesProvider(
          const CommunityPaginationParams(page: 1, perPage: 100),
        ),
      );
      ref.invalidate(communityDetailProvider(community.id));
      ref.invalidate(
        communityPostsProvider(
          PostPaginationParams(communityId: community.id, page: 1, perPage: 10),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Left ${community.name}',
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
    final joinedIds = ref.watch(sessionProvider).joinedCommunityIds;

    final allAsync = ref.watch(
      communitiesProvider(
          const CommunityPaginationParams(page: 1, perPage: 100)),
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Column(children: [
        // ── Search bar ──
        Container(
          color: isDark ? AppColors.darkSurface : Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: TextField(
            controller: _ctrl,
            onChanged: (_) => setState(() {}),
            style: AppTypography.bodyMedium(
                isDark ? AppColors.darkText : AppColors.lightText),
            decoration: InputDecoration(
              hintText: 'Search communities...',
              hintStyle: AppTypography.bodyMedium(isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary),
              prefixIcon: Icon(Icons.search_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  size: 22),
              filled: true,
              fillColor:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        // ── Results ──
        Expanded(
          child: allAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryPurple, strokeWidth: 2.5)),
            error: (_, __) => Center(
                child: Text('Error loading communities',
                    style: AppTypography.bodyMedium(
                        isDark ? AppColors.darkText : AppColors.lightText))),
            data: (response) {
              final q = _ctrl.text.toLowerCase();
              final list = response.communities
                  .where((c) =>
                      c.name.toLowerCase().contains(q) ||
                      c.description.toLowerCase().contains(q))
                  .toList();

              if (list.isEmpty) {
                return Center(
                  child: Text(
                    q.isEmpty
                        ? 'Start typing to search'
                        : 'No results for "$q"',
                    style: AppTypography.bodyMedium(isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  final isJoined = joinedIds.contains(c.id);
                  return _SearchTile(
                    community: c,
                    isDark: isDark,
                    isJoined: isJoined,
                    canJoin: c.isActive,
                    onTap: () => _navigateTo(c, isJoined), // 👈 guarded
                    onJoin: () => _joinCommunity(c),
                    onLeave: () => _confirmLeaveCommunity(c),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ─── Search Tile ──────────────────────────────────────────────────────────────

class _SearchTile extends StatelessWidget {
  final Community community;
  final bool isDark, isJoined, canJoin;
  final VoidCallback onTap;
  final Future<void> Function() onJoin;
  final Future<void> Function() onLeave;

  const _SearchTile({
    required this.community,
    required this.isDark,
    required this.isJoined,
    required this.canJoin,
    required this.onTap,
    required this.onJoin,
    required this.onLeave,
  });

  String _fmt(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k'
      : '$n';

  @override
  Widget build(BuildContext context) {
    final color = communityColor(community);
    final emoji = communityEmoji(community);

    final actionColor = isJoined
        ? const Color(0xFFE53935)
        : canJoin
            ? AppColors.primaryPurple
            : Colors.grey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // 👈 prevent bubbling issues
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isJoined
                ? actionColor.withOpacity(0.2)
                : color.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(children: [
          // Cover image (if available) else emoji badge
          if (community.coverImage != null && community.coverImage!.isNotEmpty)
            ClipOval(
              child: Container(
                width: 60,
                height: 60,
                color: color.withOpacity(0.06),
                child: Image.network(
                  community.coverImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: color.withOpacity(0.1)),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
          const SizedBox(width: 14),

          // Name + member count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium(
                          isDark ? AppColors.darkText : AppColors.lightText)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmt(community.memberCount)} members',
                  style: AppTypography.bodySmall(isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Join / Leave button
          TextButton(
            onPressed: isJoined
                ? onLeave
                : canJoin
                    ? onJoin
                    : null,
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 34),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: actionColor.withOpacity(0.08),
              disabledBackgroundColor: Colors.grey.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: actionColor.withOpacity(0.2),
                ),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isJoined
                  ? 'Leave'
                  : canJoin
                      ? 'Join'
                      : 'Closed',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: actionColor,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
