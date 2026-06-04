# Image Upload Implementation - Complete Guide

## Overview

This implementation provides a complete image upload system for your Flutter app with support for:

- Profile picture uploads (avatar context)
- Community post image uploads (post context)
- Community logo/banner uploads
- Multiple image formats (jpg, jpeg, png, webp, gif)
- File size validation (max 5MB)
- Progress tracking and error handling

## Files Created

### 1. Models (`lib/data/models/media_upload_model.dart`)

**Purpose**: Define data structures for API requests/responses

**Key Classes**:

- `MediaUploadData`: Contains uploaded image URL and path
- `MediaUploadResponse`: Complete API response wrapper
- `MediaContext`: Enum for upload context (avatar or post)

**Usage**:

```dart
final response = MediaUploadResponse.fromJson(apiData);
final imageUrl = response.data?.url;
final imagePath = response.data?.path;
```

### 2. Service (`lib/data/services/media_service.dart`)

**Purpose**: Handle all image picking and uploading logic

**Key Methods**:

- `pickImageFromGallery()`: Opens device gallery
- `pickImageFromCamera()`: Opens device camera
- `validateImageFile()`: Validates format, size, and existence
- `uploadImage()`: Uploads single image with context
- `uploadMultipleImages()`: Batch upload multiple images
- `pickAndUploadImage()`: Combined pick + upload operation

**Example**:

```dart
final response = await mediaService.uploadImage(
  imageFile: pickedFile,
  context: MediaContext.avatar,
);

if (response.success) {
  print('Uploaded to: ${response.data?.url}');
}
```

### 3. Provider (`lib/data/providers/media_provider.dart`)

**Purpose**: Manage upload state using Riverpod

**Key Classes**:

- `MediaUploadState`: Tracks upload state (loading, error, progress)
- `MediaUploadNotifier`: State management logic
- `mediaUploadProvider`: Provider for accessing state
- `mediaServiceProvider`: Provider for MediaService

**Usage**:

```dart
// Watch state in widget
final uploadState = ref.watch(mediaUploadProvider);

// Upload image
final response = await ref.read(mediaUploadProvider.notifier).uploadImage(
  imageFile: file,
  context: MediaContext.avatar,
);
```

### 4. Widgets (`lib/presentation/widgets/image_upload_widget.dart`)

**Purpose**: Pre-built UI components for image upload

**Widgets**:

#### a) ImageUploadWidget

Circular/rectangular container with camera overlay button

- Shows initial image if provided
- Click camera button to pick/upload
- Shows loading spinner during upload
- Customizable size and shape

**Usage**:

```dart
ImageUploadWidget(
  uploadContext: MediaContext.avatar,
  initialImageUrl: currentAvatarUrl,
  width: 120,
  height: 120,
  shape: BoxShape.circle,
  onImageUploaded: (url, path) {
    // Handle uploaded image
  },
)
```

#### b) ImageUploadButton

Simple ElevatedButton for image upload

- Shows loading state
- Displays upload success/error messages
- Compact button style

**Usage**:

```dart
ImageUploadButton(
  uploadContext: MediaContext.post,
  buttonText: 'Upload Post Image',
  onImageUploaded: (url, path) {
    // Handle uploaded image
  },
)
```

### 5. Implementation Guide (`IMAGE_UPLOAD_IMPLEMENTATION_GUIDE.dart`)

**Purpose**: Complete examples for all use cases

**Includes**:

- User Profile - Avatar upload
- Create Community - Logo/banner upload
- Create Post - Post image upload
- Advanced usage with direct service calls
- API integration notes

## How to Use

### Quick Start (User Profile Avatar)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/widgets/image_upload_widget.dart';
import 'data/models/media_upload_model.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  String? _avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ImageUploadWidget(
        uploadContext: MediaContext.avatar,
        initialImageUrl: _avatarUrl,
        onImageUploaded: (url, path) {
          setState(() => _avatarUrl = url);
          // Save to API
        },
      ),
    );
  }
}
```

### Post Image Upload

```dart
ImageUploadButton(
  uploadContext: MediaContext.post,
  userId: communityId,
  buttonText: 'Add Image to Post',
  onImageUploaded: (imageUrl, imagePath) {
    // Store imageUrl to include in post creation
  },
)
```

### Advanced - Direct Service Usage

```dart
final mediaService = ref.read(mediaServiceProvider);

// Pick image
final imageFile = await mediaService.pickImageFromGallery();

// Validate
final error = mediaService.validateImageFile(imageFile);
if (error != null) {
  print('Invalid: $error');
  return;
}

// Upload with context
final response = await mediaService.uploadImage(
  imageFile: imageFile,
  context: MediaContext.post,
  userId: postAuthorId,
);
```

## API Endpoint Details

**URL**: `https://habit-api.rattanakmony.com/api/v1/media/upload`

**Request Format**: `multipart/form-data`

**Fields**:
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| file | File | Yes | Image file (jpg, jpeg, png, webp, gif) |
| context | String | Yes | 'avatar' or 'post' |
| user_id | String | No | Required for post context (community ID) |

**Success Response (201)**:

```json
{
  "success": true,
  "message": "Resource created successfully.",
  "status": 201,
  "data": {
    "url": "https://habit-api.rattanakmony.com/storage/posts/...",
    "path": "posts/..."
  },
  "timestamp": "2026-06-02T16:35:31.406995Z",
  "traceId": "..."
}
```

**Error Response**:

```json
{
  "success": false,
  "message": "Error message",
  "status": 400
}
```

## File Size & Format Validation

**Allowed Formats**: jpg, jpeg, png, webp, gif

**Max File Size**: 5MB

**Validation is performed**:

1. At client level (format check)
2. Before upload (size check)
3. Server will also validate

## Dependencies

All required dependencies are already in `pubspec.yaml`:

- `image_picker: ^1.1.0` - For image selection
- `dio: ^5.4.1` - For HTTP requests
- `flutter_riverpod: ^2.5.1` - For state management

## State Management

The provider automatically handles:

- Loading state during upload
- Upload progress (0.0 to 1.0)
- Success/error messages
- Last upload response

**Access state**:

```dart
final state = ref.watch(mediaUploadProvider);

state.isUploading        // true/false
state.uploadProgress     // 0.0 to 1.0
state.uploadedImageUrl   // URL if successful
state.error              // Error message if failed
state.isSuccess          // Convenience getter
```

## Error Handling

All errors are automatically handled:

- Invalid file format → Error message
- File not found → Error message
- Network errors → Descriptive message
- Server errors → API response message

**Custom error handling**:

```dart
if (response.success) {
  // Success
  final url = response.data?.url;
} else {
  // Error
  print('Upload failed: ${response.message}');
  print('Status: ${response.status}');
}
```

## Customization

### Custom Widget Styling

```dart
ImageUploadWidget(
  uploadContext: MediaContext.avatar,
  width: 150,
  height: 150,
  shape: BoxShape.rectangle, // or circle
  label: 'Custom Label',
  // ... other properties
)
```

### Custom Upload Handler

```dart
final mediaService = ref.read(mediaServiceProvider);
final customResponse = await mediaService.uploadImage(
  imageFile: imageFile,
  context: MediaContext.post,
  userId: 'custom-user-id',
);
```

## Security Notes

✅ **Implemented**:

- Bearer token automatically added via DioClient
- File format validation
- File size validation
- Secure storage integration

✅ **Best Practices**:

- All auth headers handled automatically
- Images compressed to 85% quality
- MultipartFile used for efficient upload
- Error messages don't expose sensitive data

## Integration Checklist

- [x] Add files to project
- [ ] Import widgets in screens
- [ ] Set up `onImageUploaded` callbacks
- [ ] Test with profile upload
- [ ] Test with community post upload
- [ ] Test with community creation
- [ ] Verify images appear on API responses
- [ ] Test error cases (invalid format, large file, etc.)

## Common Issues & Solutions

**Issue**: Image not uploading

- Check network connectivity
- Verify API endpoint is accessible
- Check auth token is valid

**Issue**: Image format error

- Ensure image is jpg, jpeg, png, webp, or gif
- Check file actually has correct extension

**Issue**: File size error

- Ensure file is under 5MB
- App compresses images to 85% quality automatically

**Issue**: Image picker not opening

- Check permissions in AndroidManifest.xml
- Check iOS permissions in Info.plist
- Already configured: `permission_handler` dependency included

## Next Steps

1. **Test file upload**: Run app and test avatar upload
2. **Integrate with screens**: Add to profile, community, post screens
3. **Connect to save**: Trigger API save after successful upload
4. **Add image gallery**: Display uploaded images in user profiles
5. **Monitor progress**: Track upload progress for large files (optional)

---

**API Docs**: https://habit-api.rattanakmony.com/api/v1/media/upload
**Created**: June 2, 2026
