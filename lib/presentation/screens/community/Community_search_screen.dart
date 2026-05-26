import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_model.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/session_provider.dart';
import 'community_posts_feed_screen.dart';
import 'community_screen.dart'
    show communityColor, communityEmoji; // reuse helpers

// ─── Community Search Screen ──────────────────────────────────────────────────

class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CommunitySearchScreen> createState() =>
      _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends ConsumerState<CommunitySearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final joinedIds = ref.watch(sessionProvider).joinedCommunityIds;

    final allAsync = ref.watch(
      communitiesProvider(CommunityPaginationParams(page: 1, perPage: 100)),
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
      ),
      body: Column(children: [
        // ── Search bar ──
        Container(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
                  size: 20),
              filled: true,
              fillColor:
                  isDark ? AppColors.darkBackground : AppColors.lightBackground,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ),

        // ── Results ──
        Expanded(
          child: allAsync.when(
            loading: () => Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryPurple, strokeWidth: 2)),
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  final isJoined = joinedIds.contains(c.id);
                  return _SearchTile(
                    community: c,
                    isDark: isDark,
                    isJoined: isJoined,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommunityDetailScreen(
                              community: c, isJoined: isJoined),
                        )),
                    onJoin: () =>
                        ref.read(sessionProvider.notifier).joinCommunity(c.id),
                    onLeave: () =>
                        ref.read(sessionProvider.notifier).leaveCommunity(c.id),
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
  final bool isDark, isJoined;
  final VoidCallback onTap, onJoin, onLeave;

  const _SearchTile({
    required this.community,
    required this.isDark,
    required this.isJoined,
    required this.onTap,
    required this.onJoin,
    required this.onLeave,
  });

  String _fmt(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k'
      : '$n';

  @override
  Widget build(BuildContext context) {
    final color = communityColor(community); // ← uses custom color if set
    final emoji = communityEmoji(community); // ← uses custom emoji if set

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isJoined ? color.withOpacity(0.3) : color.withOpacity(0.15),
            width: isJoined ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          // Emoji badge
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color.withOpacity(0.12)),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),

          // Name + description
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(community.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium(
                              isDark ? AppColors.darkText : AppColors.lightText)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                Text('👥 ${_fmt(community.memberCount)}',
                    style:
                        TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
              ]),
              const SizedBox(height: 3),
              Text(community.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
            ]),
          ),
          const SizedBox(width: 10),

          // Join / Leave button
          GestureDetector(
            onTap: isJoined ? onLeave : onJoin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isJoined
                    ? color.withOpacity(0.08)
                    : color.withOpacity(0.12),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Text(
                isJoined ? '✓ Joined' : '+ Join',
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Community Detail Screen ──────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isJoined = ref
        .watch(sessionProvider)
        .joinedCommunityIds
        .contains(widget.community.id);
    final color = communityColor(widget.community);
    final emoji = communityEmoji(widget.community);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? AppColors.darkText : AppColors.lightText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(children: [
        // ── Header ──
        Container(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.13),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(height: 10),
            Text(widget.community.name,
                style: AppTypography.headlineLarge(
                        isDark ? AppColors.darkText : AppColors.lightText)
                    .copyWith(fontSize: 17)),
            const SizedBox(height: 4),
            Text('${_fmtCount(widget.community.memberCount)} members',
                style: AppTypography.bodySmall(isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)
                    .copyWith(fontSize: 12)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: isJoined
                  ? () => ref
                      .read(sessionProvider.notifier)
                      .leaveCommunity(widget.community.id)
                  : () => ref
                      .read(sessionProvider.notifier)
                      .joinCommunity(widget.community.id),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:
                      isJoined ? Colors.transparent : color.withOpacity(0.12),
                  border: Border.all(
                    color: isJoined
                        ? (isDark ? Colors.white12 : Colors.black12)
                        : color.withOpacity(0.35),
                  ),
                ),
                child: Text(
                  isJoined ? 'Leave' : 'Join',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isJoined
                        ? (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)
                        : color,
                  ),
                ),
              ),
            ),
          ]),
        ),

        // ── Tabs ──
        Container(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: TabBar(
            controller: _tab,
            labelColor: AppColors.primaryPurple,
            unselectedLabelColor: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            indicatorColor: AppColors.primaryPurple,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTypography.bodyMedium(AppColors.primaryPurple)
                .copyWith(fontSize: 13),
            tabs: const [Tab(text: 'About'), Tab(text: 'Feed')],
          ),
        ),

        // ── Tab content ──
        Expanded(
          child: TabBarView(controller: _tab, children: [
            _AboutTab(community: widget.community, isDark: isDark),
            CommunityPostsFeedScreen(
              communityId: widget.community.id,
              communityName: widget.community.name,
              showAppBar: false,
            ),
          ]),
        ),
      ]),
    );
  }

  String _fmtCount(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k'
      : '$n';
}

// ─── About Tab ────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final Community community;
  final bool isDark;
  const _AboutTab({required this.community, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('About',
              style: AppTypography.bodyMedium(text)
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(community.description,
              style: AppTypography.bodySmall(sub).copyWith(height: 1.6)),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.people_rounded, size: 14, color: sub),
            const SizedBox(width: 6),
            Text('${community.memberCount} members',
                style: AppTypography.bodySmall(sub).copyWith(fontSize: 12)),
          ]),
        ]),
      ),
    );
  }
}
