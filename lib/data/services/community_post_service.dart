import 'dio_client.dart';
import '../models/community_post_model.dart';

class CommunityPostService {
  final DioClient dioClient;

  CommunityPostService({required this.dioClient});

  // Get all posts in a community
  Future<PostListResponse> getCommunityPosts({
    required String communityId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await dioClient.get(
        '/communities/$communityId/posts',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      // Check status code
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return PostListResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to load posts: HTTP ${response.statusCode} - ${response.statusMessage}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Create a new post in a community
  Future<CommunityPost> createPost({
    required String communityId,
    required String title,
    required String body,
    required String contentType,
    bool isPinned = false,
  }) async {
    try {
      final response = await dioClient.post(
        '/communities/$communityId/posts',
        data: {
          'title': title,
          'body': body,
          'content_type': contentType,
          'is_pinned': isPinned,
        },
      );

      return CommunityPost.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Get a single post by ID
  Future<CommunityPost> getPost({
    required String communityId,
    required String postId,
  }) async {
    try {
      final response = await dioClient.get(
        '/communities/$communityId/posts/$postId',
      );

      return CommunityPost.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Update a post
  Future<CommunityPost> updatePost({
    required String communityId,
    required String postId,
    required String title,
    required String body,
    bool? isPinned,
  }) async {
    try {
      final data = {
        'title': title,
        'body': body,
      };
      if (isPinned != null) {
        data['is_pinned'] = isPinned.toString();
      }

      final response = await dioClient.put(
        '/communities/$communityId/posts/$postId',
        data: data,
      );

      return CommunityPost.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a post
  Future<bool> deletePost({
    required String communityId,
    required String postId,
  }) async {
    try {
      await dioClient.delete(
        '/communities/$communityId/posts/$postId',
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Get comments on a post
  Future<CommentsListResponse> getPostComments({
    required String postId,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await dioClient.get(
        '/posts/$postId/comments',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return CommentsListResponse.fromJson(
          response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Add a comment to a post
  Future<CommunityPostComment> addComment({
    required String postId,
    required String body,
  }) async {
    try {
      final response = await dioClient.post(
        '/posts/$postId/comments',
        data: {
          'body': body,
        },
      );

      return CommunityPostComment.fromJson(
          response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a comment
  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await dioClient.delete(
        '/posts/$postId/comments/$commentId',
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // React to a post
  Future<bool> reactToPost({
    required String postId,
    required String type,
  }) async {
    try {
      await dioClient.post(
        '/posts/$postId/react',
        data: {
          'type': type,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // React to a comment
  Future<bool> reactToComment({
    required String postId,
    required String commentId,
    required String type,
  }) async {
    try {
      await dioClient.post(
        '/posts/$postId/comments/$commentId/react',
        data: {
          'type': type,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
