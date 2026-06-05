import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

enum AppImageCropType {
  avatar,
  post,
}

class ImageCropHelper {
  const ImageCropHelper._();

  static Future<CroppedFile?> cropImage({
    required String imagePath,
    required AppImageCropType type,
  }) {
    final isAvatar = type == AppImageCropType.avatar;

    return ImageCropper().cropImage(
      sourcePath: imagePath,
      compressQuality: 90,
      maxWidth: isAvatar ? 900 : 1600,
      maxHeight: isAvatar ? 900 : 1600,
      aspectRatio:
          isAvatar ? const CropAspectRatio(ratioX: 1, ratioY: 1) : null,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isAvatar ? 'Crop profile photo' : 'Crop post image',
          toolbarColor: const Color(0xFF7C3AED),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF7C3AED),
          lockAspectRatio: isAvatar,
          cropStyle: isAvatar ? CropStyle.circle : CropStyle.rectangle,
          initAspectRatio: isAvatar
              ? CropAspectRatioPreset.square
              : CropAspectRatioPreset.original,
          aspectRatioPresets: isAvatar
              ? const [
                  CropAspectRatioPreset.square,
                ]
              : const [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
        ),
        IOSUiSettings(
          title: isAvatar ? 'Crop profile photo' : 'Crop post image',
          aspectRatioLockEnabled: isAvatar,
          resetAspectRatioEnabled: !isAvatar,
          cropStyle: isAvatar ? CropStyle.circle : CropStyle.rectangle,
          aspectRatioPresets: isAvatar
              ? const [
                  CropAspectRatioPreset.square,
                ]
              : const [
                  CropAspectRatioPreset.original,
                  CropAspectRatioPreset.square,
                  CropAspectRatioPreset.ratio4x3,
                  CropAspectRatioPreset.ratio16x9,
                ],
        ),
      ],
    );
  }
}
