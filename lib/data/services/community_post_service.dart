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
  /// Create a new post in a community. If [imageFile] is provided this will
  /// send multipart/form-data with the file attached under the 'media'
  /// field (adjust the field name if your API expects a different key).
  Future<CommunityPost> createPost({
    required String communityId,
    required String title,
    required String body,
    required String contentType,
    bool isPinned = false,
    File? imageFile,
  }) async {
    try {
      Response response;

      if (imageFile != null) {
        final fileName = imageFile.path.split(Platform.pathSeparator).last;
        final form = FormData.fromMap({
          'title': title,
          'body': body,
          'content_type': contentType,
          'is_pinned': isPinned ? '1' : '0',
          // API expects the file under the 'file' field (same as /media/upload)
          'file':
              await MultipartFile.fromFile(imageFile.path, filename: fileName),
        });

        response = await dioClient.dio.post(
          '/communities/$communityId/posts',
          data: form,
          options: Options(
            contentType: 'multipart/form-data',
            validateStatus: (status) => status != null && status < 500,
          ),
        );
      } else {
        response = await dioClient.post(
          '/communities/$communityId/posts',
          data: {
            'title': title,
            'body': body,
            'content_type': contentType,
            'is_pinned': isPinned,
          },
        );
      }

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
      Response response;

      if (imageFile != null) {
        final fileName = imageFile.path.split(Platform.pathSeparator).last;
        final form = FormData.fromMap({
          'title': title,
          'body': body,
          if (isPinned != null) 'is_pinned': isPinned ? '1' : '0',
          // Use 'file' key for multipart uploads so backend recognizes the file
          'file':
              await MultipartFile.fromFile(imageFile.path, filename: fileName),
        });

        response = await dioClient.dio.put(
          '/communities/$communityId/posts/$postId',
          data: form,
          options: Options(
            contentType: 'multipart/form-data',
            validateStatus: (status) => status != null && status < 500,
          ),
        );
      } else {
        final data = {
          'title': title,
          'body': body,
        };
        if (isPinned != null) {
          data['is_pinned'] = isPinned.toString();
        }

        response = await dioClient.put(
          '/communities/$communityId/posts/$postId',
          data: data,
        );
      }

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

      try {
        // ignore: avoid_print
        print(
            'getPostComments response => status:${response.statusCode} data:${response.data}');
      } catch (_) {}

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
      // Debug: log full response to help diagnose API shape / errors
      try {
        // ignore: avoid_print
        print(
            'addComment response => status:${response.statusCode} data:${response.data}');
      } catch (_) {}

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
        try {
          return CommunityPostComment.fromJson(respData);
        } catch (e, st) {
          // Detailed debug info to help trace parsing issues
          // ignore: avoid_print
          print('addComment parsing error: $e');
          // ignore: avoid_print
          print('respData: $respData');
          // ignore: avoid_print
          print(st);
          rethrow;
        }
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

      try {
        // ignore: avoid_print
        print(
            'deleteComment response => status:${response.statusCode} data:${response.data}');
      } catch (_) {}

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
