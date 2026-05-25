import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_model.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/session_provider.dart';
import 'community_posts_feed_screen.dart';

// ─── Community Search Screen ──────────────────────────────────────────
class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunitySearchScreen> createState() =>
      _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends ConsumerState<CommunitySearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = ref.watch(sessionProvider);
    final joinedIds = session.joinedCommunityIds;

    final allCommunitiesAsync = ref.watch(
      communitiesProvider(
        CommunityPaginationParams(page: 1, perPage: 100),
      ),
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        title: Text(
          'Search Communities',
          style: AppTypography.headlineLarge(
            isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyMedium(
                isDark ? AppColors.darkText : AppColors.lightText,
              ),
              decoration: InputDecoration(
                hintText: 'Search communities...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                filled: true,
                fillColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: allCommunitiesAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryPurple,
                ),
              ),
              error: (err, st) => Center(
                child: Text(
                  'Error loading communities',
                  style: AppTypography.bodyMedium(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ),
              data: (response) {
                final searchText = _searchController.text.toLowerCase();
                final filtered = response.communities
                    .where((c) =>
                        c.name.toLowerCase().contains(searchText) ||
                        c.description.toLowerCase().contains(searchText))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No communities found',
                      style: AppTypography.bodyMedium(
                        isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final community = filtered[index];
                    final isJoined = joinedIds.contains(community.id);
                    return _SearchCommunityTile(
                      community: community,
                      isDark: isDark,
                      isJoined: isJoined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunityDetailScreen(
                              community: community,
                              isJoined: isJoined,
                            ),
                          ),
                        );
                      },
                      onJoinTap: () {
                        ref
                            .read(sessionProvider.notifier)
                            .joinCommunity(community.id);
                      },
                      onLeaveTap: () {
                        ref
                            .read(sessionProvider.notifier)
                            .leaveCommunity(community.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Community Tile ────────────────────────────────────────────
class _SearchCommunityTile extends StatelessWidget {
  final Community community;
  final bool isDark;
  final bool isJoined;
  final VoidCallback onTap;
  final VoidCallback onJoinTap;
  final VoidCallback onLeaveTap;

  const _SearchCommunityTile({
    required this.community,
    required this.isDark,
    required this.isJoined,
    required this.onTap,
    required this.onJoinTap,
    required this.onLeaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            _CommunityAvatar(community: community, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium(
                      isDark ? AppColors.darkText : AppColors.lightText,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatCount(community.memberCount)} members',
                    style: AppTypography.bodySmall(
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: isJoined ? onLeaveTap : onJoinTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isJoined
                        ? (isDark
                            ? Colors.white.withOpacity(0.15)
                            : Colors.black.withOpacity(0.15))
                        : AppColors.primaryPurple.withOpacity(0.3),
                  ),
                  color: isJoined
                      ? (isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.05))
                      : AppColors.primaryPurple.withOpacity(0.1),
                ),
                child: Text(
                  isJoined ? 'Leave' : 'Join',
                  style: AppTypography.bodySmall(
                    isJoined
                        ? (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)
                        : AppColors.primaryPurple,
                  ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return '$count';
  }
}

// ─── Community Avatar ─────────────────────────────────────────────────
class _CommunityAvatar extends StatelessWidget {
  final Community community;
  final double size;

  const _CommunityAvatar({required this.community, this.size = 42});

  @override
  Widget build(BuildContext context) {
    if (community.coverImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size <= 42 ? 10 : 14),
        child: Image.network(
          community.coverImage!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.12),
          borderRadius: BorderRadius.circular(size <= 42 ? 10 : 14),
        ),
        child: Icon(
          Icons.groups_rounded,
          size: size * 0.52,
          color: AppColors.primaryPurple,
        ),
      );
}

// ─── Community Detail Screen ──────────────────────────────────────────
class CommunityDetailScreen extends ConsumerStatefulWidget {
  final Community community;
  final bool isJoined;

  const CommunityDetailScreen({
    Key? key,
    required this.community,
    required this.isJoined,
  }) : super(key: key);

  @override
  ConsumerState<CommunityDetailScreen> createState() =>
      _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends ConsumerState<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = ref.watch(sessionProvider);
    final currentIsJoined =
        session.joinedCommunityIds.contains(widget.community.id);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      // ── AppBar ──
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // ── Body ──
      body: Column(
        children: [
          // ── Header: avatar + name + members + join button ──
          _CommunityHeader(
            community: widget.community,
            isDark: isDark,
            isJoined: currentIsJoined,
            onJoinTap: () => ref
                .read(sessionProvider.notifier)
                .joinCommunity(widget.community.id),
            onLeaveTap: () => ref
                .read(sessionProvider.notifier)
                .leaveCommunity(widget.community.id),
          ),
          // ── Sticky TabBar ──
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryPurple,
                  unselectedLabelColor: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  indicatorColor: AppColors.primaryPurple,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle:
                      AppTypography.bodyMedium(AppColors.primaryPurple)
                          .copyWith(
                              fontWeight: FontWeight.w600, fontSize: 13),
                  unselectedLabelStyle: AppTypography.bodyMedium(
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ).copyWith(fontSize: 13),
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Feed'),
                  ],
                ),
                Container(
                  height: 0.5,
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.06),
                ),
              ],
            ),
          ),
          // ── Tab Content ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AboutTab(
                  community: widget.community,
                  isDark: isDark,
                ),
                CommunityPostsFeedScreen(
                  communityId: widget.community.id,
                  communityName: widget.community.name,
                  showAppBar: false, 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Community Header ─────────────────────────────────────────────────
class _CommunityHeader extends StatelessWidget {
  final Community community;
  final bool isDark;
  final bool isJoined;
  final VoidCallback onJoinTap;
  final VoidCallback onLeaveTap;

  const _CommunityHeader({
    required this.community,
    required this.isDark,
    required this.isJoined,
    required this.onJoinTap,
    required this.onLeaveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          // ── Name ──
          Text(
            community.name,
            textAlign: TextAlign.center,
            style: AppTypography.headlineLarge(
              isDark ? AppColors.darkText : AppColors.lightText,
            ).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          // ── Member Count ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_rounded,
                size: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${_formatCount(community.memberCount)} members',
                style: AppTypography.bodySmall(
                  isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ).copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── Join / Leave ──
          GestureDetector(
            onTap: isJoined ? onLeaveTap : onJoinTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isJoined
                      ? (isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.15))
                      : AppColors.primaryPurple.withOpacity(0.3),
                ),
                color: isJoined
                    ? (isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.05))
                    : AppColors.primaryPurple.withOpacity(0.1),
              ),
              child: Text(
                isJoined ? 'Leave' : 'Join',
                style: AppTypography.bodySmall(
                  isJoined
                      ? (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)
                      : AppColors.primaryPurple,
                ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return '$count';
  }
}

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return '$count';
  }


// ─── About Tab ────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final Community community;
  final bool isDark;

  const _AboutTab({required this.community, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: AppTypography.bodyMedium(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  community.name,
                  style: AppTypography.bodySmall(
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  community.description,
                  style: AppTypography.bodySmall(
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ).copyWith(height: 1.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${community.memberCount} members',
                      style: AppTypography.bodySmall(
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}