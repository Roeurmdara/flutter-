import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/session_provider.dart';

import 'home_dashboard_screen.dart';
import '../../widgets/create_habit_modal.dart';
import '../community/community_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/edit_profile_form.dart';
import '../../../data/providers/profile_provider.dart';
import '../categories/categories_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
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
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuthStatus();
      // Sync user's communities from API on app startup
      final userId = ref.read(authProvider).user?.id;
      if (userId != null) {
        ref.read(sessionProvider.notifier).syncUserCommunitiesFromAPI(userId);
      }
    });
  }

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
              width: 55,
              height: 55,
              child: FloatingActionButton(
                onPressed: () => _showCreateHabitModal(context),
                backgroundColor: AppColors.primaryPurple,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white, // <-- Added color here
                ),
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
        return // home_screen.dart — find your SettingsScreen(...) and add onEditProfile:

            SettingsScreen(
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
          onLogout: widget.onLogout,

          // ← ADD THIS:
          onEditProfile: () {
            final profile = ref.read(profileProvider).profile;
            if (profile == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Edit Profile')),
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: EditProfileForm(
                      profile: profile,
                      profileProvider: profileProvider,
                      onCancel: () => Navigator.pop(context),
                      onSaveSuccess: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully'),
                          ),
                        );
                        ref.read(profileProvider.notifier).fetchUserProfile();
                      },
                    ),
                  ),
                ),
              ),
            );
          },
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
                    isActive ? const Color.fromARGB(255, 9, 8, 9) : Colors.grey,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateHabitModal(),
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
