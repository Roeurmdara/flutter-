import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_post_model.dart';
import '../../../data/providers/community_provider.dart';

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
    extends ConsumerState<CommunityPostsFeedScreen> {
  int _currentPage = 1;
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    final postsAsyncValue = ref.watch(
      communityPostsProvider(
        PostPaginationParams(
          communityId: widget.communityId,
          page: _currentPage,
          perPage: 10,
        ),
      ),
    );

    return Scaffold(
    appBar: widget.showAppBar
      ? AppBar(
          title: Text('${widget.communityName} - Posts'),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showCreatePostDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Post'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                  ),
                ),
              ),
            ),
          ],
        )
      : null,
      body: postsAsyncValue.when(
        data: (response) {
          final posts = response.data;

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    style: AppTypography.headlineSmall(Colors.grey[600]!),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to create a post!',
                    style: AppTypography.bodyMedium(Colors.grey[500]!),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length +
                (response.meta.hasNext
                    ? 1
                    : 0), // Add one more item for load more button
            itemBuilder: (context, index) {
              if (index == posts.length) {
                // Load more button
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _isLoadingMore
                        ? null
                        : () async {
                            setState(() {
                              _isLoadingMore = true;
                              _currentPage++;
                            });
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            setState(() {
                              _isLoadingMore = false;
                            });
                          },
                    child: _isLoadingMore
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Load More'),
                  ),
                );
              }

              final post = posts[index];
              return _buildPostCard(context, post);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading posts',
                style: AppTypography.headlineSmall(Colors.red[600]!),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(Colors.grey[500]!),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(communityPostsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, CommunityPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: AppTypography.headlineSmall(Colors.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        post.createdAt.toString().split('.')[0],
                        style: AppTypography.bodySmall(Colors.grey[500]!),
                      ),
                    ],
                  ),
                ),
                if (post.isPinned)
                  Tooltip(
                    message: 'Pinned',
                    child: Icon(
                      Icons.push_pin,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Post body
            Text(
              post.body,
              style: AppTypography.bodyMedium(Colors.black),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Post stats
            Row(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.likeCount.toString(),
                      style: AppTypography.bodySmall(Colors.grey[600]!),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.commentCount.toString(),
                      style: AppTypography.bodySmall(Colors.grey[600]!),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _likePost(post.id),
                    icon: const Icon(Icons.thumb_up_outlined, size: 18),
                    label: const Text('Like'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCommentsDialog(context, post),
                    icon: const Icon(Icons.comment_outlined, size: 18),
                    label: const Text('Comments'),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditPostDialog(context, post);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, post);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _likePost(String postId) {
    ref.read(postOperationsProvider.notifier).reactToPost(
          postId: postId,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post liked!')),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreatePostDialog(
        communityId: widget.communityId,
      ),
    );
  }

  void _showEditPostDialog(BuildContext context, CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => _EditPostDialog(
        communityId: widget.communityId,
        post: post,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(postOperationsProvider.notifier).deletePost(
                    communityId: widget.communityId,
                    postId: post.id,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => _CommentsDialog(
        postId: post.id,
        postTitle: post.title,
      ),
    );
  }
}

class _CreatePostDialog extends ConsumerStatefulWidget {
  final String communityId;

  const _CreatePostDialog({
    required this.communityId,
  });

  @override
  ConsumerState<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends ConsumerState<_CreatePostDialog> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  bool _isLoading = false;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _createPost() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(postOperationsProvider.notifier).createPost(
          communityId: widget.communityId,
          title: _titleController.text,
          body: _bodyController.text,
          isPinned: _isPinned,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter post title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              enabled: !_isLoading,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Content *',
                hintText: 'Enter post content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _isPinned,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() => _isPinned = value ?? false);
                    },
              title: const Text('Pin this post'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}

class _EditPostDialog extends ConsumerStatefulWidget {
  final String communityId;
  final CommunityPost post;

  const _EditPostDialog({
    required this.communityId,
    required this.post,
  });

  @override
  ConsumerState<_EditPostDialog> createState() => _EditPostDialogState();
}

class _EditPostDialogState extends ConsumerState<_EditPostDialog> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  bool _isLoading = false;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _bodyController = TextEditingController(text: widget.post.body);
    _isPinned = widget.post.isPinned;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _updatePost() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(postOperationsProvider.notifier).updatePost(
          communityId: widget.communityId,
          postId: widget.post.id,
          title: _titleController.text,
          body: _bodyController.text,
          isPinned: _isPinned,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter post title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              enabled: !_isLoading,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Content *',
                hintText: 'Enter post content',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _isPinned,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() => _isPinned = value ?? false);
                    },
              title: const Text('Pin this post'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updatePost,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
}

class _CommentsDialog extends ConsumerStatefulWidget {
  final String postId;
  final String postTitle;

  const _CommentsDialog({
    required this.postId,
    required this.postTitle,
  });

  @override
  ConsumerState<_CommentsDialog> createState() => _CommentsDialogState();
}

class _CommentsDialogState extends ConsumerState<_CommentsDialog> {
  late TextEditingController _commentController;
  int _currentPage = 1;

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

  void _addComment() async {
    if (_commentController.text.isEmpty) {
      return;
    }

    await ref.read(postOperationsProvider.notifier).addComment(
          postId: widget.postId,
          body: _commentController.text,
        );

    _commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment added!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsyncValue = ref.watch(
      postCommentsProvider(
        CommentPaginationParams(
          postId: widget.postId,
          page: _currentPage,
          perPage: 10,
        ),
      ),
    );

    return AlertDialog(
      title: Text('Comments - ${widget.postTitle}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: commentsAsyncValue.when(
                data: (response) {
                  final comments = response.data;

                  if (comments.isEmpty) {
                    return Center(
                      child: Text(
                        'No comments yet',
                        style:
                            AppTypography.bodySmall(Colors.grey[500]!).copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comment.authorId.substring(0, 8),
                                    style: AppTypography.bodySmall(
                                            Colors.grey[600]!)
                                        .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        ref
                                            .read(
                                                postOperationsProvider.notifier)
                                            .deleteComment(
                                              postId: widget.postId,
                                              commentId: comment.id,
                                            );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment.body,
                                style: AppTypography.bodyMedium(Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                comment.createdAt.toString().split('.')[0],
                                style:
                                    AppTypography.bodySmall(Colors.grey[500]!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    'Error loading comments',
                    style: AppTypography.bodySmall(Colors.red[600]!).copyWith(
                      color: Colors.red[600],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}