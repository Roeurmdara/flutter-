import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/community_service.dart';
import '../services/community_post_service.dart';
import '../services/dio_client.dart';
import '../services/secure_storage_service.dart';

/// Global session state that persists all user data
class UserSession {
  final List<String> joinedCommunityIds;
  final List<String> createdCommunityIds;
  final Map<String, dynamic> userUpdates; // Track any user profile/data updates
  final DateTime lastSyncTime;

  UserSession({
    this.joinedCommunityIds = const [],
    this.createdCommunityIds = const [],
    this.userUpdates = const {},
    DateTime? lastSyncTime,
  }) : lastSyncTime = lastSyncTime ?? DateTime.now();

  /// Convert session to JSON for storage
  Map<String, dynamic> toJson() => {
        'joinedCommunityIds': joinedCommunityIds,
        'createdCommunityIds': createdCommunityIds,
        'userUpdates': userUpdates,
        'lastSyncTime': lastSyncTime.toIso8601String(),
      };

  /// Create session from JSON
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      joinedCommunityIds: List<String>.from(json['joinedCommunityIds'] ?? []),
      createdCommunityIds: List<String>.from(json['createdCommunityIds'] ?? []),
      userUpdates: Map<String, dynamic>.from(json['userUpdates'] ?? {}),
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'])
          : DateTime.now(),
    );
  }

  /// Create empty session
  factory UserSession.empty() => UserSession();

  /// Copy with updates
  UserSession copyWith({
    List<String>? joinedCommunityIds,
    List<String>? createdCommunityIds,
    Map<String, dynamic>? userUpdates,
    DateTime? lastSyncTime,
  }) {
    return UserSession(
      joinedCommunityIds: joinedCommunityIds ?? this.joinedCommunityIds,
      createdCommunityIds: createdCommunityIds ?? this.createdCommunityIds,
      userUpdates: userUpdates ?? this.userUpdates,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Global session notifier that manages all persistent user data
class SessionNotifier extends StateNotifier<UserSession> {
  static const String _storageKey = 'user_session';
  final CommunityService _communityService;
  final CommunityPostService _postService;
  static SharedPreferences? _prefs;

  /// Static method to initialize prefs early (call from main() before running app)
  static void initializePrefs(SharedPreferences prefs) {
    _prefs = prefs;
  }

  SessionNotifier(this._communityService, this._postService)
      : super(UserSession.empty()) {
    // Load from storage immediately and synchronously if possible
    _loadStorageSynchronously();
  }

  /// Load session from storage synchronously (if already cached) or async
  void _loadStorageSynchronously() {
    if (_prefs != null) {
      // If prefs already loaded, use synchronously
      _loadFromStorageSync();
    } else {
      // Otherwise load async and update state
      _initializeSession();
    }
  }

  /// Load session from SharedPreferences synchronously (for cached prefs)
  void _loadFromStorageSync() {
    try {
      final sessionJson = _prefs?.getString(_storageKey);

      if (sessionJson != null && sessionJson.isNotEmpty) {
        final loaded = UserSession.fromJson(jsonDecode(sessionJson));
        state = loaded;
      }
    } catch (_) {
      state = UserSession.empty();
    }
  }

  /// Initialize session from storage and cache it
  Future<void> _initializeSession() async {
    try {
      // Get SharedPreferences instance and cache it
      _prefs = await SharedPreferences.getInstance();

      // Load from local storage
      final loadedSession = await _loadFromStorage();
      state = loadedSession;
    } catch (_) {
      state = UserSession.empty();
    }
  }

  /// Load session from SharedPreferences
  Future<UserSession> _loadFromStorage() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_storageKey);
      if (sessionJson != null) {
        return UserSession.fromJson(jsonDecode(sessionJson));
      }
    } catch (_) {
      return UserSession.empty();
    }
    return UserSession.empty();
  }

  /// Save session to SharedPreferences - SYNCHRONOUS when possible
  Future<void> _saveToStorage() async {
    try {
      // Get or initialize prefs
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;

      final json = jsonEncode(state.toJson());
      await prefs.setString(_storageKey, json);
    } catch (_) {
      // Ignore storage write errors; session can be rebuilt from API.
    }
  }

  /// Sync with server to get fresh data (don't override existing data)
  Future<void> _syncWithServer() async {
    try {
      // Optionally sync with server, but don't override local data
      // For now, skip this since we're managing data locally
    } catch (_) {
      // Ignore sync errors.
    }
  }

  /// Add joined community and persist
  Future<void> joinCommunity(String communityId) async {
    if (!state.joinedCommunityIds.contains(communityId)) {
      state = state.copyWith(
        joinedCommunityIds: [...state.joinedCommunityIds, communityId],
        lastSyncTime: DateTime.now(),
      );
      await _saveToStorage();
    }
  }

  /// Remove joined community and persist
  Future<void> leaveCommunity(String communityId) async {
    if (state.joinedCommunityIds.contains(communityId)) {
      state = state.copyWith(
        joinedCommunityIds:
            state.joinedCommunityIds.where((id) => id != communityId).toList(),
        lastSyncTime: DateTime.now(),
      );
      await _saveToStorage();
    }
  }

  /// Add created community and persist
  Future<void> createCommunity(String communityId) async {
    if (!state.createdCommunityIds.contains(communityId)) {
      state = state.copyWith(
        createdCommunityIds: [...state.createdCommunityIds, communityId],
        lastSyncTime: DateTime.now(),
      );
      await _saveToStorage();
    }
  }

  /// Update user data and persist
  Future<void> updateUserData(String key, dynamic value) async {
    final updatedUserData = Map<String, dynamic>.from(state.userUpdates);
    updatedUserData[key] = value;

    state = state.copyWith(
      userUpdates: updatedUserData,
      lastSyncTime: DateTime.now(),
    );
    await _saveToStorage();
  }

  /// Clear session (on logout)
  Future<void> clearSession() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      _prefs = prefs;
      await prefs.remove(_storageKey);
      state = UserSession.empty();
    } catch (_) {
      state = UserSession.empty();
    }
  }

  /// Check if community is joined
  bool isCommunityJoined(String communityId) {
    return state.joinedCommunityIds.contains(communityId);
  }

  /// Check if community is created by user
  bool isCommunityCreated(String communityId) {
    return state.createdCommunityIds.contains(communityId);
  }

  /// Get all user updates
  Map<String, dynamic> getUserUpdates() => state.userUpdates;

  /// Force sync with server
  Future<void> resyncWithServer() async {
    await _syncWithServer();
  }

  /// Load user's communities from API (call on app startup)
  /// Checks each community to see if user is a member or creator
  Future<void> syncUserCommunitiesFromAPI(String userId) async {
    try {
      // Fetch all communities
      final response =
          await _communityService.getCommunities(page: 1, perPage: 100);

      final joinedIds = <String>[];
      final createdIds = <String>[];

      // Check each community
      for (final community in response.communities) {
        // If user created it
        if (community.createdBy == userId) {
          createdIds.add(community.id);
          joinedIds.add(community.id); // Creator is also a member
        }
        // Check if user is a member
        else {
          try {
            final members = await _communityService.getCommunityMembers(
              community.id,
              page: 1,
              perPage: 100,
            );

            // Check if current user is in members list
            if (members.members.any((m) => m.userId == userId)) {
              joinedIds.add(community.id);
            }
          } catch (_) {
            // Ignore communities whose member list is not accessible.
          }
        }
      }

      // Update state with synced data
      if (joinedIds.isNotEmpty || createdIds.isNotEmpty) {
        state = state.copyWith(
          joinedCommunityIds: joinedIds,
          createdCommunityIds: createdIds,
          lastSyncTime: DateTime.now(),
        );
        await _saveToStorage();
      }
    } catch (_) {
      // Keep the locally cached session if API sync fails.
    }
  }
}

/// Global session provider - use this throughout the app
final sessionProvider =
    StateNotifierProvider<SessionNotifier, UserSession>((ref) {
  // ✅ Create services WITHOUT watching other providers
  // This prevents provider recreation and data loss
  final dioClient = DioClient(secureStorage: SecureStorageService());
  final communityService = CommunityService(dio: dioClient.dio);
  final postService = CommunityPostService(dioClient: dioClient);

  return SessionNotifier(communityService, postService);
});

final isCommunityJoinedProvider =
    Provider.family<bool, String>((ref, communityId) {
  final session = ref.watch(sessionProvider);
  return session.joinedCommunityIds.contains(communityId);
});

/// Convenience provider to check if a community is created
final isCommunityCreatedProvider =
    Provider.family<bool, String>((ref, communityId) {
  final session = ref.watch(sessionProvider);
  return session.createdCommunityIds.contains(communityId);
});

/// Convenience provider to get user updates
final userUpdatesProvider = Provider<Map<String, dynamic>>((ref) {
  final session = ref.watch(sessionProvider);
  return session.userUpdates;
});
