import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool isDark) onThemeToggle;
  final bool isDarkMode;
  final Future<void> Function() onLogout;
  final VoidCallback? onEditProfile;

  const SettingsScreen({
    Key? key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onLogout,
    this.onEditProfile,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;
  late bool _smartReminders;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = true;
    _smartReminders = true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Appearance ──────────────────────────────────────────
            _buildSectionLabel('Appearance', isDark),
            const SizedBox(height: 8),
            _buildCard(
              isDark: isDark,
              child: _buildToggleItem(
                icon: Icons.brightness_4_outlined,
                title: 'Dark Mode',
                isDark: isDark,
                value: widget.isDarkMode,
                onChanged: widget.onThemeToggle,
              ),
            ),

            const SizedBox(height: 24),

            // ── Notifications ───────────────────────────────────────
            _buildSectionLabel('Notifications', isDark),
            const SizedBox(height: 8),
            _buildCard(
              isDark: isDark,
              child: Column(
                children: [
                  _buildToggleItem(
                    icon: Icons.notifications_outlined,
                    title: 'Enable Notifications',
                    isDark: isDark,
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                  ),
                  _buildDivider(isDark),
                  _buildToggleItem(
                    icon: Icons.smart_toy_outlined,
                    title: 'Smart Reminders',
                    isDark: isDark,
                    value: _smartReminders,
                    onChanged: (v) => setState(() => _smartReminders = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Account ─────────────────────────────────────────────
            _buildSectionLabel('Account', isDark),
            const SizedBox(height: 8),
            _buildCard(
              isDark: isDark,
              child: Column(
                children: [
                  _buildTapItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    isDark: isDark,
                    onTap: widget.onEditProfile ?? () {},
                  ),
                  _buildDivider(isDark),
                  _buildTapItem(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildDivider(isDark),
                  _buildTapItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── About ───────────────────────────────────────────────
            _buildSectionLabel('About', isDark),
            const SizedBox(height: 8),
            _buildCard(
              isDark: isDark,
              child: _buildTapItem(
                icon: Icons.info_outline_rounded,
                title: 'Version 1.0.0',
                isDark: isDark,
                showArrow: false,
              ),
            ),

            const SizedBox(height: 32),

            // ── Logout ──────────────────────────────────────────────
            _buildCard(
              isDark: isDark,
              child: _buildTapItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDark: isDark,
                showArrow: false,
                destructive: true,
                onTap: _handleLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CARD
  // ─────────────────────────────────────────────────────────────

  Widget _buildCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: child,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DIVIDER
  // ─────────────────────────────────────────────────────────────

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAP ITEM  (matches ProfileScreen._buildQuickActionItem exactly)
  // ─────────────────────────────────────────────────────────────

  Widget _buildTapItem({
    required IconData icon,
    required String title,
    required bool isDark,
    VoidCallback? onTap,
    bool showArrow = true,
    bool destructive = false,
  }) {
    final color = destructive ? Colors.red : AppColors.primaryPurple;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: destructive
                      ? Colors.red
                      : (isDark ? AppColors.darkText : AppColors.lightText),
                ),
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TOGGLE ITEM
  // ─────────────────────────────────────────────────────────────

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT DIALOG
  // ─────────────────────────────────────────────────────────────

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}