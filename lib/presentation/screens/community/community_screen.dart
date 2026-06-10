import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/category_providers.dart';
import '../../../data/models/community_model.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/media_provider.dart';
import '../../../data/models/media_upload_model.dart';
import 'community_detail_screen.dart';
import 'community_search_screen.dart';
import '../../../core/theme/app_typography.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

Color communityColor(Community c) {
  if (c.customColor != null) {
    try {
      return Color(
          int.parse('FF${c.customColor!.replaceAll('#', '')}', radix: 16));
    } catch (_) {}
  }
  const fallback = {
    'fitness': Color(0xFFFF6B6B),
    'health': Color(0xFF10B981),
    'productivity': Color(0xFF3B82F6),
    'learning': Color(0xFF8B5CF6),
    'mindfulness': Color(0xFFFBBF24),
    'nutrition': Color(0xFF06B6D4),
    'social': Color(0xFFEC4899),
    'work': Color(0xFF6366F1),
  };
  return fallback[c.categoryId.toLowerCase()] ?? const Color(0xFF7C3AED);
}

String communityEmoji(Community c) {
  if (c.customEmoji != null && c.customEmoji!.isNotEmpty) return c.customEmoji!;
  const fallback = {
    'fitness': '💪',
    'health': '🏥',
    'productivity': '⚡',
    'learning': '📚',
    'mindfulness': '🧘',
    'nutrition': '🥗',
    'social': '👥',
    'work': '💼',
    'hobby': '🎨',
    'gaming': '🎮',
    'sports': '⚽',
    'music': '🎵',
  };
  return fallback[c.categoryId.toLowerCase()] ?? '🌟';
}

String _fmt(int n) =>
    n >= 1000 ? '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k' : '$n';

// ─── Community Screen ─────────────────────────────────────────────────────────

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = ref.watch(sessionProvider);
    final joinedIds = session.joinedCommunityIds;
    final createdIds = session.createdCommunityIds;

    final allAsync = ref.watch(
      communitiesProvider(
          const CommunityPaginationParams(page: 1, perPage: 100)),
    );

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _CreateCommunityDialog(),
        ),
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Communities',
          style: AppTypography.titleLarge(
            isDark ? AppColors.darkText : AppColors.lightText,
          ).copyWith(
            fontSize: 18, // 👈 font size change here
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CommunitySearchScreen(),
                ),
              );
              ref.invalidate(
                communitiesProvider(
                  const CommunityPaginationParams(page: 1, perPage: 100),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(communitiesProvider(
            const CommunityPaginationParams(page: 1, perPage: 100),
          ));
          try {
            await ref.read(communitiesProvider(
              const CommunityPaginationParams(page: 1, perPage: 100),
            ).future);
          } catch (_) {}
        },
        color: AppColors.primaryPurple,
        child: allAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primaryPurple, strokeWidth: 1.5)),
          error: (error, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              alignment: Alignment.center,
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          data: (response) {
            final all = response.communities;
            final mine = all.where((c) => createdIds.contains(c.id)).toList();
            final joined = all
                .where((c) =>
                    joinedIds.contains(c.id) && !createdIds.contains(c.id))
                .toList();
            final discover = all
                .where((c) =>
                    !createdIds.contains(c.id) && !joinedIds.contains(c.id))
                .toList();

            if (all.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  child: _EmptyState(isDark: isDark),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 104),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
              if (mine.isNotEmpty) ...[
                _Label('My Communities', mine.length, isDark),
                const SizedBox(height: 10),
                ...mine.map((c) => _CommunityCard(
                    community: c,
                    isDark: isDark,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CommunityDetailScreen(
                                  community: c,
                                  isJoined: true,
                                ))))),
                const SizedBox(height: 24),
              ],
              if (joined.isNotEmpty) ...[
                _Label('Joined', joined.length, isDark),
                const SizedBox(height: 10),
                ...joined.map((c) => _CommunityCard(
                    community: c,
                    isDark: isDark,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CommunityDetailScreen(
                                  community: c,
                                  isJoined: true,
                                ))))),
                const SizedBox(height: 24),
              ],
              if (discover.isNotEmpty) ...[
                _Label('Discover', discover.length, isDark),
                const SizedBox(height: 10),
                ...discover.map((c) => _CommunityCard(
                    community: c,
                    isDark: isDark,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CommunityDetailScreen(
                                  community: c,
                                  isJoined: false,
                                ))))),
              ],
            ],
          );
        },
      ),
    ),
  );
}
}

// ─── Section label ────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;
  const _Label(this.title, this.count, this.isDark);

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primaryPurple.withValues(alpha: 0.14),
            ),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: subColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Community card ───────────────────────────────────────────────────────────

class _CommunityCard extends StatelessWidget {
  final Community community;
  final bool isDark;
  final VoidCallback onTap;
  const _CommunityCard(
      {required this.community, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = communityColor(community);
    final emoji = communityEmoji(community);
    final bgColor =
        isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface;
    final nameColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final description = community.description.trim();
    final statusLabel = community.isActive ? 'Active' : 'Closed';
    final joinLabel = community.joinType.isEmpty
        ? 'Open'
        : '${community.joinType[0].toUpperCase()}${community.joinType.substring(1)}';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : color.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CommunityCover(
                  imageUrl: community.coverImage,
                  emoji: emoji,
                  color: color,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                community.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: nameColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _MemberPill(
                              count: community.memberCount,
                              color: color,
                              isDark: isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          description.isEmpty
                              ? 'No description yet'
                              : description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            height: 1.35,
                            color: subColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetaChip(
                  icon: Icons.circle,
                  label: statusLabel,
                  color: community.isActive ? AppColors.accentBlue : subColor,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _MetaChip(
                  icon: Icons.circle,
                  label: joinLabel,
                  color: color,
                  isDark: isDark,
                ),
                const Spacer(),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: color,
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

class _CommunityCover extends StatelessWidget {
  final String? imageUrl;
  final String emoji;
  final Color color;

  const _CommunityCover({
    required this.imageUrl,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _EmojiFallback(
                  emoji: emoji,
                  color: color,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: color,
                      ),
                    ),
                  );
                },
              )
            : _EmojiFallback(emoji: emoji, color: color),
      ),
    );
  }
}

class _EmojiFallback extends StatelessWidget {
  final String emoji;
  final Color color;

  const _EmojiFallback({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class _MemberPill extends StatelessWidget {
  final int count;
  final Color color;
  final bool isDark;

  const _MemberPill({
    required this.count,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          // Added "Member" text between the icon and the count
          Text(
            'member ',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight:
                  FontWeight.w600, // Slightly lighter weight for contrast
              color: color,
            ),
          ),
          Text(
            _fmt(count),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: icon == Icons.circle ? 7 : 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.08),
                  AppColors.primaryPurple.withValues(alpha: 0.03),
                ],
              ),
            ),
            child: const Center(
              child: Text('🌟', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 20),
          Text('No communities yet',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText)),
          const SizedBox(height: 6),
          Text('Tap + to create or search to join',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
        ]),
      );
}

// ─── Create community dialog ──────────────────────────────────────────────────

class _CreateCommunityDialog extends ConsumerStatefulWidget {
  const _CreateCommunityDialog();
  @override
  ConsumerState<_CreateCommunityDialog> createState() =>
      _CreateCommunityDialogState();
}

class _CreateCommunityDialogState
    extends ConsumerState<_CreateCommunityDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  XFile? _coverImageFile;
  String? _selectedCategoryId;
  bool _isLoading = false;
  Color _color = AppColors.primaryPurple;
  String _emoji = '🌟';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String get _colorHex => _color
      .toARGB32()
      .toRadixString(16)
      .padLeft(8, '0')
      .substring(2)
      .toUpperCase();

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text('New Community',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: text)),
            const SizedBox(height: 20),

            // Cover image picker (minimal): tap to pick, shows preview
            GestureDetector(
              onTap: _pickImageFromPhone,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: _coverImageFile == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library_outlined,
                                color: sub, size: 28),
                            const SizedBox(height: 8),
                            Text('Pick cover image (optional)',
                                style: TextStyle(color: sub)),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(_coverImageFile!.path),
                            fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 14),

            // Live preview — mirrors card exactly
            Container(
              height: 56,
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _color.withValues(alpha: 0.25), width: 2)),
              child: Row(children: [
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(_emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _nameCtrl.text.trim().isEmpty
                        ? 'Community name'
                        : _nameCtrl.text.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: _nameCtrl.text.trim().isEmpty ? sub : text,
                    ),
                  ),
                ),
                Text('0 members',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400, color: sub)),
                const SizedBox(width: 14),
              ]),
            ),
            const SizedBox(height: 20),

            // Name field
            _Field(
                controller: _nameCtrl,
                hint: 'Community name',
                isDark: isDark,
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 10),

            // Description field
            _Field(
                controller: _descCtrl,
                hint: 'Description (optional)',
                maxLines: 2,
                isDark: isDark),
            const SizedBox(height: 10),

            // Category dropdown
            ref.watch(categoriesProvider).when(
                  data: (cats) {
                    if (cats.isEmpty) return const SizedBox.shrink();
                    _selectedCategoryId ??= cats.first.id;
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedCategoryId,
                      onChanged: (v) => setState(() => _selectedCategoryId = v),
                      dropdownColor: surface,
                      style: TextStyle(fontSize: 14, color: text),
                      decoration: InputDecoration(
                        hintText: 'Category',
                        hintStyle: TextStyle(fontSize: 14, color: sub),
                        filled: true,
                        fillColor: bg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: cats
                          .map((c) => DropdownMenuItem(
                              value: c.id, child: Text(c.name)))
                          .toList(),
                    );
                  },
                  loading: () => const SizedBox(
                      height: 44,
                      child: Center(
                          child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5)))),
                  error: (_, __) => const SizedBox.shrink(),
                ),
            const SizedBox(height: 20),

            // Customize label
            Text('Customize',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: sub)),
            const SizedBox(height: 10),

            // Color + Emoji buttons
            Row(children: [
              Expanded(
                child: _PickerButton(
                  onTap: () => _pickColor(isDark),
                  color: _color.withValues(alpha: 0.1),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                                color: _color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text('Color',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _color)),
                      ]),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PickerButton(
                  onTap: () => _pickEmoji(isDark),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text('Emoji',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: sub)),
                      ]),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // Actions
            Row(children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 19),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.08)),
                    ),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: sub)),
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
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Create',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Upload cover image if selected and get URL
      String? coverImageUrl;

      if (_coverImageFile != null) {
        try {
          final uploadResponse =
              await ref.read(mediaServiceProvider).uploadImage(
                    imageFile: _coverImageFile!,
                    context: MediaContext.community,
                  );
          if (uploadResponse.success && uploadResponse.data?.url != null) {
            coverImageUrl = uploadResponse.data!.url;
          } else {
            throw Exception(uploadResponse.message);
          }
        } catch (uploadError) {
          throw Exception('Error uploading cover image: $uploadError');
        }
      }

      final newCommunity =
          await ref.read(communityServiceProvider).createCommunity(
                name: name,
                description: _descCtrl.text.trim(),
                categoryId: _selectedCategoryId!,
                coverImage: coverImageUrl,
                customColor: _colorHex,
                customEmoji: _emoji,
              );
      try {
        await ref.read(communityServiceProvider).joinCommunity(newCommunity.id);
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (_) {}
      await ref.read(sessionProvider.notifier).createCommunity(newCommunity.id);
      await ref.read(sessionProvider.notifier).joinCommunity(newCommunity.id);
      ref.invalidate(communitiesProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ⚪ Force the text color to be white
            content: Text(
              '$name created!',
              style: const TextStyle(color: Colors.white),
            ),
            // 🟢 Uses your app's success color
            backgroundColor: AppColors.primaryPurple,
          ),
        );
      }
    } catch (e) {
      String message = 'Error creating community';
      if (e is ApiException) {
        try {
          final data = e.data;
          Map<String, dynamic>? details;
          if (data is Map<String, dynamic>) {
            if (data['error'] is Map && data['error']['details'] != null) {
              details = Map<String, dynamic>.from(data['error']['details']);
            } else if (data['details'] is Map) {
              details = Map<String, dynamic>.from(data['details']);
            } else if (data['errors'] is Map) {
              details = Map<String, dynamic>.from(data['errors']);
            }
            if (details != null && details.isNotEmpty) {
              final messages = <String>[];
              details.forEach((key, value) {
                if (value is List) {
                  messages.addAll(value.map((v) => v.toString()));
                } else {
                  messages.add(value.toString());
                }
              });
              message = messages.join(' ');
            } else if (data['message'] != null) {
              message = data['message'].toString();
            } else {
              message = data.toString();
            }
          } else {
            message = e.toString();
          }
        } catch (_) {
          message = e.toString();
        }
      } else {
        message = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _pickColor(bool isDark) {
    final colors = [
      AppColors.primaryPurple,
      const Color(0xFFFF6B6B),
      const Color(0xFFFFA500),
      const Color(0xFFFBBF24),
      AppColors.secondaryGreen,
      const Color(0xFF3B82F6),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _Sheet(
        title: 'Color',
        isDark: isDark,
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((c) {
            final sel = c.toARGB32() == _color.toARGB32();
            return GestureDetector(
              onTap: () {
                setState(() => _color = c);
                Navigator.pop(context);
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                  border:
                      sel ? Border.all(color: Colors.white, width: 3) : null,
                  boxShadow: sel
                      ? [
                          BoxShadow(
                              color: c.withValues(alpha: 0.4), blurRadius: 8)
                        ]
                      : [],
                ),
                child: sel
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _pickEmoji(bool isDark) {
    const emojis = [
      '🌟',
      '✨',
      '🔥',
      '⚡',
      '💎',
      '🎯',
      '💪',
      '🚀',
      '🎨',
      '🎭',
      '🎮',
      '🎲',
      '😎',
      '🥳',
      '🤩',
      '❤️',
      '🧡',
      '💛',
      '💚',
      '💙',
      '💜',
      '🌈',
      '☀️',
      '🌙',
      '🏆',
      '🥇',
      '🎁',
      '🎉',
      '🍕',
      '🍔',
      '🌮',
      '☕',
      '📚',
      '✏️',
      '💻',
      '📷',
      '🎸',
      '⚽',
      '🎤',
      '🎧',
      '🎬',
      '🎪',
      '🌿',
      '🦋',
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _Sheet(
        title: 'Emoji',
        isDark: isDark,
        child: Wrap(
          spacing: 2,
          runSpacing: 2,
          children: emojis.map((e) {
            final sel = e == _emoji;
            return GestureDetector(
              onTap: () {
                setState(() => _emoji = e);
                Navigator.pop(context);
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      sel ? _color.withValues(alpha: 0.15) : Colors.transparent,
                  border: sel ? Border.all(color: _color, width: 1.5) : null,
                ),
                child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 22))),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _pickImageFromPhone() async {
    try {
      final picker = ImagePicker();
      final XFile? xfile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (xfile == null) return;
      setState(() {
        _coverImageFile = xfile;
      });
    } catch (e) {
      // ignore errors silently; user can retry
    }
  }
}

// ─── Shared picker sheet ──────────────────────────────────────────────────────

class _Sheet extends StatelessWidget {
  final String title;
  final bool isDark;
  final Widget child;
  const _Sheet(
      {required this.title, required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 18),
          child,
        ]),
      );
}

// ─── Picker button ────────────────────────────────────────────────────────────

class _PickerButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final Widget child;
  const _PickerButton(
      {required this.onTap, required this.color, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(10)),
          child: child,
        ),
      );
}

// ─── Text field ───────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final bool isDark;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
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
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: AppColors.primaryPurple.withValues(alpha: 0.35),
                width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
