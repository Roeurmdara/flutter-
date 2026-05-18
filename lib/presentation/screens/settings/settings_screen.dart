import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/custom_buttons.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool isDark) onThemeToggle;
  final bool isDarkMode;
  final Future<void> Function() onLogout;

  const SettingsScreen({
    Key? key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onLogout,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Appearance', isDark),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.brightness_7,
              title: 'Dark Mode',
              isDark: isDark,
              trailing: Switch(
                value: widget.isDarkMode,
                onChanged: (value) {
                  widget.onThemeToggle(value);
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Notifications', isDark),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.notifications,
              title: 'Enable Notifications',
              isDark: isDark,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.smart_toy,
              title: 'Smart Reminders',
              isDark: isDark,
              trailing: Switch(
                value: _smartReminders,
                onChanged: (value) {
                  setState(() {
                    _smartReminders = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Account', isDark),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.person,
              title: 'Edit Profile',
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.language,
              title: 'Language',
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              isDark: isDark,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('About', isDark),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.info,
              title: 'Version 1.0.0',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.titleLarge(
        isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryPurple,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleMedium(
                  isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
          ],
        ),
      ),
    );
  }

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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
