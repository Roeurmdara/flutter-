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
    print('✓ SharedPreferences initialized globally');
  }

  SessionNotifier(this._communityService, this._postService)
      : super(UserSession.empty()) {
    // Load from storage immediately and synchronously if possible
    _loadStorageSynchronously();
  }

  /// Load session from storage synchronously (if already cached) or async
  void _loadStorageSynchronously() {
    print(
        '🔍 SessionNotifier: _loadStorageSynchronously() called, _prefs=$_prefs');
    if (_prefs != null) {
      // If prefs already loaded, use synchronously
      _loadFromStorageSync();
    } else {
      // Otherwise load async and update state
      print('⚠️ SessionNotifier: _prefs is null, loading async');
      _initializeSession();
    }
  }

  /// Load session from SharedPreferences synchronously (for cached prefs)
  void _loadFromStorageSync() {
    try {
      print('🔍 _loadFromStorageSync: reading key "$_storageKey"');
      final sessionJson = _prefs?.getString(_storageKey);
      print('🔍 _loadFromStorageSync: raw data=$sessionJson');

      if (sessionJson != null && sessionJson.isNotEmpty) {
        final loaded = UserSession.fromJson(jsonDecode(sessionJson));
        state = loaded;
        print(
            '✅ Session loaded from storage: ${state.joinedCommunityIds.length} joined, ${state.createdCommunityIds.length} created');
        print('📋 Joined IDs: ${state.joinedCommunityIds}');
        print('📋 Created IDs: ${state.createdCommunityIds}');
      } else {
        print('⚠️ No session data found in storage');
      }
    } catch (e, st) {
      print('❌ Error loading session synchronously: $e');
      print('Stack: $st');
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
      print(
          '✓ Session initialized: ${state.joinedCommunityIds.length} joined, ${state.createdCommunityIds.length} created');
    } catch (e) {
      print('Error initializing session: $e');
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
    } catch (e) {
      print('Error loading session from storage: $e');
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
      print('💾 Saving session to storage:');
      print('   Joined: ${state.joinedCommunityIds}');
      print('   Created: ${state.createdCommunityIds}');
      print('   JSON length: ${json.length} chars');

      final success = await prefs.setString(_storageKey, json);
      print('✅ Session saved to storage (success=$success)');

      // Verify it was saved by reading it back
      final verify = prefs.getString(_storageKey);
      print(
          '🔍 Verification: data exists=${verify != null}, length=${verify?.length ?? 0}');
    } catch (e, st) {
      print('❌ Error saving session to storage: $e');
      print('Stack: $st');
    }
  }

  /// Sync with server to get fresh data (don't override existing data)
  Future<void> _syncWithServer() async {
    try {
      // Optionally sync with server, but don't override local data
      // For now, skip this since we're managing data locally
    } catch (e) {
      print('Error syncing with server: $e');
    }
  }

  /// Add joined community and persist
  Future<void> joinCommunity(String communityId) async {
    print('🔗 joinCommunity($communityId) called');
    print('   Current joined: ${state.joinedCommunityIds}');

    if (!state.joinedCommunityIds.contains(communityId)) {
      state = state.copyWith(
        joinedCommunityIds: [...state.joinedCommunityIds, communityId],
        lastSyncTime: DateTime.now(),
      );
      print('✅ State updated: ${state.joinedCommunityIds}');
      await _saveToStorage();
      print('✅ Community joined: $communityId');
    } else {
      print('⚠️ Already joined: $communityId');
    }
  }

  /// Remove joined community and persist
  Future<void> leaveCommunity(String communityId) async {
    print('🔗 leaveCommunity($communityId) called');
    print('   Current joined: ${state.joinedCommunityIds}');

    if (state.joinedCommunityIds.contains(communityId)) {
      state = state.copyWith(
        joinedCommunityIds:
            state.joinedCommunityIds.where((id) => id != communityId).toList(),
        lastSyncTime: DateTime.now(),
      );
      print('✅ State updated: ${state.joinedCommunityIds}');
      await _saveToStorage();
      print('✅ Community left: $communityId');
    } else {
      print('⚠️ Not joined: $communityId');
    }
  }

  /// Add created community and persist
  Future<void> createCommunity(String communityId) async {
    print('🔗 createCommunity($communityId) called');
    print('   Current created: ${state.createdCommunityIds}');

    if (!state.createdCommunityIds.contains(communityId)) {
      state = state.copyWith(
        createdCommunityIds: [...state.createdCommunityIds, communityId],
        lastSyncTime: DateTime.now(),
      );
      print('✅ State updated: ${state.createdCommunityIds}');
      await _saveToStorage();
      print('✅ Community created: $communityId');
    } else {
      print('⚠️ Already created: $communityId');
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
      print('✓ Session cleared');
    } catch (e) {
      print('Error clearing session: $e');
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
      print('🌐 Syncing user communities from API...');
      print('   User ID: $userId');

      // Fetch all communities
      final response =
          await _communityService.getCommunities(page: 1, perPage: 100);
      print('📥 Fetched ${response.communities.length} total communities');

      final joinedIds = <String>[];
      final createdIds = <String>[];

      // Check each community
      for (final community in response.communities) {
        // If user created it
        if (community.createdBy == userId) {
          print('👤 User created: ${community.name} (${community.id})');
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
              print('👥 User joined: ${community.name} (${community.id})');
              joinedIds.add(community.id);
            }
          } catch (e) {
            print('⚠️ Could not check members for ${community.id}: $e');
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
        print('✅ Session synced from API!');
        print('   Joined: ${joinedIds.length} communities');
        print('   Created: ${createdIds.length} communities');
      } else {
        print('⚠️ User has no communities yet');
      }
    } catch (e, st) {
      print('❌ Error syncing communities from API: $e');
      print('Stack: $st');
    }
  }
}

/// Global session provider - use this throughout the app
final sessionProvider =
    StateNotifierProvider<SessionNotifier, UserSession>((ref) {
  print('🏭 sessionProvider factory called - creating new SessionNotifier');
  // ✅ Create services WITHOUT watching other providers
  // This prevents provider recreation and data loss
  final dioClient = DioClient(secureStorage: SecureStorageService());
  final communityService = CommunityService(dio: dioClient.dio);
  final postService = CommunityPostService(dioClient: dioClient);

  final notifier = SessionNotifier(communityService, postService);
  print(
      '🏭 SessionNotifier created with state: joined=${notifier.state.joinedCommunityIds}, created=${notifier.state.createdCommunityIds}');
  return notifier;
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
