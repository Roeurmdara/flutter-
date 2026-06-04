import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/media_service.dart';
import '../models/media_upload_model.dart';
import '../services/dio_client.dart';

/// State for media upload operations
class MediaUploadState {
  final MediaUploadResponse? lastUploadResponse;
  final bool isUploading;
  final String? error;
  final double uploadProgress; // 0.0 to 1.0

  const MediaUploadState({
    this.lastUploadResponse,
    this.isUploading = false,
    this.error,
    this.uploadProgress = 0.0,
  });

  bool get isSuccess =>
      lastUploadResponse != null && lastUploadResponse!.success;

  String? get uploadedImageUrl => lastUploadResponse?.data?.url;

  String? get uploadedImagePath => lastUploadResponse?.data?.path;

  MediaUploadState copyWith({
    MediaUploadResponse? lastUploadResponse,
    bool? isUploading,
    String? error,
    double? uploadProgress,
  }) {
    return MediaUploadState(
      lastUploadResponse: lastUploadResponse ?? this.lastUploadResponse,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  void clearError() {
    // Error is cleared by creating a new state with error = null
  }
}

/// Notifier for managing media upload state
class MediaUploadNotifier extends StateNotifier<MediaUploadState> {
  final MediaService _mediaService;

  MediaUploadNotifier(this._mediaService) : super(const MediaUploadState());

  /// Upload a single image
  Future<MediaUploadResponse> uploadImage({
    required dynamic imageFile, // XFile type
    required MediaContext context,
    String? userId,
  }) async {
    state = state.copyWith(
      isUploading: true,
      error: null,
      uploadProgress: 0.0,
    );

    try {
      final response = await _mediaService.uploadImage(
        imageFile: imageFile,
        context: context,
        userId: userId,
      );

      state = state.copyWith(
        isUploading: false,
        lastUploadResponse: response,
        uploadProgress: response.success ? 1.0 : 0.0,
        error: response.success ? null : response.message,
      );

      return response;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
        uploadProgress: 0.0,
      );

      return MediaUploadResponse(
        success: false,
        message: e.toString(),
        status: 500,
      );
    }
  }

  /// Pick and upload image in one operation
  Future<MediaUploadResponse> pickAndUploadImage({
    required MediaContext context,
    String? userId,
    bool useCamera = false,
  }) async {
    state = state.copyWith(
      isUploading: true,
      error: null,
      uploadProgress: 0.0,
    );

    try {
      final response = await _mediaService.pickAndUploadImage(
        context: context,
        userId: userId,
        useCamera: useCamera,
      );

      state = state.copyWith(
        isUploading: false,
        lastUploadResponse: response,
        uploadProgress: response.success ? 1.0 : 0.0,
        error: response.success ? null : response.message,
      );

      return response;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
        uploadProgress: 0.0,
      );

      return MediaUploadResponse(
        success: false,
        message: e.toString(),
        status: 500,
      );
    }
  }

  /// Clear upload error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset upload state
  void reset() {
    state = const MediaUploadState();
  }

  /// Set upload progress (for future implementation with progress tracking)
  void setProgress(double progress) {
    state = state.copyWith(uploadProgress: progress);
  }
}

/// Provider for DioClient
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Provider for MediaService
final mediaServiceProvider = Provider<MediaService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MediaService(dio: dioClient.dio);
});

/// StateNotifier Provider for MediaUploadState
final mediaUploadProvider =
    StateNotifierProvider<MediaUploadNotifier, MediaUploadState>((ref) {
  final mediaService = ref.watch(mediaServiceProvider);
  return MediaUploadNotifier(mediaService);
});
