import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import 'auth_provider.dart';

class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  // ✅ Cache-bust key: changes whenever avatar is updated, forcing
  //    CachedNetworkImage to reload instead of serving the stale image.
  final int avatarVersion;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.avatarVersion = 0,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    int? avatarVersion,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      avatarVersion: avatarVersion ?? this.avatarVersion,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final UserProfileService _service;

  ProfileNotifier(this._service) : super(const ProfileState()) {
    _loadCachedProfile();
  }

  // ── Load cached profile from SharedPreferences ──────────────────────────
  Future<void> _loadCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_profile');
      if (cached != null) {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        final profile = UserProfile.fromJson(map);
        state = state.copyWith(profile: profile);
        debugPrint('📦 Loaded cached profile: ${profile.username}');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load cached profile: $e');
    }
  }

  // ── Save profile to SharedPreferences ───────────────────────────────────
  Future<void> _cacheProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_profile', jsonEncode(profile.toJson()));
      debugPrint('💾 Profile cached: ${profile.username}');
    } catch (e) {
      debugPrint('⚠️ Failed to cache profile: $e');
    }
  }

  // ── Fetch from API ───────────────────────────────────────────────────────
  Future<void> fetchUserProfile() async {
    state = state.copyWith(isLoading: true);

    final token = _service.getAuthToken();
    debugPrint('🔑 Token in service: "$token"');

    final response = await _service.getUserProfile();

    debugPrint('📡 Response success: ${response.success}');
    debugPrint('📡 Response message: ${response.message}');
    debugPrint('📡 Response data: ${response.data?.username}');

    if (response.success && response.data != null) {
      await _cacheProfile(response.data!);
      state = state.copyWith(
        isLoading: false,
        profile: response.data,
        error: null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
    }
  }

  // ── Update profile ───────────────────────────────────────────────────────
  Future<bool> updateUserProfile({
    required String username,
    String? bio,
    String? avatarUrl,
  }) async {
    state = state.copyWith(isUpdating: true);

    final response = await _service.updateUserProfile(
      username: username,
      bio: bio,
      avatarUrl: avatarUrl,
    );

    if (response.success && response.data != null) {
      await _cacheProfile(response.data!);
      // ✅ Bump avatarVersion so the UI rebuilds with a fresh image URL.
      //    This forces CachedNetworkImage to treat the URL as new even if
      //    the URL string itself hasn't changed (same host, different content).
      state = state.copyWith(
        isUpdating: false,
        profile: response.data,
        error: null,
        avatarVersion: state.avatarVersion + 1,
      );
      return true;
    } else {
      state = state.copyWith(
        isUpdating: false,
        error: response.message,
      );
      return false;
    }
  }

  // ── Clear cache on logout ────────────────────────────────────────────────
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_profile');
    state = const ProfileState();
  }
}

// ── Service provider ──────────────────────────────────────────────────────────
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final service = UserProfileService();
  final token = ref.watch(authProvider).user?.token ?? '';
  debugPrint('🔧 Building service, token: "$token"');
  debugPrint('🔧 Auth user: ${ref.watch(authProvider).user?.username}');
  debugPrint('🔧 Is authenticated: ${ref.watch(authProvider).isAuthenticated}');
  if (token.isNotEmpty) {
    service.setAuthToken(token);
  }
  return service;
});

// ── Profile provider ──────────────────────────────────────────────────────────
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return ProfileNotifier(service);
});