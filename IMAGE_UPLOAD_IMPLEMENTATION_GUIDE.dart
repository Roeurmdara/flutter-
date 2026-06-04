// IMAGE UPLOAD IMPLEMENTATION GUIDE
// This guide shows how to integrate image upload functionality into:
// 1. Create Community Screen
// 2. Create Post in Community Screen
// 3. User Profile Screen

// ============================================================================
// EXAMPLE 1: USER PROFILE - Upload Avatar
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/widgets/image_upload_widget.dart';
import '../../data/models/media_upload_model.dart';

class UserProfileEditScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<UserProfileEditScreen> createState() =>
      _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends ConsumerState<UserProfileEditScreen> {
  String? _uploadedAvatarUrl;
  String? _uploadedAvatarPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar Upload Widget
            Center(
              child: ImageUploadWidget(
                uploadContext: MediaContext.avatar,
                initialImageUrl: _uploadedAvatarUrl,
                width: 120,
                height: 120,
                shape: BoxShape.circle,
                onImageUploaded: (imageUrl, imagePath) {
                  setState(() {
                    _uploadedAvatarUrl = imageUrl;
                    _uploadedAvatarPath = imagePath;
                  });
                  print('Avatar uploaded: $imageUrl');
                },
                onError: () {
                  print('Avatar upload failed');
                },
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Upload a profile picture',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),

            // Other profile fields...
            TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                maxLines: 3,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Save profile with uploaded avatar URL
                if (_uploadedAvatarUrl != null) {
                  print('Saving profile with avatar: $_uploadedAvatarUrl');
                }
              },
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: CREATE COMMUNITY - Upload Community Logo/Banner
// ============================================================================

class CreateCommunityScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  String? _communityLogoUrl;
  String? _communityLogoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Community')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Community Logo Upload
            Center(
              child: Column(
                children: [
                  ImageUploadWidget(
                    uploadContext: MediaContext.avatar,
                    initialImageUrl: _communityLogoUrl,
                    width: 150,
                    height: 150,
                    shape: BoxShape.rectangle,
                    label: 'Community Logo',
                    onImageUploaded: (imageUrl, imagePath) {
                      setState(() {
                        _communityLogoUrl = imageUrl;
                        _communityLogoPath = imagePath;
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload a community logo',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Community Details
            TextField(
              decoration: InputDecoration(
                labelText: 'Community Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Fitness Enthusiasts',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                maxLines: 4,
                hintText: 'Describe your community...',
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Create community with logo
                  if (_communityLogoUrl != null) {
                    print('Creating community with logo: $_communityLogoUrl');
                    // Call API to create community
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please upload a community logo')),
                    );
                  }
                },
                child: Text('Create Community'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: CREATE POST IN COMMUNITY - Upload Post Image
// ============================================================================

class CreateCommunityPostScreen extends ConsumerStatefulWidget {
  final String communityId;

  const CreateCommunityPostScreen({
    required this.communityId,
  });

  @override
  ConsumerState<CreateCommunityPostScreen> createState() =>
      _CreateCommunityPostScreenState();
}

class _CreateCommunityPostScreenState
    extends ConsumerState<CreateCommunityPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  String? _postImageUrl;
  String? _postImagePath;
  bool _isPosting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(mediaUploadProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s on your mind?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),

            // Caption input
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Write your post',
                border: OutlineInputBorder(),
                maxLines: 4,
                hintText: 'Share your thoughts...',
              ),
            ),
            SizedBox(height: 24),

            // Image upload section
            Text(
              'Add an Image (Optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),

            // Show uploaded image preview or upload widget
            if (_postImageUrl != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _postImageUrl!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _postImageUrl = null;
                        _postImagePath = null;
                      });
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Remove Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: ImageUploadButton(
                  uploadContext: MediaContext.post,
                  userId: widget.communityId,
                  buttonText: 'Upload Image',
                  onImageUploaded: (imageUrl, imagePath) {
                    setState(() {
                      _postImageUrl = imageUrl;
                      _postImagePath = imagePath;
                    });
                  },
                ),
              ),
            SizedBox(height: 24),

            // Post button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPosting || uploadState.isUploading
                    ? null
                    : () async {
                        if (_captionController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please write your post'),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isPosting = true;
                        });

                        try {
                          // Call API to create post
                          print('Creating post:');
                          print('Caption: ${_captionController.text}');
                          if (_postImageUrl != null) {
                            print('Image URL: $_postImageUrl');
                          }

                          // Example API call:
                          // await ref.read(communityPostServiceProvider).createPost(
                          //   communityId: widget.communityId,
                          //   caption: _captionController.text,
                          //   imageUrl: _postImageUrl,
                          // );

                          // Show success message
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Post created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Navigate back
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error creating post: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          setState(() {
                            _isPosting = false;
                          });
                        }
                      },
                child: _isPosting || uploadState.isUploading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ADVANCED EXAMPLE: Using MediaService Directly
// ============================================================================

class AdvancedImageUploadExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Get the media service
        final mediaService = ref.read(mediaServiceProvider);

        // Pick image from gallery
        final imageFile = await mediaService.pickImageFromGallery();
        if (imageFile == null) return;

        // Validate image
        final validationError = mediaService.validateImageFile(imageFile);
        if (validationError != null) {
          print('Validation error: $validationError');
          return;
        }

        // Upload image
        final response =
            await ref.read(mediaUploadProvider.notifier).uploadImage(
                  imageFile: imageFile,
                  context: MediaContext.avatar,
                );

        if (response.success) {
          print('Image uploaded: ${response.data?.url}');
        } else {
          print('Upload failed: ${response.message}');
        }
      },
      child: Text('Upload Image'),
    );
  }
}

// ============================================================================
// API INTEGRATION NOTES
// ============================================================================

/*
API Endpoint: https://habit-api.rattanakmony.com/api/v1/media/upload

Request:
- Method: POST (multipart/form-data)
- Fields:
  - file: The image file (max 5MB)
  - context: Either 'avatar' or 'post'
  - user_id: (Optional) User ID for post context

Supported Formats: jpg, jpeg, png, webp, gif

Response (Success - 201):
{
  "success": true,
  "message": "Resource created successfully.",
  "status": 201,
  "data": {
    "url": "https://habit-api.rattanakmony.com/storage/posts/019e4633-8a96-70a9-a749-ce1d2090933f/316850ff-1db2-4502-8550-2ce1bc543d70.png",
    "path": "posts/019e4633-8a96-70a9-a749-ce1d2090933f/316850ff-1db2-4502-8550-2ce1bc543d70.png"
  },
  "timestamp": "2026-06-02T16:35:31.406995Z",
  "traceId": "8b595b24-0be5-4c12-acbf-3af96c970675"
}

Response (Error):
{
  "success": false,
  "message": "Error message here",
  "status": 400
}
*/
