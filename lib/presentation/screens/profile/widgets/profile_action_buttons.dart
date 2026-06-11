import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileActionButtons extends StatelessWidget {
  final VoidCallback onEditProfileTap;

  const ProfileActionButtons({
    super.key,
    required this.onEditProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const forestGreen = Color(0xFF1B3D2F);

    return Row(
      children: [
        // Forest green "Edit Profile" button
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onEditProfileTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: forestGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Secondary icon button (edit note)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.edit_note_rounded,
              color: isDark ? AppColors.darkText : Colors.black.withValues(alpha: 0.7),
            ),
            onPressed: onEditProfileTap,
            padding: EdgeInsets.zero,
            splashRadius: 24,
          ),
        ),
      ],
    );
  }
}
