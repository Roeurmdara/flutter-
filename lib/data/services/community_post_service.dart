import 'dart:io';

import 'package:dio/dio.dart';
import '../../core/exceptions/api_exception.dart';
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
        throw ApiException(response.statusCode, response.data);
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
    File? imageFile,
  }) async {
    try {
      final imageUrl =
          imageFile == null ? null : await _uploadPostImage(imageFile);
      final response = await dioClient.post(
        '/communities/$communityId/posts',
        data: {
          'title': title,
          'body': body,
          'content_type': contentType,
          'is_pinned': isPinned,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      // Validate response status
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return CommunityPost.fromJson(
              responseData['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Invalid response structure from server');
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to create post: $errorMessage');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to extract error message from API response
  String _extractErrorMessage(Response response) {
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('error')) {
          final error = data['error'];
          if (error is Map<String, dynamic>) {
            final details = error['details'];
            if (details is Map<String, dynamic>) {
              final messages = <String>[];
              for (final entry in details.entries) {
                final value = entry.value;
                if (value is List && value.isNotEmpty) {
                  messages.add('${entry.key}: ${value.join(', ')}');
                } else if (value != null) {
                  messages.add('${entry.key}: $value');
                }
              }
              if (messages.isNotEmpty) return messages.join('\n');
            }
            if (error.containsKey('message')) {
              return error['message'] as String;
            }
          }
        }
        if (data.containsKey('message')) {
          return data['message'] as String;
        }
      }
    } catch (e) {
      // Ignore error extraction errors
    }
    return 'Unknown error (HTTP ${response.statusCode})';
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

      // Validate response status
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return CommunityPost.fromJson(
              responseData['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Invalid response structure from server');
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to fetch post: $errorMessage');
      }
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
    File? imageFile,
  }) async {
    try {
      final imageUrl =
          imageFile == null ? null : await _uploadPostImage(imageFile);
      final data = <String, dynamic>{
        'title': title,
        'body': body,
        if (imageUrl != null) 'image_url': imageUrl,
      };
      if (isPinned != null) {
        data['is_pinned'] = isPinned.toString();
      }

      final response = await dioClient.put(
        '/communities/$communityId/posts/$postId',
        data: data,
      );

      // Validate response status
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          return CommunityPost.fromJson(
              responseData['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Invalid response structure from server');
        }
      } else {
        final errorMessage = _extractErrorMessage(response);
        throw Exception('Failed to update post: $errorMessage');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _uploadPostImage(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      'context': 'post',
    });

    final response = await dioClient.dio.post(
      '/media/upload',
      data: form,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300 &&
        response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        final url = payload['url']?.toString().trim();
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
    }

    throw Exception(
        'Failed to upload post image: ${_extractErrorMessage(response)}');
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
      // List comments using GET with query parameters only.
      // POST to this endpoint is for creating comments (requires 'body' field).
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
          // Server expects only the comment body in the POST payload.
          'body': body,
        },
      );
      // Validate status code
      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            'Failed to add comment: HTTP ${response.statusCode} - ${response.statusMessage} - ${response.data}');
      }

      // Support responses where created comment is either the direct data object or wrapped under 'data'
      final respData =
          response.data is Map && (response.data as Map).containsKey('data')
              ? (response.data as Map)['data']
              : response.data;

      if (respData is Map<String, dynamic>) {
        return CommunityPostComment.fromJson(respData);
      } else {
        throw Exception(
            'Unexpected response shape when adding comment: ${response.data}');
      }
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
      // Some servers require the comment UUID in the path and/or body.
      final response = await dioClient.delete(
        '/posts/$postId/comments/$commentId',
        data: {
          'comment_uuid': commentId,
          'commentUuid': commentId,
          'comment_id': commentId,
        },
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw Exception(
            'Failed to delete comment: HTTP ${response.statusCode} - ${response.statusMessage} - ${response.data}');
      }

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
