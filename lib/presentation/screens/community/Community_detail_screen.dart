import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_model.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/community_provider.dart';
import 'community_posts_feed_screen.dart';
import 'community_screen.dart' show communityColor, communityEmoji;

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
              style: AppTypography.bodySmall(Colors.white.withOpacity(0.75))
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
                        return AppColors.primaryPurple.withOpacity(0.08);
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
                    color: color,
                    onJoin: () => ref
                        .read(sessionProvider.notifier)
                        .joinCommunity(widget.community.id),
                    onLeave: () => ref
                        .read(sessionProvider.notifier)
                        .leaveCommunity(widget.community.id),
                  ),
                  CommunityPostsFeedScreen(
                    communityId: widget.community.id,
                    communityName: widget.community.name,
                    showAppBar: false,
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
  final Color color;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _AboutTab({
    required this.community,
    required this.isDark,
    required this.isJoined,
    required this.color,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final detailActionColor =
        isJoined ? const Color(0xFFD32F2F) : AppColors.primaryPurple;

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
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04)),
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
            onTap: () => _showCreatorProfile(context, community.createdBy, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: creatorAsync.when(
                data: (response) => Text(
                  response.data?.username ?? 'Unknown',
                  style: TextStyle(
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
                  community.createdBy.length > 20
                      ? '${community.createdBy.substring(0, 20)}...'
                      : community.createdBy,
                  style: TextStyle(
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
          InkWell(
            onTap: isJoined ? onLeave : onJoin,
            borderRadius: BorderRadius.circular(10),
            splashColor: detailActionColor.withOpacity(0.08),
            highlightColor: detailActionColor.withOpacity(0.04),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: detailActionColor.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Text(
                isJoined ? 'Leave community' : 'Join community',
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
      BuildContext context, String creatorId, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, refInModal, child) {
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
                  data: (response) => Column(
                    children: [
                      if (response.data?.username != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Username',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '@${response.data!.username}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User ID',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              creatorId,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User ID',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          creatorId,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
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
