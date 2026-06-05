// Media Upload Response Model
class MediaUploadData {
  final String url;
  final String path;

  MediaUploadData({
    required this.url,
    required this.path,
  });

  factory MediaUploadData.fromJson(Map<String, dynamic> json) {
    return MediaUploadData(
      url: _stringValue(json['url']) ?? '',
      path: _stringValue(json['path']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'path': path,
    };
  }

  MediaUploadData copyWith({
    String? url,
    String? path,
  }) {
    return MediaUploadData(
      url: url ?? this.url,
      path: path ?? this.path,
    );
  }
}

String? _stringValue(Object? value) {
  if (value is String) return value;
  return null;
}

class MediaUploadResponse {
  final bool success;
  final String message;
  final int status;
  final MediaUploadData? data;
  final String? timestamp;
  final String? traceId;
  final String? path;

  MediaUploadResponse({
    required this.success,
    required this.message,
    required this.status,
    this.data,
    this.timestamp,
    this.traceId,
    this.path,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      data: json['data'] != null
          ? MediaUploadData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      timestamp: json['timestamp'] as String?,
      traceId: json['traceId'] as String?,
      path: json['path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      if (data != null) 'data': data!.toJson(),
      if (timestamp != null) 'timestamp': timestamp,
      if (traceId != null) 'traceId': traceId,
      if (path != null) 'path': path,
    };
  }

  MediaUploadResponse copyWith({
    bool? success,
    String? message,
    int? status,
    MediaUploadData? data,
    String? timestamp,
    String? traceId,
    String? path,
  }) {
    return MediaUploadResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      status: status ?? this.status,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      traceId: traceId ?? this.traceId,
      path: path ?? this.path,
    );
  }
}

// Image upload context enum
enum MediaContext {
  avatar, // For profile picture uploads
  post, // For images attached to community posts
  community; // For community cover images

  String toApiValue() {
    return switch (this) {
      MediaContext.avatar => 'avatar',
      MediaContext.post => 'post',
      // The media API currently accepts only avatar/post. Community covers use
      // the avatar bucket and the returned URL is saved on the community.
      MediaContext.community => 'avatar',
    };
  }
}
