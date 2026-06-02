import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_post_model.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/profile_provider.dart';

class CommunityPostCard extends ConsumerWidget {
  final CommunityPost post;
  final String communityId;
  final VoidCallback? onCommentsTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final Function(String)? onAuthorTap;

  const CommunityPostCard({
    Key? key,
    required this.post,
    required this.communityId,
    this.onCommentsTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onAuthorTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (post.isPinned) ...[
                            Icon(
                              Icons.push_pin,
                              size: 12,
                              color: AppColors.primaryPurple,
                            ),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              post.title,
                              style: AppTypography.headlineSmall(
                                Theme.of(context).colorScheme.onSurface,
                              ).copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: () => onAuthorTap?.call(post.authorId),
                        child: _AuthorDisplay(authorId: post.authorId),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDate(post.createdAt),
                        style: AppTypography.bodySmall(
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                        ).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                _PostMenu(
                  onEdit: onEditTap,
                  onDelete: onDeleteTap,
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              post.body,
              style: AppTypography.bodyMedium(
                Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ).copyWith(
                fontSize: 13,
                height: 1.55,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Divider
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.4),
          ),

          // Footer actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                _ActionButton(
                  icon: Icons.thumb_up_outlined,
                  label: _formatCount(post.likeCount),
                  onTap: () => ref
                      .read(postOperationsProvider.notifier)
                      .reactToPost(postId: post.id),
                ),
                _ActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: _formatCount(post.commentCount),
                  onTap: onCommentsTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.bodySmall(
                Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              ).copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _PostMenu({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz,
        size: 18,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 2,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          height: 36,
          child: Text(
            'Edit',
            style: AppTypography.bodySmall(
              Theme.of(context).colorScheme.onSurface,
            ).copyWith(fontSize: 13),
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 36,
          child: Text(
            'Delete',
            style: AppTypography.bodySmall(Colors.red[400]!)
                .copyWith(fontSize: 13),
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
    );
  }
}

// ── Author Display with name fetching ──────────────────────────
class _AuthorDisplay extends ConsumerWidget {
  final String authorId;

  const _AuthorDisplay({required this.authorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileByIdProvider(authorId));

    return Row(
      children: [
        Icon(
          Icons.person_outline,
          size: 12,
          color: AppColors.primaryPurple,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: userAsync.when(
            data: (profileResponse) {
              final profile = profileResponse.data;
              final displayName =
                  profile?.username ?? 'Unknown';
              return Text(
                'By: $displayName',
                style: AppTypography.bodySmall(
                  AppColors.primaryPurple,
                ).copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
            loading: () => Text(
              'By: Loading...',
              style: AppTypography.bodySmall(
                AppColors.primaryPurple,
              ).copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            error: (_, __) => Text(
              'By: ${authorId.substring(0, 8)}...',
              style: AppTypography.bodySmall(
                AppColors.primaryPurple,
              ).copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
