import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_post_model.dart';
import '../../../data/providers/community_provider.dart';
import 'community_post_card.dart';
import 'package:image_picker/image_picker.dart';

class CommunityPostsFeedScreen extends ConsumerStatefulWidget {
  final String communityId;
  final String communityName;
  final bool showAppBar;

  const CommunityPostsFeedScreen({
    Key? key,
    required this.communityId,
    required this.communityName,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  ConsumerState<CommunityPostsFeedScreen> createState() =>
      _CommunityPostsFeedScreenState();
}

class _CommunityPostsFeedScreenState
    extends ConsumerState<CommunityPostsFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    if (widget.showAppBar) {
      _tab = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    if (widget.showAppBar) {
      _tab.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Fetch posts
    final postsAsync = ref.watch(
      communityPostsProvider(
        PostPaginationParams(
          communityId: widget.communityId,
          page: _currentPage,
          perPage: 10,
        ),
      ),
    );

    // When used as nested component (showAppBar: false), ONLY show feed list
    if (!widget.showAppBar) {
      return postsAsync.when(
        data: (response) => Stack(
          children: [
            _buildFeed(context, response),
            // Small floating button for embedded feed
            Positioned(
              right: 16,
              bottom: 12,
              child: GestureDetector(
                onTap: () => _showCreatePostDialog(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12), blurRadius: 6),
                    ],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildError(context, error),
      );
    }

    // When used standalone, show full screen with tabs
    final communityAsync =
        ref.watch(communityDetailProvider(widget.communityId));

    return communityAsync.when(
      loading: () => Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Center(child: Text('Error: $error')),
      ),
      data: (community) => Scaffold(
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
        body: Column(
          children: [
            // ── Purple header with community info ──
            Container(
              width: double.infinity,
              color: AppColors.primaryPurple,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  Text(
                    community.name,
                    style: AppTypography.headlineLarge(Colors.white).copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_fmtCount(community.memberCount)} members',
                    style:
                        AppTypography.bodySmall(Colors.white.withOpacity(0.75))
                            .copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),

            // ── Tabs (rounded top corners overlapping purple header) ──
            Transform.translate(
              offset: const Offset(0, -16),
              child: Container(
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
            ),

            // ── Tab content ──
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: TabBarView(
                  controller: _tab,
                  children: [
                    // About Tab
                    _AboutTab(
                      community: community,
                      isDark: isDark,
                    ),
                    // Feed Tab
                    postsAsync.when(
                      data: (response) => _buildFeed(context, response),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => _buildError(context, error),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreatePostDialog(context),
          backgroundColor: AppColors.primaryPurple,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          mini: true,
          child: const Icon(Icons.edit, size: 20, color: Colors.white),
        ),
      ),
    );
  }

  String _fmtCount(int n) => n >= 1000
      ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k'
      : '$n';

  Widget _buildFeed(BuildContext context, dynamic response) {
    final posts = response.data as List<CommunityPost>;

    if (posts.isEmpty) return _buildEmpty(context);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: posts.length + (response.meta.hasNext ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == posts.length) return _buildLoadMore(context);
        return CommunityPostCard(
          post: posts[index],
          communityId: widget.communityId,
          onCommentsTap: () => _showCommentsDialog(context, posts[index]),
          onEditTap: () => _showEditPostDialog(context, posts[index]),
          onDeleteTap: () => _showDeleteConfirmation(context, posts[index]),
          onAuthorTap: (authorId) => _showAuthorProfile(context, authorId),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 40, color: muted.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            'No posts yet',
            style: AppTypography.headlineSmall(muted).copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to post.',
            style: AppTypography.bodySmall(muted).copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 36, color: Colors.red[300]),
            const SizedBox(height: 12),
            Text(
              'Failed to load posts',
              style: AppTypography.headlineSmall(
                isDark ? AppColors.darkText : AppColors.lightText,
              ).copyWith(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(muted).copyWith(fontSize: 12),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(communityPostsProvider),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry', style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                side: BorderSide(color: muted.withOpacity(0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMore(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: OutlinedButton(
        onPressed: _isLoadingMore
            ? null
            : () async {
                setState(() {
                  _isLoadingMore = true;
                  _currentPage++;
                });
                await Future.delayed(const Duration(milliseconds: 500));
                setState(() => _isLoadingMore = false);
              },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: muted.withOpacity(0.3)),
        ),
        child: _isLoadingMore
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.grey[400],
                ),
              )
            : Text(
                'Load more',
                style: TextStyle(
                  fontSize: 13,
                  color: muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _PostDialog(communityId: widget.communityId),
    );
  }

  void _showEditPostDialog(BuildContext context, CommunityPost post) {
    showDialog(
      context: context,
      builder: (_) => _PostDialog(communityId: widget.communityId, post: post),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CommunityPost post) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('Delete post?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(postOperationsProvider.notifier).deletePost(
                    communityId: widget.communityId,
                    postId: post.id,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Post deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Delete',
                style: TextStyle(fontSize: 13, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, CommunityPost post) {
    showDialog(
      context: context,
      builder: (_) => _CommentsDialog(postId: post.id, postTitle: post.title),
    );
  }

  void _showAuthorProfile(BuildContext context, String authorId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final userAsync = ref.watch(userProfileByIdProvider(authorId));

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post Author',
                  style: AppTypography.headlineSmall(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ).copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                userAsync.when(
                  data: (profileResponse) {
                    final profile = profileResponse.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display name
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
                                'Name',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                profile?.username ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Username
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
                                '@${profile?.username ?? 'unknown'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // User ID
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
                                authorId,
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
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Container(
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
                          authorId,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

// ── _AboutTab ─────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final dynamic community;
  final bool isDark;

  const _AboutTab({
    required this.community,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

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
                : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: AppTypography.bodyMedium(text)
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Text(
              community.description,
              style: AppTypography.bodySmall(sub)
                  .copyWith(height: 1.6, fontSize: 13.5),
            ),
            const SizedBox(height: 14),
            Text(
              '${community.memberCount} members',
              style: AppTypography.bodySmall(sub).copyWith(fontSize: 12),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 20),
            Text(
              'Created by',
              style: AppTypography.bodySmall(sub).copyWith(fontSize: 11),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: SelectableText(
                community.createdBy.length > 30
                    ? '${community.createdBy.substring(0, 30)}...'
                    : community.createdBy,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryPurple,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _PostDialog ────────────────────────────────────────────────────────────

class _PostDialog extends ConsumerStatefulWidget {
  final String communityId;
  final CommunityPost? post; // null = create mode

  const _PostDialog({required this.communityId, this.post});

  @override
  ConsumerState<_PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends ConsumerState<_PostDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isLoading = false;
  late bool _isPinned;
  File? _selectedImage;

  bool get _isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _bodyController = TextEditingController(text: widget.post?.body ?? '');
    _isPinned = widget.post?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (_isEditing) {
      await ref.read(postOperationsProvider.notifier).updatePost(
            communityId: widget.communityId,
            postId: widget.post!.id,
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            isPinned: _isPinned,
            imageFile: _selectedImage,
          );
    } else {
      await ref.read(postOperationsProvider.notifier).createPost(
            communityId: widget.communityId,
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            isPinned: _isPinned,
            imageFile: _selectedImage,
          );
    }

    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Post updated successfully'
              : 'Post created successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Section (Now at the Top) ──
            if (_selectedImage != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (!_isLoading)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedImage = null),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ] else ...[
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () async {
                        final picker = ImagePicker();
                        final XFile? picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (picked != null) {
                          setState(() => _selectedImage = File(picked.path));
                        }
                      },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 20, color: sub),
                      const SizedBox(width: 8),
                      Text(
                        'Add cover image',
                        style: TextStyle(
                            color: sub,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Title ──
            Text(
              _isEditing ? 'Edit Post' : 'New Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: text,
              ),
            ),
            const SizedBox(height: 20),

            // ── Input Fields ──
            _Field(
              controller: _titleController,
              hint: 'Post title',
              isDark: isDark,
              enabled: !_isLoading,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _bodyController,
              hint: 'What\'s on your mind?',
              isDark: isDark,
              maxLines: 4,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 20),

            // ── Viral / Pin Toggle ──
            GestureDetector(
              onTap: _isLoading
                  ? null
                  : () => setState(() => _isPinned = !_isPinned),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      'Make this post viral',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _isPinned ? AppColors.primaryPurple : sub,
                      ),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: _isPinned,
                        onChanged: _isLoading
                            ? null
                            : (v) => setState(() => _isPinned = v),
                        activeColor: AppColors.primaryPurple,
                        activeTrackColor:
                            AppColors.primaryPurple.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Action Buttons ──
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: sub,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Update' : 'Create',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── _CommentsDialog ───────────────────────────────────────────────────────────

class _CommentsDialog extends ConsumerStatefulWidget {
  final String postId;
  final String postTitle;

  const _CommentsDialog({required this.postId, required this.postTitle});

  @override
  ConsumerState<_CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends ConsumerState<_CommentsDialog> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    try {
      await ref.read(postOperationsProvider.notifier).addComment(
            postId: widget.postId,
            body: _commentController.text.trim(),
          );
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add comment: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(
      postCommentsProvider(
        CommentPaginationParams(postId: widget.postId, page: 1, perPage: 10),
      ),
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Comments',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            widget.postTitle,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: commentsAsync.when(
                data: (response) {
                  final comments = response.data;
                  if (comments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No comments yet.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.authorId.substring(0, 8),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDate(comment.createdAt),
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[400]),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.body,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => ref
                                  .read(postOperationsProvider.notifier)
                                  .deleteComment(
                                    postId: widget.postId,
                                    commentId: comment.id,
                                  ),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(Icons.close,
                                    size: 14, color: Colors.grey[300]),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const Center(
                  child: Text('Failed to load comments',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Write a comment…',
                      hintStyle:
                          TextStyle(fontSize: 13, color: Colors.grey[400]),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    onSubmitted: (_) => _addComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addComment,
                  icon: Icon(Icons.arrow_upward,
                      size: 18, color: AppColors.primaryPurple),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple.withOpacity(0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ── Shared minimal text field ──────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: sub),
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
