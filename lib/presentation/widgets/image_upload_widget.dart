import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/media_provider.dart';
import '../../data/models/media_upload_model.dart';

/// Callback function when image is successfully uploaded
typedef OnImageUploaded = Function(String imageUrl, String imagePath);

/// Image upload widget that handles picking and uploading images
/// Can be used for profile avatars or community post images
class ImageUploadWidget extends ConsumerStatefulWidget {
  final MediaContext uploadContext;
  final String? userId;
  final OnImageUploaded? onImageUploaded;
  final VoidCallback? onError;
  final bool useCamera;
  final String? initialImageUrl;
  final double? width;
  final double? height;
  final BoxShape shape;
  final String? label;

  const ImageUploadWidget({
    super.key,
    required this.uploadContext,
    this.userId,
    this.onImageUploaded,
    this.onError,
    this.useCamera = false,
    this.initialImageUrl,
    this.width = 120,
    this.height = 120,
    this.shape = BoxShape.circle,
    this.label,
  });

  @override
  ConsumerState<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends ConsumerState<ImageUploadWidget> {
  Future<void> _handleImageUpload(bool useCamera) async {
    try {
      final response =
          await ref.read(mediaUploadProvider.notifier).pickAndUploadImage(
                context: widget.uploadContext,
                userId: widget.userId,
                useCamera: useCamera,
              );

      if (response.success && response.data != null) {
        // Call the callback with the uploaded image URL and path
        widget.onImageUploaded?.call(response.data!.url, response.data!.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        widget.onError?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      widget.onError?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: const Text('Choose where to upload image from:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleImageUpload(false); // Gallery
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleImageUpload(true); // Camera
            },
            child: const Text('Camera'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(mediaUploadProvider);

    return Stack(
      children: [
        // Main image container
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            color: Colors.grey[200],
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: widget.initialImageUrl != null
              ? ClipRRect(
                  borderRadius: widget.shape == BoxShape.circle
                      ? BorderRadius.circular(100)
                      : BorderRadius.zero,
                  child: Image.network(
                    widget.initialImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
        ),

        // Upload button overlay
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // Loading indicator
        if (uploadState.isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: widget.shape,
                color: Colors.black26,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: uploadState.uploadProgress > 0
                      ? uploadState.uploadProgress
                      : null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Simple image upload button widget
class ImageUploadButton extends ConsumerWidget {
  final MediaContext uploadContext;
  final String? userId;
  final OnImageUploaded? onImageUploaded;
  final String? buttonText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ImageUploadButton({
    super.key,
    required this.uploadContext,
    this.userId,
    this.onImageUploaded,
    this.buttonText = 'Upload Image',
    this.icon = Icons.image,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(mediaUploadProvider);

    return ElevatedButton.icon(
      onPressed: uploadState.isUploading
          ? null
          : () async {
              final response = await ref
                  .read(mediaUploadProvider.notifier)
                  .pickAndUploadImage(
                    context: uploadContext,
                    userId: userId,
                    useCamera: false,
                  );

              if (response.success && response.data != null) {
                onImageUploaded?.call(response.data!.url, response.data!.path);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image uploaded successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
      icon: uploadState.isUploading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(foregroundColor),
              ),
            )
          : Icon(icon),
      label: Text(uploadState.isUploading
          ? 'Uploading...'
          : (buttonText ?? 'Upload Image')),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}
