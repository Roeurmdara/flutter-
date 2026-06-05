import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/image_crop_helper.dart';
import '../../../data/providers/profile_provider.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
class _T {
  // Colors (light / dark aware via context)
  static Color surface(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : Colors.white;

  static Color field(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFF5F5F7);

  static Color border(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.08);

  static Color labelText(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.35);

  static Color bodyText(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? Colors.white : Colors.black;

  static Color hintText(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.25)
          : Colors.black.withValues(alpha: 0.25);

  static Color cancelBg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFF0F0F2);

  static Color cancelText(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.6)
          : Colors.black.withValues(alpha: 0.5);

  // Accent — a single restrained purple
  static const accent = Color(0xFF534AB7);
  static const accentLight = Color(0xFFC7BFF9);

  // Spacing
  static const double gapSm = 10;
  static const double radius = 12;
  static const double radiusLg = 20;

  // Typography
  static const String fontFamily = 'DM Sans'; // add to pubspec.yaml

  static TextStyle label(BuildContext ctx) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: labelText(ctx),
        fontFamily: fontFamily,
      );

  static TextStyle body(BuildContext ctx) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: bodyText(ctx),
        fontFamily: fontFamily,
      );
}

// ─── Widget ───────────────────────────────────────────────────────────────────
class EditProfileForm extends ConsumerStatefulWidget {
  final dynamic profile;
  final VoidCallback onCancel;
  final VoidCallback onSaveSuccess;
  final ProviderBase<dynamic> profileProvider;

  const EditProfileForm({
    super.key,
    required this.profile,
    required this.onCancel,
    required this.onSaveSuccess,
    required this.profileProvider,
  });

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _avatarUrlController;

  String? _previewAvatarUrl;
  File? _pickedImageFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final username = widget.profile.username as String? ?? '';
    final bio = widget.profile.bio as String? ?? '';
    final avatarUrl = widget.profile.avatarUrl as String? ?? '';

    _usernameController = TextEditingController(text: username);
    _bioController = TextEditingController(text: bio);
    _avatarUrlController = TextEditingController(text: avatarUrl);
    _previewAvatarUrl = avatarUrl.isNotEmpty ? avatarUrl : null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  // ── Image picking ──────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
          source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (picked == null || !mounted) return;
      final cropped = await ImageCropHelper.cropImage(
        imagePath: picked.path,
        type: AppImageCropType.avatar,
      );
      if (cropped == null || !mounted) return;
      setState(() {
        _pickedImageFile = File(cropped.path);
        _previewAvatarUrl = null;
      });
      // Upload immediately and set the avatar URL for saving
      try {
        final notifier = ref.read(profileProvider.notifier);
        final uploaded = await notifier.uploadAvatarFile(_pickedImageFile!);
        if (uploaded != null && mounted) {
          setState(() {
            _avatarUrlController.text = uploaded;
            _previewAvatarUrl = uploaded;
            _pickedImageFile = null; // clear local preview since we use URL
          });
          _snack('Image uploaded');
        } else {
          _snack('Upload failed');
        }
      } catch (e) {
        _snack('Upload failed: $e');
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Could not pick image: $e');
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showImageSourceSheet() {
    // capture theme values from outer context before entering builder
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final hasPhoto = _previewAvatarUrl != null || _pickedImageFile != null;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ← was missing
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _SheetTile(
                icon: Icons.image_outlined,
                label: 'Choose from gallery',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
              _SheetTile(
                icon: Icons.camera_outlined,
                label: 'Take a photo',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              _SheetTile(
                icon: Icons.link_outlined,
                label: 'Paste image URL',
                onTap: () {
                  Navigator.pop(ctx);
                  _showAvatarUrlDialog();
                },
              ),
              if (hasPhoto) ...[
                const SizedBox(height: 6),
                _SheetTile(
                  icon: Icons.delete_outline_rounded, // remove — red tinted box
                  label: 'Remove photo',
                  destructive: true,
                  onTap: () {
                    setState(() {
                      _pickedImageFile = null;
                      _previewAvatarUrl = null;
                      _avatarUrlController.clear();
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── URL dialog ─────────────────────────────────────────────────────────────
  void _showAvatarUrlDialog() {
    final tempCtrl = TextEditingController(text: _avatarUrlController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _T.surface(ctx),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_T.radiusLg)),
        title: const Text('Image URL',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: _T.fontFamily)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Paste the URL of any publicly accessible image.',
              style: TextStyle(
                  fontSize: 13,
                  color: _T.labelText(ctx),
                  fontFamily: _T.fontFamily)),
          const SizedBox(height: 14),
          _MinimalTextField(
            controller: tempCtrl,
            hint: 'https://example.com/avatar.jpg',
            context: ctx,
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: _T.labelText(ctx))),
          ),
          TextButton(
            onPressed: () {
              final url = tempCtrl.text.trim();
              if (mounted) {
                setState(() {
                  _avatarUrlController.text = url;
                  _previewAvatarUrl = url.isNotEmpty ? url : null;
                  _pickedImageFile = null;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Apply',
                style:
                    TextStyle(color: _T.accent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();
    final avatarUrl = _avatarUrlController.text.trim();

    if (username.isEmpty) {
      _snack('Username cannot be empty');
      return;
    }
    if (_pickedImageFile != null && avatarUrl.isEmpty) {
      _snack('Upload the photo to save it.');
      return;
    }

    final notifier = ref.read((widget.profileProvider as dynamic).notifier);
    final success = await notifier.updateUserProfile(
      username: username,
      bio: bio.isNotEmpty ? bio : null,
      avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
    );

    if (!mounted) return;
    if (success) {
      widget.onSaveSuccess();
    } else {
      final state = ref.read(widget.profileProvider as dynamic);
      _snack(state.error ?? 'Update failed');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(widget.profileProvider as dynamic);
    final username = widget.profile.username as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Avatar ──────────────────────────────────────────────────────────
        Center(
          child: GestureDetector(
            onTap: _showImageSourceSheet,
            child: Stack(alignment: Alignment.bottomRight, children: [
              _AvatarPreview(
                username: username,
                pickedFile: _pickedImageFile,
                avatarUrl: _previewAvatarUrl,
              ),
              Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(bottom: 2, right: 2),
                decoration: BoxDecoration(
                  color: _T.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: _T.surface(context), width: 2),
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 12, color: Colors.white),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('change photo',
              style: TextStyle(
                  fontSize: 12,
                  color: _T.labelText(context),
                  letterSpacing: 0.3,
                  fontFamily: _T.fontFamily)),
        ),
        const SizedBox(height: 32),

        // ── Divider ─────────────────────────────────────────────────────────
        Divider(height: 1, thickness: 0.5, color: _T.border(context)),
        const SizedBox(height: 28),

        // ── Fields ──────────────────────────────────────────────────────────
        _FieldLabel(label: 'Username', context: context),
        const SizedBox(height: 8),
        _MinimalTextField(
          controller: _usernameController,
          hint: 'your username',
          context: context,
        ),
        const SizedBox(height: 20),

        _FieldLabel(label: 'Bio', context: context),
        const SizedBox(height: 8),
        _MinimalTextField(
          controller: _bioController,
          hint: 'a short intro about you',
          maxLines: 3,
          context: context,
        ),
        const SizedBox(height: 32),
        // ── Actions ─────────────────────────────────────────────────────────
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: _T.cancelBg(context),
                foregroundColor: _T.cancelText(context),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 21),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: _T.gapSm),
          Expanded(
            child: ElevatedButton(
              onPressed: profileState.isUpdating ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: profileState.isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ]),
      ],
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _AvatarPreview extends StatelessWidget {
  final String username;
  final File? pickedFile;
  final String? avatarUrl;

  const _AvatarPreview({
    required this.username,
    this.pickedFile,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    const size = 84.0;
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    Widget image;
    if (pickedFile != null) {
      image = Image.file(pickedFile!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _initials(initial, size));
    } else if ((avatarUrl ?? '').isNotEmpty) {
      image = Image.network(avatarUrl!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _initials(initial, size));
    } else {
      image = _initials(initial, size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _T.border(context), width: 1),
      ),
      child: ClipOval(child: image),
    );
  }

  Widget _initials(String initial, double size) {
    return Container(
      width: size,
      height: size,
      color: _T.accentLight.withValues(alpha: 0.5),
      child: Center(
        child: Text(initial,
            style: TextStyle(
              fontSize: size * 0.38,
              fontWeight: FontWeight.w500,
              color: _T.accent,
              fontFamily: _T.fontFamily,
            )),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final BuildContext context;
  const _FieldLabel({required this.label, required this.context});

  @override
  Widget build(BuildContext _) {
    return Text(label.toUpperCase(), style: _T.label(context));
  }
}

class _MinimalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final BuildContext context;

  const _MinimalTextField({
    required this.controller,
    required this.hint,
    required this.context,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext _) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: _T.body(context),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: _T.hintText(context), fontFamily: _T.fontFamily),
        filled: true,
        fillColor: _T.field(context),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_T.radius),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_T.radius),
          borderSide: const BorderSide(color: _T.accent, width: 1.0),
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFE24B4A) : _T.accent;

    return InkWell(
      borderRadius: BorderRadius.circular(_T.radius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: destructive
                    ? const Color(0xFFE24B4A)
                    : _T.bodyText(context),
                fontFamily: _T.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
