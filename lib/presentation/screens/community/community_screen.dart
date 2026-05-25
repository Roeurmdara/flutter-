import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/category_providers.dart';
import '../../../data/models/community_model.dart';
import '../../../data/providers/session_provider.dart';
import 'community_posts_feed_screen.dart';
import 'community_search_screen.dart';


class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = ref.watch(sessionProvider);
    final joinedIds = session.joinedCommunityIds;
    final createdIds = session.createdCommunityIds;
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;

    final allCommunitiesAsync = ref.watch(
      communitiesProvider(
        CommunityPaginationParams(page: 1, perPage: 100),
      ),
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,

      // ── FAB: circle + icon floats above the nav bar ──────────────
      floatingActionButton: SizedBox(
        width: 52,
        height: 52,
        child: FloatingActionButton(
          onPressed: () => _showCreateCommunityDialog(context, ref),
          backgroundColor: AppColors.primaryPurple,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Communities',
          style: AppTypography.titleLarge(
            isDark ? AppColors.darkText : AppColors.lightText,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        // Only search icon — no add button
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _AppBarIconButton(
              icon: Icons.search_rounded,
              isDark: isDark,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CommunitySearchScreen()),
              ),
            ),
          ),
        ],
      ),

      body: allCommunitiesAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryPurple,
            strokeWidth: 2,
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Something went wrong',
            style: AppTypography.bodyMedium(
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        data: (response) {
          final all = response.communities;

          final myCommunities =
              all.where((c) => createdIds.contains(c.id)).toList();

          final joinedCommunities = all
              .where(
                  (c) => joinedIds.contains(c.id) && !createdIds.contains(c.id))
              .toList();

          if (myCommunities.isEmpty && joinedCommunities.isEmpty) {
            return _EmptyState(isDark: isDark);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              if (myCommunities.isNotEmpty) ...[
                _SectionHeader(
                  title: 'My Communities',
                  count: myCommunities.length,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...myCommunities.map((c) => _CommunityTile(
                      community: c,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommunityPostsFeedScreen(
                            communityId: c.id,
                            communityName: c.name,
                          ),
                        ),
                      ),
                    )),
                const SizedBox(height: 28),
              ],

              if (joinedCommunities.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Joined',
                  count: joinedCommunities.length,
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                ...joinedCommunities.map((c) => _CommunityTile(
                      community: c,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommunityPostsFeedScreen(
                            communityId: c.id,
                            communityName: c.name,
                          ),
                        ),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showCreateCommunityDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => const _CreateCommunityDialog(),
    );
  }
}

// ─── AppBar icon button ────────────────────────────────────────────
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onPressed;

  const _AppBarIconButton({
    required this.icon,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
    );
  }
}

// ─── Empty state ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryPurple.withOpacity(0.10),
            ),
            child: Icon(
              Icons.groups_rounded,
              size: 36,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No communities yet',
            style: AppTypography.bodyLarge(
              isDark ? AppColors.darkText : AppColors.lightText,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to create or join one',
            style: AppTypography.bodySmall(
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.bodySmall(
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: AppTypography.bodySmall(AppColors.primaryPurple)
                .copyWith(fontWeight: FontWeight.w700, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

// ─── Community tile ────────────────────────────────────────────────
class _CommunityTile extends StatelessWidget {
  final Community community;
  final bool isDark;
  final VoidCallback onTap;

  const _CommunityTile({
    required this.community,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
            _Avatar(community: community),
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
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark
                  ? AppColors.darkTextSecondary.withOpacity(0.4)
                  : AppColors.lightTextSecondary.withOpacity(0.4),
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

// ─── Avatar ────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final Community community;
  const _Avatar({required this.community});

  @override
  Widget build(BuildContext context) {
    if (community.coverImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          community.coverImage!,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.groups_rounded,
          size: 22,
          color: AppColors.primaryPurple,
        ),
      );
}

// ─── Create Community Dialog ───────────────────────────────────────
class _CreateCommunityDialog extends ConsumerStatefulWidget {
  const _CreateCommunityDialog();

  @override
  ConsumerState<_CreateCommunityDialog> createState() =>
      _CreateCommunityDialogState();
}

class _CreateCommunityDialogState
    extends ConsumerState<_CreateCommunityDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryPurple.withOpacity(0.12),
                  ),
                  child: Icon(Icons.groups_rounded,
                      size: 18, color: AppColors.primaryPurple),
                ),
                const SizedBox(width: 12),
                Text(
                  'New Community',
                  style: AppTypography.titleLarge(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name field
            _DialogField(
              controller: _nameController,
              hint: 'Community name',
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Description field
            _DialogField(
              controller: _descriptionController,
              hint: 'Description (optional)',
              maxLines: 3,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            // Category dropdown
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox.shrink();
                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId ?? categories.first.id,
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  dropdownColor: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  style: AppTypography.bodyMedium(
                      isDark ? AppColors.darkText : AppColors.lightText),
                  decoration: InputDecoration(
                    hintText: 'Category',
                    hintStyle: AppTypography.bodyMedium(
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  items: categories
                      .map((cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTypography.bodyMedium(
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ).copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _create,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Create',
                            style: AppTypography.bodyMedium(Colors.white)
                                .copyWith(fontWeight: FontWeight.w600),
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

  Future<void> _create() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a community name')),
      );
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newCommunity =
          await ref.read(communityServiceProvider).createCommunity(
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                categoryId: _selectedCategoryId!,
              );

      await ref.read(sessionProvider.notifier).createCommunity(newCommunity.id);
      ref.invalidate(communitiesProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${_nameController.text.trim()} created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ─── Reusable dialog text field ────────────────────────────────────
class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool isDark;

  const _DialogField({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTypography.bodyMedium(
          isDark ? AppColors.darkText : AppColors.lightText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium(
          isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        filled: true,
        fillColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.primaryPurple.withOpacity(0.5),
            width: 1,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}