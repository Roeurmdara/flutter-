import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/community_post_model.dart';
import '../../../data/providers/community_provider.dart';
import '../../widgets/image_viewer_dialog.dart';

class CommunityPostCard extends ConsumerWidget {
  final CommunityPost post;
  final String communityId;
  final VoidCallback? onTap;
  final VoidCallback? onCommentsTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final Function(String)? onAuthorTap;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.communityId,
    this.onTap,
    this.onCommentsTap,
    this.onEditTap,
    this.onDeleteTap,
    this.onAuthorTap,
  });

  String _getReadTime(String body) {
    if (body.trim().isEmpty) return '1 min';
    final words = body.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 150).ceil().clamp(1, 60);
    return '$minutes min';
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

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    final userAsync = ref.watch(userProfileByIdProvider(post.authorId));
    final embeddedName = post.authorUsername;
    final displayName = userAsync.maybeWhen(
      data: (profileResponse) => profileResponse.data?.username ?? embeddedName,
      orElse: () => embeddedName,
    );

    final cardContent = Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20), // Rounded corners matching design
        border: Border.all(color: border),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => onAuthorTap?.call(post.authorId),
                  child: _AuthorAvatar(post: post),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onAuthorTap?.call(post.authorId),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title.trim().isNotEmpty
                              ? post.title.trim()
                              : 'Habit Routine',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: text,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_getReadTime(post.body)} • ${displayName ?? "member"}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: sub,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: sub.withValues(alpha: 0.8),
                  ),
                ),
                _PostMenu(onEdit: onEditTap, onDelete: onDeleteTap),
              ],
            ),
            const SizedBox(height: 14),

            // ── Post body content ───────────────────────────────────────────
            if (post.body.trim().isNotEmpty) ...[
              Text(
                post.body.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: text.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Post Cover Image ────────────────────────────────────────────
            if (_validImageUrl(post.imageUrl) != null) ...[
              GestureDetector(
                onTap: () => showImageViewer(
                  context,
                  _validImageUrl(post.imageUrl)!,
                  post.title.trim().isNotEmpty ? post.title.trim() : 'Post Image',
                ),
                child: _PostImage(imageUrl: _validImageUrl(post.imageUrl)!),
              ),
              const SizedBox(height: 16),
            ],

            // ── Footer row: Stats + View Article Button ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Stats
                Row(
                  children: [
                    _StatIcon(
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFF25C74),
                      label: _formatCount(post.likeCount),
                      onTap: () => ref
                          .read(postOperationsProvider.notifier)
                          .reactToPost(postId: post.id),
                    ),
                    const SizedBox(width: 14),
                    _StatIcon(
                      icon: Icons.chat_bubble_rounded,
                      iconColor: const Color(0xFFF5C542),
                      label: _formatCount(post.commentCount),
                      onTap: onCommentsTap,
                    ),
                    const SizedBox(width: 14),
                    _StatIcon(
                      icon: Icons.visibility_rounded,
                      iconColor: const Color(0xFF8F9BB3),
                      label: _formatCount(post.likeCount * 7 + post.commentCount * 3 + 24),
                    ),
                  ],
                ),

                // Action Button
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF2C303B) : const Color(0xFF1A1D24),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'View Article',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
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

    return onTap != null
        ? GestureDetector(
            onTap: onTap,
            child: cardContent,
          )
        : cardContent;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-Widgets
// ─────────────────────────────────────────────────────────────────────────────

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

class _PostImage extends StatelessWidget {
  final String imageUrl;

  const _PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16), // Rounded matching mockup card image
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
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
        color: AppColors.primaryPurple.withValues(alpha: 0.12),
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

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;

  const _StatIcon({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textThemeColor = isDark ? AppColors.darkText : AppColors.lightText;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: textThemeColor.withValues(alpha: 0.7),
          ),
        ),
      ],
    );

    return onTap != null
        ? GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: child,
            ),
          )
        : child;
  }
}

class _PostMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _PostMenu({this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        size: 20,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            height: 38,
            child: Text('Edit'),
          ),
        if (onDelete != null)
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
