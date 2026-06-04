import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/media_upload_model.dart';

/// Service for handling media uploads (images) to the API
/// Supports uploading images for different contexts (avatar, post)
class MediaService {
  static const String _mediaEndpoint = '/media/upload';
  static const List<String> _allowedFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'gif'
  ];
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB

  final Dio _dio;
  final ImagePicker _imagePicker;

  MediaService({
    Dio? dio,
    ImagePicker? imagePicker,
  })  : _dio = dio ?? Dio(),
        _imagePicker = imagePicker ?? ImagePicker();

  /// Pick an image from the device gallery
  /// Returns null if no image is selected
  Future<XFile?> pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress to 85% quality
      );
      return pickedFile;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick an image from the device camera
  /// Returns null if no image is captured
  Future<XFile?> pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return pickedFile;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Validate image file before upload
  /// Checks format, file size, and file existence
  /// Returns error message if validation fails, null if valid
  String? validateImageFile(XFile imageFile) {
    // Check file format
    final fileExtension = imageFile.path.split('.').last.toLowerCase();
    if (!_allowedFormats.contains(fileExtension)) {
      return 'Invalid image format. Allowed: ${_allowedFormats.join(', ')}';
    }

    // Check file size (basic check using path)
    final file = File(imageFile.path);
    if (!file.existsSync()) {
      return 'Image file not found';
    }

    // For accurate size check, we'd need to read the file
    // This is done during upload
    return null; // Valid
  }

  /// Upload image to the API
  /// [imageFile] - The image file to upload (from image_picker)
  /// [context] - The context for storage path (avatar or post)
  /// [userId] - Deprecated; the media API only accepts file and context.
  /// Returns [MediaUploadResponse] with upload result
  Future<MediaUploadResponse> uploadImage({
    required XFile imageFile,
    required MediaContext context,
    String? userId,
  }) async {
    try {
      // Validate image file
      final validationError = validateImageFile(imageFile);
      if (validationError != null) {
        return MediaUploadResponse(
          success: false,
          message: validationError,
          status: 400,
        );
      }

      // Create multipart form data
      final formData = FormData();

      // Add the image file
      final file = File(imageFile.path);
      final fileSize = await file.length();

      // Check file size (5MB max)
      if (fileSize > _maxFileSizeBytes) {
        return MediaUploadResponse(
          success: false,
          message: 'File size exceeds 5MB limit',
          status: 400,
        );
      }

      formData.files.add(
        MapEntry(
          'file',
          MultipartFile.fromFileSync(
            imageFile.path,
            filename: imageFile.name,
          ),
        ),
      );

      // Add context parameter
      formData.fields.add(
        MapEntry('context', context.toApiValue()),
      );

      // Make the API call
      final response = await _dio.post<Map<String, dynamic>>(
        _mediaEndpoint,
        data: formData,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Parse response
      if (response.statusCode == 201 && response.data != null) {
        final uploadResponse = MediaUploadResponse.fromJson(response.data!);
        return uploadResponse;
      } else if (response.statusCode == 200 && response.data != null) {
        // Handle 200 status as well (some APIs return 200 instead of 201)
        final responseData = response.data!;
        return MediaUploadResponse.fromJson({
          ...responseData,
          'status': 200,
        });
      } else {
        return MediaUploadResponse(
          success: false,
          message: _extractErrorMessage(response.data),
          status: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      return MediaUploadResponse(
        success: false,
        message: e.message ?? 'Network error during upload',
        status: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      return MediaUploadResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
        status: 500,
      );
    }
  }

  /// Upload multiple images
  /// Returns list of upload responses
  Future<List<MediaUploadResponse>> uploadMultipleImages({
    required List<XFile> imageFiles,
    required MediaContext context,
    String? userId,
  }) async {
    final responses = <MediaUploadResponse>[];

    for (final imageFile in imageFiles) {
      final response = await uploadImage(
        imageFile: imageFile,
        context: context,
        userId: userId,
      );
      responses.add(response);
    }

    return responses;
  }

  /// Utility method to get image from gallery and upload directly
  /// This combines image selection and upload in one call
  Future<MediaUploadResponse> pickAndUploadImage({
    required MediaContext context,
    String? userId,
    bool useCamera = false,
  }) async {
    try {
      // Pick image
      final imageFile = useCamera
          ? await pickImageFromCamera()
          : await pickImageFromGallery();

      if (imageFile == null) {
        return MediaUploadResponse(
          success: false,
          message: 'No image selected',
          status: 400,
        );
      }

      // Upload the image
      return await uploadImage(
        imageFile: imageFile,
        context: context,
        userId: userId,
      );
    } catch (e) {
      return MediaUploadResponse(
        success: false,
        message: 'Error during image selection: $e',
        status: 500,
      );
    }
  }

  String _extractErrorMessage(Map<String, dynamic>? data) {
    if (data == null) return 'Upload failed';

    final errors = _fieldErrorMessage(data['errors']);
    if (errors != null) return errors;

    final details = _fieldErrorMessage(data['details']);
    if (details != null) return details;

    final error = data['error'];
    if (error is Map<String, dynamic>) {
      final errorDetails = _fieldErrorMessage(error['details']);
      if (errorDetails != null) return errorDetails;

      final errorMessage = error['message'];
      if (errorMessage != null) return errorMessage.toString();
    }

    final message = data['message'];
    return message?.toString() ?? 'Upload failed';
  }

  String? _fieldErrorMessage(Object? value) {
    if (value is! Map || value.isEmpty) return null;

    final messages = <String>[];
    for (final entry in value.entries) {
      final fieldValue = entry.value;
      if (fieldValue is List && fieldValue.isNotEmpty) {
        messages.add('${entry.key}: ${fieldValue.join(', ')}');
      } else if (fieldValue != null) {
        messages.add('${entry.key}: $fieldValue');
      }
    }

    return messages.isEmpty ? null : messages.join('\n');
  }
}
