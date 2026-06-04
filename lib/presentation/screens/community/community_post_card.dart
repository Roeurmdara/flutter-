import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/community_post_model.dart';
import '../../../data/providers/community_provider.dart';

class CommunityPostCard extends ConsumerWidget {
  final CommunityPost post;
  final String communityId;
  final VoidCallback? onCommentsTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final Function(String)? onAuthorTap;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.communityId,
    this.onCommentsTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.06);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onAuthorTap?.call(post.authorId),
                  child: _AuthorAvatar(post: post),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onAuthorTap?.call(post.authorId),
                    child: _AuthorMeta(post: post, text: text, sub: sub),
                  ),
                ),
                if (post.isPinned)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin_rounded,
                          size: 12,
                          color: AppColors.primaryPurple,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Pinned',
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                _PostMenu(onEdit: onEditTap, onDelete: onDeleteTap),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.title.trim().isNotEmpty) ...[
                  Text(
                    post.title.trim(),
                    style: AppTypography.bodyMedium(text).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (post.body.trim().isNotEmpty)
                  Text(
                    post.body.trim(),
                    style: AppTypography.bodyMedium(text).copyWith(
                      fontSize: 13.5,
                      height: 1.45,
                      color: text.withOpacity(0.78),
                    ),
                  ),
              ],
            ),
          ),
          if (_validImageUrl(post.imageUrl) != null)
            _PostImage(imageUrl: _validImageUrl(post.imageUrl)!),
          Divider(height: 1, color: border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                  icon: Icons.mode_comment_outlined,
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

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _AuthorAvatar extends ConsumerWidget {
  final CommunityPost post;

  const _AuthorAvatar({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fallback = _InitialAvatar(seed: post.authorUsername ?? post.authorId);
    final localAvatar = _validImageUrl(post.authorAvatarUrl);
    if (localAvatar != null) {
      return _AvatarImage(url: localAvatar, fallback: fallback);
    }

    final userAsync = ref.watch(userProfileByIdProvider(post.authorId));
    return userAsync.maybeWhen(
      data: (profileResponse) {
        final avatar = _validImageUrl(profileResponse.data?.avatarUrl);
        return avatar != null
            ? _AvatarImage(url: avatar, fallback: fallback)
            : fallback;
      },
      orElse: () => fallback,
    );
  }
}

class _AuthorMeta extends ConsumerWidget {
  final CommunityPost post;
  final Color text;
  final Color sub;

  const _AuthorMeta({
    required this.post,
    required this.text,
    required this.sub,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileByIdProvider(post.authorId));

    final embeddedName = post.authorUsername;
    final displayName = userAsync.maybeWhen(
      data: (profileResponse) => profileResponse.data?.username ?? embeddedName,
      orElse: () => embeddedName,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName == null || displayName.isEmpty
              ? 'Unknown member'
              : displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMedium(text).copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatDate(post.createdAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall(sub).copyWith(fontSize: 11.5),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _PostImage extends StatelessWidget {
  final String imageUrl;

  const _PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.zero,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).dividerColor.withOpacity(0.18),
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Theme.of(context).dividerColor.withOpacity(0.12),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  final String url;
  final Widget fallback;

  const _AvatarImage({required this.url, required this.fallback});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String seed;

  const _InitialAvatar({required this.seed});

  @override
  Widget build(BuildContext context) {
    final initial = seed.trim().isEmpty ? '?' : seed.trim()[0].toUpperCase();
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryPurple.withOpacity(0.12),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryPurple,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
    final color = Theme.of(context).colorScheme.onSurface.withOpacity(0.58);
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(68, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        Icons.more_horiz_rounded,
        size: 20,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          height: 38,
          child: Text('Edit'),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 38,
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red.shade400),
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

String? _validImageUrl(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final uri = Uri.tryParse(trimmed);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
  return trimmed;
}
