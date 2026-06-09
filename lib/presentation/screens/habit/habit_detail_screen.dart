import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/providers/activity_provider.dart';
import '../../../data/providers/community_provider.dart';
import '../../widgets/create_habit_modal.dart';
import '../../../data/providers/habit_provider.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final Habit habit;
  final DateTime selectedDate;

  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.selectedDate,
  });

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  late TextEditingController _activityTypeController;
  late TextEditingController _valueController;
  late TextEditingController _unitController;
  late TextEditingController _noteController;
  // Post operations controllers (debug / helper UI)
  late TextEditingController _communityIdController;
  late TextEditingController _postIdController;
  late TextEditingController _postTitleController;
  late TextEditingController _postBodyController;
  bool _postIsPinned = false;

  late TextEditingController _commentBodyController;
  late TextEditingController _commentIdController;
  bool _showAddActivityForm = false;

  // Community posts UI state
  late TextEditingController _quickCommentController;

  @override
  void initState() {
    super.initState();
    _activityTypeController = TextEditingController();
    _valueController = TextEditingController();
    _unitController = TextEditingController();
    _noteController = TextEditingController();
    _communityIdController = TextEditingController();
    _postIdController = TextEditingController();
    _postTitleController = TextEditingController();
    _postBodyController = TextEditingController();
    _commentBodyController = TextEditingController();
    _commentIdController = TextEditingController();
    _quickCommentController = TextEditingController();

    // Load activities for this habit
    Future.microtask(() {
      ref.read(activitiesNotifierProvider.notifier).loadActivities(
            widget.habit.id,
            widget.selectedDate,
          );
    });
  }

  @override
  void dispose() {
    _activityTypeController.dispose();
    _valueController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    _communityIdController.dispose();
    _postIdController.dispose();
    _postTitleController.dispose();
    _postBodyController.dispose();
    _commentBodyController.dispose();
    _commentIdController.dispose();
    _quickCommentController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _activityTypeController.clear();
    _valueController.clear();
    _unitController.clear();
    _noteController.clear();
  }

  void _showCommentDialog(String postId, String postTitle) {
    _quickCommentController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Comment to "$postTitle"'),
        content: TextField(
          controller: _quickCommentController,
          decoration: const InputDecoration(
            hintText: 'Enter your comment...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final body = _quickCommentController.text.trim();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              if (body.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Comment cannot be empty')),
                );
                return;
              }
              try {
                await ref.read(postOperationsProvider.notifier).addComment(
                      postId: postId,
                      body: body,
                    );
                if (mounted) {
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Comment added!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Post Comment'),
          ),
        ],
      ),
    );
  }

  Future<void> _createActivity() async {
    if (_activityTypeController.text.isEmpty || _valueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in activity type and value'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref.read(activitiesNotifierProvider.notifier).createActivity(
            habitId: widget.habit.id,
            activityType: _activityTypeController.text,
            value: _valueController.text,
            unit: _unitController.text,
            settlementPeriodDate: widget.selectedDate,
            note: _noteController.text.isEmpty ? null : _noteController.text,
          );

      _clearForm();
      setState(() => _showAddActivityForm = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activity created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activityState = ref.watch(activitiesNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF6F5F3),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Details',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.08,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              widget.habit.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
        toolbarHeight: 64,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      // Render the create/edit habit form inline so user can update and add activities
      body: CreateHabitModal(
        editingHabit: widget.habit,
        onSubmit: (data) async {
          try {
            await ref.read(habitsProvider.notifier).updateHabit(
                  widget.habit.id,
                  title: data['title'] as String?,
                  description: data['description'] as String?,
                  frequencyType: data['frequencyType'] as String?,
                  frequencyConfig: (data['frequencyConfig'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList(),
                  categoryId: data['categoryId'] as String?,
                  startDate: data['startDate'] as DateTime?,
                  endDate: data['endDate'] as DateTime?,
                  emoji: data['emoji'] as String?,
                  colorHex: data['color'] as String?,
                );
          } catch (e) {
            // ignore - CreateHabitModal shows feedback
          }
        },
        onDelete: () async {
          try {
            await ref
                .read(habitsProvider.notifier)
                .deleteHabit(widget.habit.id);
            if (mounted) Navigator.pop(context);
          } catch (_) {}
        },
      ),
    );
  }

  Widget _buildHabitInfoSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _parseColor(widget.habit.categoryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.habit.categoryIcon ?? '📋',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.habit.description,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Frequency',
                  widget.habit.frequency,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Current Streak',
                  '${widget.habit.currentStreak}',
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'Best Streak',
                  '${widget.habit.bestStreak}',
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Post operations helper (for testing update/delete/comments)
          _buildPostOperationsSection(isDark),
        ],
      ),
    );
  }

  Widget _buildPostOperationsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post Operations',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _communityIdController,
            label: 'Community ID',
            hint: 'community id',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _postIdController,
            label: 'Post ID',
            hint: 'post id',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _postTitleController,
            label: 'Post Title',
            hint: 'title',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _postBodyController,
            label: 'Post Body',
            hint: 'body',
            isDark: isDark,
          ),
          Row(
            children: [
              Checkbox(
                value: _postIsPinned,
                onChanged: (v) => setState(() => _postIsPinned = v ?? false),
              ),
              const SizedBox(width: 4),
              const Text('Pinned'),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final cid = _communityIdController.text.trim();
                    final pid = _postIdController.text.trim();
                    final title = _postTitleController.text.trim();
                    final body = _postBodyController.text.trim();
                    final messenger = ScaffoldMessenger.of(context);
                    if (cid.isEmpty || pid.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Community and Post IDs required')),
                      );
                      return;
                    }
                    try {
                      await ref
                          .read(postOperationsProvider.notifier)
                          .updatePost(
                            communityId: cid,
                            postId: pid,
                            title: title.isEmpty ? 'Updated' : title,
                            body: body.isEmpty ? 'Updated body' : body,
                            isPinned: _postIsPinned,
                          );
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Post updated'),
                            backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                            content: Text('Update failed: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Update Post'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final cid = _communityIdController.text.trim();
                    final pid = _postIdController.text.trim();
                    final messenger = ScaffoldMessenger.of(context);
                    if (cid.isEmpty || pid.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Community and Post IDs required')),
                      );
                      return;
                    }
                    try {
                      await ref
                          .read(postOperationsProvider.notifier)
                          .deletePost(
                            communityId: cid,
                            postId: pid,
                          );
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Post deleted'),
                            backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                            content: Text('Delete failed: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Delete Post'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _commentBodyController,
            label: 'Comment Body',
            hint: 'comment text',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _commentIdController,
            label: 'Comment ID (for delete)',
            hint: 'comment id',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final pid = _postIdController.text.trim();
                    final body = _commentBodyController.text.trim();
                    final messenger = ScaffoldMessenger.of(context);
                    if (pid.isEmpty || body.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Post ID and comment body required')),
                      );
                      return;
                    }
                    try {
                      await ref
                          .read(postOperationsProvider.notifier)
                          .addComment(
                            postId: pid,
                            body: body,
                          );
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Comment added'),
                            backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                            content: Text('Add comment failed: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Add Comment'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final pid = _postIdController.text.trim();
                    final cid = _commentIdController.text.trim();
                    final messenger = ScaffoldMessenger.of(context);
                    if (pid.isEmpty || cid.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Post ID and Comment ID required')),
                      );
                      return;
                    }
                    try {
                      await ref
                          .read(postOperationsProvider.notifier)
                          .deleteComment(
                            postId: pid,
                            commentId: cid,
                          );
                      messenger.showSnackBar(
                        const SnackBar(
                            content: Text('Comment deleted'),
                            backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(
                            content: Text('Delete comment failed: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Delete Comment'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildAddActivityForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Activity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _activityTypeController,
            label: 'Activity Type',
            hint: 'e.g., Running, Push-ups',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildTextField(
                  controller: _valueController,
                  label: 'Value',
                  hint: 'e.g., 10',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _unitController,
                  label: 'Unit',
                  hint: 'e.g., km, reps',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _noteController,
            label: 'Note (Optional)',
            hint: 'Add a note...',
            isDark: isDark,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create Activity',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesList(ActivityState activityState, bool isDark) {
    return Column(
      children: activityState.activities.map((activity) {
        return _buildActivityCard(activity, isDark);
      }).toList(),
    );
  }

  Widget _buildCommunityPostsSection(bool isDark, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _communityIdController,
          label: 'Community ID',
          hint: 'Enter community ID to view posts',
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        if (_communityIdController.text.isNotEmpty)
          _buildPostsList(_communityIdController.text, isDark, ref)
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Text(
              'Enter a Community ID above to view posts',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostsList(String communityId, bool isDark, WidgetRef ref) {
    return ref
        .watch(communityPostsProvider(
            PostPaginationParams(communityId: communityId)))
        .when(
          loading: () => _buildLoadingState(isDark),
          error: (error, st) => _buildErrorState(error.toString(), isDark),
          data: (postsResponse) {
            if (postsResponse.data.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  'No posts in this community',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              );
            }
            return Column(
              children: postsResponse.data.map((post) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  post.body,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _showCommentDialog(post.id, post.title),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.comment,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                post.commentCount.toString(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ID: ${post.id.substring(0, 8)}...',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            '${post.likeCount} likes',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
  }

  Widget _buildActivityCard(
    dynamic activity,
    bool isDark,
  ) {
    final isCompleted = activity.isCompleted ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (isCompleted) {
                ref
                    .read(activitiesNotifierProvider.notifier)
                    .unmarkActivityComplete(widget.habit.id, activity.id);
              } else {
                ref
                    .read(activitiesNotifierProvider.notifier)
                    .markActivityComplete(widget.habit.id, activity.id);
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color:
                    isCompleted ? const Color(0xFF6366F1) : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF6366F1)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  width: isCompleted ? 0 : 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.activityType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${activity.value} ${activity.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    if (activity.note != null && activity.note!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '• ${activity.note}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ref
                  .read(activitiesNotifierProvider.notifier)
                  .deleteActivity(widget.habit.id, activity.id);
            },
            child: Icon(
              Icons.close,
              size: 18,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Error Loading Activities',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivitiesState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_outlined,
            size: 48,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No Activities Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create an activity to get started',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return const Color(0xFF6366F1);
    }
    try {
      return Color(int.parse('FF${hexColor.replaceFirst('#', '')}', radix: 16));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }
}
