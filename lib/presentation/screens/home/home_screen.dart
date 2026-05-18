import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';

import '../../widgets/custom_buttons.dart';

import 'home_dashboard_screen.dart';
import '../../widgets/CreateHabitModal.dart';           // ← pulled out here
import '../categories/categories_screen.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool isDark) onThemeToggle;
  final bool isDarkMode;
  final Future<void> Function() onLogout;

  const HomeScreen({
    Key? key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onLogout,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  late final List<NavBarItem> _navItems = [
    NavBarItem(
      label: 'Today',
      index: 0,
      iconPath: 'assets/images/calendar-check-regular-full.svg',
    ),
    NavBarItem(
      label: 'Discover',
      index: 1,
      iconPath: 'assets/images/paperclip-solid-full.svg',
    ),
    NavBarItem(
      label: 'Community',
      index: 2,
      iconPath: 'assets/images/comments-regular-full.svg',
    ),
    NavBarItem(
      label: 'Profile',
      index: 3,
      iconPath: 'assets/images/circle-user-regular-full.svg',
    ),
  ];

  Widget _buildSvgIcon(String path, Color color) {
    return SvgPicture.asset(
      path,
      width: 28,
      height: 28,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (context) => Icon(
        Icons.calendar_today,
        color: color,
        size: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(isDark),
      floatingActionButton: _currentTabIndex == 0
          ? SizedBox(
              width: 48,
              height: 48,
              child: FloatingActionButton(
                onPressed: () => _showCreateHabitModal(context),
                backgroundColor: AppColors.primaryPurple,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 20),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        return HomeDashboardScreen(
          onThemeToggle: widget.onThemeToggle,
          isDarkMode: widget.isDarkMode,
        );
      case 1:
        return const CategoriesScreen();
      case 2:
        return const CommunityScreen();
      case 3:
        return ProfileScreen(
          onNavigateToSettings: () {
            setState(() => _currentTabIndex = 4);
          },
        );
      case 4:
        return SettingsScreen(
          onThemeToggle: widget.onThemeToggle,
          isDarkMode: widget.isDarkMode,
          onLogout: widget.onLogout,
        );
      default:
        return HomeDashboardScreen(
          onThemeToggle: widget.onThemeToggle,
          isDarkMode: widget.isDarkMode,
        );
    }
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _navItems.map((item) {
          final isActive = _currentTabIndex == item.index;
          return GestureDetector(
            onTap: () => setState(() => _currentTabIndex = item.index),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSvgIcon(
                    item.iconPath,
                    isActive
                        ? const Color.fromARGB(255, 9, 8, 9)
                        : Colors.grey,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? const Color.fromARGB(255, 0, 0, 0)
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showCreateHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CreateHabitModal(       // ← just a call now
        onClose: () => Navigator.pop(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class NavBarItem {
  final String label;
  final int index;
  final String iconPath;

  NavBarItem({
    required this.label,
    required this.index,
    required this.iconPath,
  });
}