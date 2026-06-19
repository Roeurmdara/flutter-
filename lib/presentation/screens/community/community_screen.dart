import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/exceptions/api_exception.dart';
import '../../../data/providers/community_provider.dart';
import '../../../data/providers/category_providers.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/media_provider.dart';
import '../../../data/models/media_upload_model.dart';
import 'community_detail_screen.dart';
import 'community_search_screen.dart';
import '../../../core/theme/app_typography.dart';
import 'widgets/community_card.dart';

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
                  ...mine.map((c) => CommunityCard(
                      community: c,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CommunityDetailScreen(
                                  community: c, isJoined: true))))),
                  const SizedBox(height: 24),
                ],
                if (joined.isNotEmpty) ...[
                  _Label('Joined', joined.length, isDark),
                  const SizedBox(height: 10),
                  ...joined.map((c) => CommunityCard(
                      community: c,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CommunityDetailScreen(
                                  community: c, isJoined: true))))),
                  const SizedBox(height: 24),
                ],
                if (discover.isNotEmpty) ...[
                  _Label('Discover', discover.length, isDark),
                  const SizedBox(height: 10),
                  ...discover.map((c) => CommunityCard(
                      community: c,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CommunityDetailScreen(
                                  community: c, isJoined: false))))),
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

// Community card and small sub-widgets are moved to widgets/community_card.dart

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
  final Color _color = AppColors.primaryPurple;
  final String _emoji = '🌟';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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

            // Cover image picker: tap to pick, shows preview with change/remove controls
            GestureDetector(
              onTap: _coverImageFile == null ? _pickImageFromPhone : null,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: _coverImageFile == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: text.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add, color: text, size: 28),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Upload Cover Image',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, color: text),
                            ),
                            Text(
                              'Optional background banner',
                              style: TextStyle(fontSize: 12, color: sub),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_coverImageFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gradient overlay so action buttons stay legible over any photo
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.0),
                                    Colors.black.withValues(alpha: 0.45),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Change / Remove controls
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _CoverImageActionButton(
                                  icon: Icons.edit,
                                  label: 'Change',
                                  onTap: _pickImageFromPhone,
                                ),
                                const SizedBox(width: 8),
                                _CoverImageActionButton(
                                  icon: Icons.close,
                                  label: 'Remove',
                                  onTap: () =>
                                      setState(() => _coverImageFile = null),
                                ),
                              ],
                            ),
                          ),
                        ],
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
            _FieldLabel('COMMUNITY NAME', color: sub),
            const SizedBox(height: 6),
            _Field(
                controller: _nameCtrl,
                hint: 'e.g. Morning Runners Club',
                isDark: isDark,
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 14),

            // Description field
            _FieldLabel('DESCRIPTION', color: sub, optional: true),
            const SizedBox(height: 6),
            _Field(
                controller: _descCtrl,
                hint: 'What is this community about?',
                maxLines: 2,
                isDark: isDark),
            const SizedBox(height: 14),

            // Category dropdown
            _FieldLabel('CATEGORY', color: sub),
            const SizedBox(height: 6),
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

// ─── Text field ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color color;
  final bool optional;
  const _FieldLabel(this.text, {required this.color, this.optional = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.1)),
        if (optional) ...[
          const SizedBox(width: 4),
          Text('(optional)',
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: color.withValues(alpha: 0.6))),
        ],
      ],
    );
  }
}

class _CoverImageActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _CoverImageActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared minimal text field (local to this file) ──────────────────────────
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
