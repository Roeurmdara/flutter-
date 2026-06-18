import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/media_service.dart';
import '../models/media_upload_model.dart';
import 'core_providers.dart';

// Sentinel used by `copyWith` to differentiate between an omitted `error`
// parameter and an explicit `null` (which clears the error).
const _noError = Object();

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

  String? get uploadedImageUrl =>
      lastUploadResponse?.data?.url ?? lastUploadResponse?.path;

  String? get uploadedImagePath =>
      lastUploadResponse?.data?.path ?? lastUploadResponse?.path;

  MediaUploadState copyWith({
    MediaUploadResponse? lastUploadResponse,
    bool? isUploading,
    Object? error = _noError,
    double? uploadProgress,
  }) {
    return MediaUploadState(
      lastUploadResponse: lastUploadResponse ?? this.lastUploadResponse,
      isUploading: isUploading ?? this.isUploading,
      error: identical(error, _noError) ? this.error : error as String?,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  /// Return a new state with the error cleared.
  MediaUploadState clearError() => copyWith(error: null);
}

/// Notifier for managing media upload state
class MediaUploadNotifier extends StateNotifier<MediaUploadState> {
  final MediaService _mediaService;

  MediaUploadNotifier(this._mediaService) : super(const MediaUploadState());

  /// Upload a single image
  Future<MediaUploadResponse> uploadImage({
    required XFile imageFile,
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
    final p = (progress.clamp(0.0, 1.0) as num).toDouble();
    state = state.copyWith(uploadProgress: p);
  }
}

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
