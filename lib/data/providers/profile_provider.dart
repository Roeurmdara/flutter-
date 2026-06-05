import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../services/profile_service.dart';
import '../models/profile_model.dart';
import '../models/follower_model.dart';
import 'auth_provider.dart';
import 'dart:io';

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

  /// Upload an avatar file and return the resulting URL, or null on failure.
  Future<String?> uploadAvatarFile(File file) async {
    try {
      // Optionally set a loading state here if desired
      final url = await _service.uploadAvatar(file);
      return url;
    } catch (e) {
      debugPrint('Avatar upload failed: $e');
      return null;
    }
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
      }
    } catch (_) {
      // Ignore cache read errors; the profile can be fetched from the API.
    }
  }

  // ── Save profile to SharedPreferences ───────────────────────────────────
  Future<void> _cacheProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_profile', jsonEncode(profile.toJson()));
    } catch (_) {
      // Ignore cache write errors.
    }
  }

  // ── Fetch from API ───────────────────────────────────────────────────────
  Future<void> fetchUserProfile() async {
    state = state.copyWith(isLoading: true);

    final response = await _service.getUserProfile();

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

// ══════════════════════════════════════════════════════════════════════════════
// FOLLOWERS STATE & NOTIFIER
// ══════════════════════════════════════════════════════════════════════════════

class FollowersState {
  final List<FollowerUser> followers;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PaginationMeta meta;
  final int currentPage;
  final int pageSize;

  const FollowersState({
    this.followers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    required this.meta,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  FollowersState copyWith({
    List<FollowerUser>? followers,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PaginationMeta? meta,
    int? currentPage,
    int? pageSize,
  }) {
    return FollowersState(
      followers: followers ?? this.followers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      meta: meta ?? this.meta,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class FollowersNotifier extends StateNotifier<FollowersState> {
  final UserProfileService _service;

  FollowersNotifier(this._service)
      : super(FollowersState(
          meta: PaginationMeta(
            page: 1,
            size: 0,
            totalElements: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            perPage: 20,
            total: 0,
            lastPage: 1,
          ),
        ));

  /// Fetch followers with pagination
  Future<void> fetchFollowers({int page = 1, int pageSize = 20}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final response = await _service.getFollowers(
        page: page,
        perPage: pageSize,
      );

      if (response.success) {
        if (page == 1) {
          state = state.copyWith(
            followers: response.data,
            isLoading: false,
            isLoadingMore: false,
            meta: response.meta,
            currentPage: page,
            pageSize: pageSize,
            error: null,
          );
        } else {
          state = state.copyWith(
            followers: [...state.followers, ...response.data],
            isLoading: false,
            isLoadingMore: false,
            meta: response.meta,
            currentPage: page,
            pageSize: pageSize,
            error: null,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.message,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching followers: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to fetch followers: $e',
      );
    }
  }

  /// Load more followers
  Future<void> loadMoreFollowers() async {
    if (state.meta.hasNext && !state.isLoadingMore) {
      await fetchFollowers(
        page: state.currentPage + 1,
        pageSize: state.pageSize,
      );
    }
  }

  /// Refresh followers list
  Future<void> refreshFollowers() async {
    await fetchFollowers(page: 1, pageSize: state.pageSize);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FOLLOWING STATE & NOTIFIER
// ══════════════════════════════════════════════════════════════════════════════

class FollowingState {
  final List<FollowerUser> following;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PaginationMeta meta;
  final int currentPage;
  final int pageSize;

  const FollowingState({
    this.following = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    required this.meta,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  FollowingState copyWith({
    List<FollowerUser>? following,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PaginationMeta? meta,
    int? currentPage,
    int? pageSize,
  }) {
    return FollowingState(
      following: following ?? this.following,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      meta: meta ?? this.meta,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class FollowingNotifier extends StateNotifier<FollowingState> {
  final UserProfileService _service;

  FollowingNotifier(this._service)
      : super(FollowingState(
          meta: PaginationMeta(
            page: 1,
            size: 0,
            totalElements: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            perPage: 20,
            total: 0,
            lastPage: 1,
          ),
        ));

  /// Fetch following list with pagination
  Future<void> fetchFollowing({int page = 1, int pageSize = 20}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final response = await _service.getFollowing(
        page: page,
        perPage: pageSize,
      );

      if (response.success) {
        if (page == 1) {
          state = state.copyWith(
            following: response.data,
            isLoading: false,
            isLoadingMore: false,
            meta: response.meta,
            currentPage: page,
            pageSize: pageSize,
            error: null,
          );
        } else {
          state = state.copyWith(
            following: [...state.following, ...response.data],
            isLoading: false,
            isLoadingMore: false,
            meta: response.meta,
            currentPage: page,
            pageSize: pageSize,
            error: null,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: response.message,
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching following: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to fetch following: $e',
      );
    }
  }

  /// Load more following
  Future<void> loadMoreFollowing() async {
    if (state.meta.hasNext && !state.isLoadingMore) {
      await fetchFollowing(
        page: state.currentPage + 1,
        pageSize: state.pageSize,
      );
    }
  }

  /// Refresh following list
  Future<void> refreshFollowing() async {
    await fetchFollowing(page: 1, pageSize: state.pageSize);
  }
}

// ── Service provider ──────────────────────────────────────────────────────────
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  final service = UserProfileService();
  final token = ref.watch(authProvider).user?.token ?? '';
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

// ── Followers provider ────────────────────────────────────────────────────────
final followersProvider =
    StateNotifierProvider<FollowersNotifier, FollowersState>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return FollowersNotifier(service);
});

// ── Following provider ────────────────────────────────────────────────────────
final followingProvider =
    StateNotifierProvider<FollowingNotifier, FollowingState>((ref) {
  final service = ref.watch(userProfileServiceProvider);
  return FollowingNotifier(service);
});
