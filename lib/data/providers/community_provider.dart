import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_model.dart';
import '../models/community_post_model.dart';
import '../models/habit_category_model.dart';
import '../models/profile_model.dart';
import '../services/community_service.dart';
import '../services/community_post_service.dart';
import '../services/habit_category_service.dart';
import '../services/dio_client.dart';
import '../services/secure_storage_service.dart';
import 'session_provider.dart';
import 'profile_provider.dart';

// ─── Service providers ────────────────────────────────────────
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(secureStorage: SecureStorageService());
});

final communityServiceProvider = Provider<CommunityService>((ref) {
  return CommunityService(dio: ref.watch(dioClientProvider).dio);
});

final communityPostServiceProvider = Provider<CommunityPostService>((ref) {
  return CommunityPostService(dioClient: ref.watch(dioClientProvider));
});

final habitCategoryServiceProvider = Provider<HabitCategoryService>((ref) {
  return HabitCategoryService();
});

// using userProfileServiceProvider from profile_provider.dart

// ─── Habit categories ─────────────────────────────────────────
final habitCategoriesProvider =
    FutureProvider<List<HabitCategory>>((ref) async {
  return ref.watch(habitCategoryServiceProvider).getCategories();
});

// ─── All communities (paginated) ──────────────────────────────
final communitiesProvider =
    FutureProvider.family<CommunityListResponse, CommunityPaginationParams>(
        (ref, params) async {
  return ref.watch(communityServiceProvider).getCommunities(
        page: params.page,
        perPage: params.perPage,
      );
});

// ─── Single community detail ──────────────────────────────────
final communityDetailProvider =
    FutureProvider.family<Community, String>((ref, communityId) async {
  return ref.watch(communityServiceProvider).getCommunityById(communityId);
});

// ─── User profile by ID ───────────────────────────────────────
final userProfileByIdProvider = FutureProvider.family<ProfileResponse, String>(
  (ref, userId) async {
    return ref.watch(userProfileServiceProvider).getUserProfileById(userId);
  },
);

// ─── Community members ────────────────────────────────────────
final communityMembersProvider = FutureProvider.family<CommunityMembersResponse,
    CommunityMembersPaginationParams>((ref, params) async {
  return ref.watch(communityServiceProvider).getCommunityMembers(
        params.communityId,
        page: params.page,
        perPage: params.perPage,
      );
});

// ─── SINGLE SOURCE OF TRUTH: joined IDs come from sessionProvider ───
//
// Both community_screen and community_search_screen must watch this.
// It is kept in sync by CommunityOperationsNotifier below.
//
// Convenience derived provider so widgets only need one watch call.
final joinedCommunityIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(sessionProvider).joinedCommunityIds.toSet();
});

// ─── Community join / leave operations ────────────────────────
final communityOperationsProvider =
    StateNotifierProvider<CommunityOperationsNotifier, AsyncValue<void>>(
  (ref) =>
      CommunityOperationsNotifier(ref.watch(communityServiceProvider), ref),
);

class CommunityOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final CommunityService _service;
  final Ref _ref;

  CommunityOperationsNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> joinCommunity(String communityId) async {
    state = const AsyncValue.loading();
    try {
      await _service.joinCommunity(communityId);
      // ✅ Update the single source of truth
      await _ref.read(sessionProvider.notifier).joinCommunity(communityId);
      // ✅ Invalidate community list so member counts refresh
      _ref.invalidate(communitiesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> leaveCommunity(String communityId) async {
    state = const AsyncValue.loading();
    try {
      await _service.leaveCommunity(communityId);
      // ✅ Update the single source of truth
      await _ref.read(sessionProvider.notifier).leaveCommunity(communityId);
      // ✅ Invalidate community list so member counts refresh
      _ref.invalidate(communitiesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// ─── Create community ─────────────────────────────────────────
final createCommunityProvider =
    StateNotifierProvider<CreateCommunityNotifier, AsyncValue<Community?>>(
  (ref) => CreateCommunityNotifier(ref.watch(communityServiceProvider), ref),
);

class CreateCommunityNotifier extends StateNotifier<AsyncValue<Community?>> {
  final CommunityService _service;
  final Ref _ref;

  CreateCommunityNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<Community> createCommunity({
    required String name,
    required String description,
    required String categoryId,
    String? coverImage,
    String joinType = 'open',
  }) async {
    state = const AsyncValue.loading();
    try {
      final community = await _service.createCommunity(
        name: name,
        description: description,
        categoryId: categoryId,
        coverImage: coverImage,
        joinType: joinType,
      );
      state = AsyncValue.data(community);
      // ✅ Creator is automatically a member AND is the creator
      await _ref.read(sessionProvider.notifier).createCommunity(community.id);
      // ✅ Also mark as joined (since creator is a member)
      await _ref.read(sessionProvider.notifier).joinCommunity(community.id);
      // ✅ Refresh list
      _ref.invalidate(communitiesProvider);
      return community;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// ─── Community posts ──────────────────────────────────────────
final communityPostsProvider =
    FutureProvider.family<PostListResponse, PostPaginationParams>(
        (ref, params) async {
  return ref.watch(communityPostServiceProvider).getCommunityPosts(
        communityId: params.communityId,
        page: params.page,
        perPage: params.perPage,
      );
});

// ─── Post comments ────────────────────────────────────────────
final postCommentsProvider =
    FutureProvider.family<CommentsListResponse, CommentPaginationParams>(
        (ref, params) async {
  return ref.watch(communityPostServiceProvider).getPostComments(
        postId: params.postId,
        page: params.page,
        perPage: params.perPage,
      );
});

// ─── Post operations ──────────────────────────────────────────
final postOperationsProvider =
    StateNotifierProvider<PostOperationsNotifier, AsyncValue<void>>(
  (ref) => PostOperationsNotifier(ref.watch(communityPostServiceProvider), ref),
);

class PostOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final CommunityPostService _service;
  final Ref _ref;

  PostOperationsNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createPost({
    required String communityId,
    required String title,
    required String body,
    bool isPinned = false,
    File? imageFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.createPost(
        communityId: communityId,
        title: title,
        body: body,
        contentType: 'post',
        isPinned: isPinned,
        imageFile: imageFile,
      );
      _ref.invalidate(communityPostsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updatePost({
    required String communityId,
    required String postId,
    required String title,
    required String body,
    bool? isPinned,
    File? imageFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.updatePost(
        communityId: communityId,
        postId: postId,
        title: title,
        body: body,
        isPinned: isPinned,
        imageFile: imageFile,
      );
      _ref.invalidate(communityPostsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deletePost({
    required String communityId,
    required String postId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.deletePost(communityId: communityId, postId: postId);
      _ref.invalidate(communityPostsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addComment(
      {required String postId, required String body}) async {
    state = const AsyncValue.loading();
    try {
      await _service.addComment(postId: postId, body: body);
      _ref.invalidate(postCommentsProvider(
        CommentPaginationParams(postId: postId),
      ));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteComment(postId: postId, commentId: commentId);
      _ref.invalidate(postCommentsProvider(
        CommentPaginationParams(postId: postId),
      ));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> reactToPost({required String postId}) async {
    state = const AsyncValue.loading();
    try {
      await _service.reactToPost(postId: postId, type: 'like');
      _ref.invalidate(communityPostsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

// ─── Parameter classes ────────────────────────────────────────
class CommunityPaginationParams {
  final int page;
  final int perPage;

  const CommunityPaginationParams({this.page = 1, this.perPage = 10});

  @override
  bool operator ==(Object other) =>
      other is CommunityPaginationParams &&
      page == other.page &&
      perPage == other.perPage;

  @override
  int get hashCode => page.hashCode ^ perPage.hashCode;
}

class CommunityMembersPaginationParams {
  final String communityId;
  final int page;
  final int perPage;

  const CommunityMembersPaginationParams({
    required this.communityId,
    this.page = 1,
    this.perPage = 10,
  });

  @override
  bool operator ==(Object other) =>
      other is CommunityMembersPaginationParams &&
      communityId == other.communityId &&
      page == other.page &&
      perPage == other.perPage;

  @override
  int get hashCode => communityId.hashCode ^ page.hashCode ^ perPage.hashCode;
}

class PostPaginationParams {
  final String communityId;
  final int page;
  final int perPage;

  const PostPaginationParams({
    required this.communityId,
    this.page = 1,
    this.perPage = 10,
  });

  @override
  bool operator ==(Object other) =>
      other is PostPaginationParams &&
      communityId == other.communityId &&
      page == other.page &&
      perPage == other.perPage;

  @override
  int get hashCode => communityId.hashCode ^ page.hashCode ^ perPage.hashCode;
}

class CommentPaginationParams {
  final String postId;
  final int page;
  final int perPage;

  const CommentPaginationParams({
    required this.postId,
    this.page = 1,
    this.perPage = 10,
  });

  @override
  bool operator ==(Object other) =>
      other is CommentPaginationParams &&
      postId == other.postId &&
      page == other.page &&
      perPage == other.perPage;

  @override
  int get hashCode => postId.hashCode ^ page.hashCode ^ perPage.hashCode;
}
