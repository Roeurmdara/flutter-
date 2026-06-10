import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
import '../../../data/providers/sync_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(bool isDark) onThemeToggle;
  final bool isDarkMode;
  final Future<void> Function() onLogout;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.onLogout,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;

  late final AnimationController _fabAnimCtrl;
  late final Animation<double> _fabScale;

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
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.easeOutBack),
    );
    _fabAnimCtrl.forward();

    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuthStatus();
      // Sync user's communities from API on app startup
      final userId = ref.read(authProvider).user?.id;
      if (userId != null) {
        ref.read(sessionProvider.notifier).syncUserCommunitiesFromAPI(userId);
      }
    });
  }

  @override
  void dispose() {
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  Widget _buildSvgIcon(String path, Color color) {
    return SvgPicture.asset(
      path,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (context) => Icon(
        Icons.calendar_today,
        color: color,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Enable real-time API sync connection
    ref.watch(syncConnectionManagerProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(isDark),
      floatingActionButton: _currentTabIndex == 0
          ? ScaleTransition(
              scale: _fabScale,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.heroGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => _showCreateHabitModal(context),
                    child: const Icon(Icons.add_rounded,
                        size: 26, color: Colors.white),
                  ),
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
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const navContentHeight = 72.0;

    return Container(
      height: navContentHeight + bottomInset,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _navItems.map((item) {
            final isActive = _currentTabIndex == item.index;
            return GestureDetector(
              onTap: () => setState(() => _currentTabIndex = item.index),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 72,
                height: navContentHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Active indicator pill
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: isActive ? 48 : 0,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryPurple
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Icon with scale animation
                    AnimatedScale(
                      scale: isActive ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: _buildSvgIcon(
                        item.iconPath,
                        isActive ? AppColors.primaryPurple : inactiveColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Label
                    Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isActive ? AppColors.primaryPurple : inactiveColor,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
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
