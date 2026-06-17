import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/community_post_model.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/profile_provider.dart';
import 'community_post_card.dart';
import '../../widgets/image_viewer_dialog.dart';

class CommunityPostDetailScreen extends ConsumerStatefulWidget {
  final CommunityPost post;
  final String communityId;

  const CommunityPostDetailScreen({
    super.key,
    required this.post,
    required this.communityId,
  });

  @override
  ConsumerState<CommunityPostDetailScreen> createState() =>
      _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState
    extends ConsumerState<CommunityPostDetailScreen> {
  late final TextEditingController _commentController;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(postOperationsProvider.notifier).addComment(
            postId: widget.post.id,
            body: text,
          );

      // Force refresh comments on pagination provider
      ref.invalidate(postCommentsProvider(
        CommentPaginationParams(postId: widget.post.id, page: 1, perPage: 100),
      ));

      _commentController.clear();
      _focusNode.unfocus();

      // Scroll to bottom
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(postOperationsProvider.notifier).deleteComment(
            postId: widget.post.id,
            commentId: commentId,
          );

      ref.invalidate(postCommentsProvider(
        CommentPaginationParams(postId: widget.post.id, page: 1, perPage: 100),
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comment: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : Colors.white;

    final myProfile = ref.watch(profileProvider).profile;
    final myAvatarUrl = myProfile?.avatarUrl;
    final myUsername = myProfile?.username ?? 'Me';

    final currentUserId = ref.watch(authProvider).user?.id ?? '';

    final commentsAsync = ref.watch(
      postCommentsProvider(
        CommentPaginationParams(postId: widget.post.id, page: 1, perPage: 100),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Post Details',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: text,
          ),
        ),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              data: (response) {
                final comments = response.data;
                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    CommunityPostCard(
                      post: widget.post,
                      communityId: widget.communityId,
                      onCommentsTap: () => _focusNode.requestFocus(),
                      onEditTap: null,
                      onDeleteTap: null,
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Comments (${comments.length})',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: text,
                        ),
                      ),
                    ),
                    if (comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 44,
                                color: sub.withValues(alpha: 0.35),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No comments yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: sub,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Be the first to share your thoughts!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: sub.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...comments.map(
                        (comment) => _CommentTile(
                          comment: comment,
                          currentUserId: currentUserId,
                          communityId: widget.communityId,
                          onDelete: () => _deleteComment(comment.id),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Failed to load comments: $err',
                    style: TextStyle(color: sub),
                  ),
                ),
              ),
            ),
          ),
          _buildInputBar(context, myAvatarUrl, myUsername),
        ],
      ),
    );
  }

Widget _buildInputBar(BuildContext context, String? avatarUrl, String username) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final text = isDark ? AppColors.darkText : AppColors.lightText;
  final hint = isDark ? Colors.white30 : Colors.grey[400]!;
  final divider = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05);
  
  final bottomPadding = MediaQuery.of(context).padding.bottom;
  final isTextEmpty = _commentController.text.trim().isEmpty;

  return Container(
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkBackground : Colors.white,
      border: Border(top: BorderSide(color: divider, width: 1)),
    ),
    // Compact overall bar padding
    padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding > 0 ? bottomPadding + 6 : 8),
    child: Row(
      // CHANGED: Back to center alignment since the form is now shorter and sleeker
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        // Avatar
        ClipOval(
          child: SizedBox(
            width: 34, // Slightly scaled down to match the shorter bar
            height: 34,
            child: avatarUrl == null || avatarUrl.trim().isEmpty
                ? Container(
                    color: AppColors.primaryPurple.withValues(alpha: 0.10),
                    alignment: Alignment.center,
                    child: Text(
                      username.isEmpty ? '?' : username[0].toUpperCase(),
                      textScaler: TextScaler.noScaling, 
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Image.network(avatarUrl, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),

        // Input field
        Expanded(
          child: TextField(
            controller: _commentController,
            focusNode: _focusNode,
            style: TextStyle(fontSize: 15, color: text, height: 1.3),
            maxLines: 4,
            minLines: 1,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Add a comment…',
              hintStyle: TextStyle(fontSize: 15, color: hint),
              border: InputBorder.none,
              isDense: true,
              // 🔥 CHANGED: Shorter height (vertical: 8) but spacious wide sides (horizontal: 14)
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 10),

        // Send button
        IgnorePointer(
          ignoring: isTextEmpty, 
          child: AnimatedOpacity(
            opacity: isTextEmpty ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: _isSubmitting
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded),
                    color: AppColors.primaryPurple,
                    iconSize: 24, 
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: isTextEmpty ? null : _submitComment,
                  ),
          ),
        ),
      ],
    ),
  );

}


}

class _CommentTile extends ConsumerWidget {
  final CommunityPostComment comment;
  final String currentUserId;
  final String communityId;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.communityId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Resolve community admin status
    final communityAsync = ref.watch(communityDetailProvider(communityId));
    final isCommunityAdmin = communityAsync.value?.createdBy == comment.authorId;

    // Resolve name and avatar (using fast cache if available, falling back to profile load)
    String displayName = comment.authorUsername ?? '';
    String? avatarUrl = comment.authorAvatarUrl;

    if (displayName.trim().isEmpty) {
      final userAsync = ref.watch(userProfileByIdProvider(comment.authorId));
      if (userAsync.value?.data != null) {
        displayName = userAsync.value!.data!.username;
        avatarUrl = userAsync.value!.data!.avatarUrl;
      }
    }

    if (displayName.trim().isEmpty) {
      displayName = comment.authorId.length > 8
          ? comment.authorId.substring(0, 8)
          : comment.authorId;
    }

    final bubbleBg = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.8)
        : Colors.grey[100];
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
                showImageViewer(context, avatarUrl, "$displayName's Avatar");
              }
            },
            child: ClipOval(
              child: SizedBox(
                width: 36,
                height: 36,
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
                    : Image.network(avatarUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bubbleBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: text,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCommunityAdmin) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPurple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Admin',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryPurple,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        comment.body,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: text.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Row(
                    children: [
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(fontSize: 11, color: sub),
                      ),
                      if (comment.authorId == currentUserId) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onDelete,
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.month}/${date.day}/${date.year}';
  }
}
