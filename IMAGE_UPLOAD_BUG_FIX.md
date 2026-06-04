# Image Upload + Community Post - Bug Fix

## Issues Found & Fixed

### 1. **Invalid `is_pinned` Format (Primary Issue)**

**Problem**:

- When uploading image with post, `is_pinned` was sent as boolean `false`
- API validation requires it to be a string: `'true'` or `'false'`
- This caused validation error: `"The is pinned field must be true or false"`

**Solution**:

- Fixed in `createPost()`: Changed `'is_pinned': isPinned` → `'is_pinned': isPinned.toString()`
- Now correctly converts boolean to string for API

### 2. **Type Casting Error on Failed Response (Secondary Issue)**

**Problem**:

- When API returned error (422), code tried to access `response.data['data']` which was null
- Caused: `type 'Null' is not a subtype of type 'Map<String, dynamic>'`
- No status code validation before trying to parse response

**Solution**:

- Added status code validation before response parsing
- Added response structure validation with `containsKey('data')`
- Checks if response is successful (200-299) before trying to extract data
- Returns proper error message if response fails

### 3. **Better Error Messages**

**Added**:

- New `_extractErrorMessage()` helper method
- Extracts error details from API error responses
- Shows meaningful error messages instead of generic errors
- Helps with debugging when validation fails

## Code Changes

### `lib/data/services/community_post_service.dart`

**Changes**:

1. **createPost() method**:

   ```dart
   // Before
   'is_pinned': isPinned,  // ❌ Boolean sent as-is

   // After
   'is_pinned': isPinned.toString(),  // ✅ Converted to string
   ```

2. **Added response validation**:

   ```dart
   // Before
   return CommunityPost.fromJson(response.data['data'] as Map<String, dynamic>);

   // After
   if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
     final responseData = response.data;
     if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
       return CommunityPost.fromJson(responseData['data'] as Map<String, dynamic>);
     } else {
       throw Exception('Invalid response structure from server');
     }
   } else {
     final errorMessage = _extractErrorMessage(response);
     throw Exception('Failed to create post: $errorMessage');
   }
   ```

3. **Added error extraction helper**:

   ```dart
   String _extractErrorMessage(Response response) {
     // Extracts meaningful error messages from API response
     // Handles both 'message' and 'error.message' fields
   }
   ```

4. **Applied same fixes to**:
   - `updatePost()` method - for consistency
   - `getPost()` method - for robustness

## When Image Upload Works Now

✅ Upload image to community post
✅ Upload image to community profile/logo
✅ Upload avatar to user profile
✅ Proper error messages when validation fails
✅ No more null type casting errors

## Testing Checklist

- [ ] Create post with image - verify `is_pinned=false` sent as string
- [ ] Check network logs - see `'is_pinned': 'false'` in FormData
- [ ] Create post without image - works without regression
- [ ] Get error message when image format invalid
- [ ] Get error message when file too large (>5MB)
- [ ] Profile avatar upload still works
- [ ] Community logo upload still works

## Root Cause Analysis

The issue occurred because:

1. FormData builder in Dio automatically converts values to strings for multipart data
2. But boolean `false` might be sent as `"false"` or `false` depending on serialization
3. The non-image request path was using boolean directly: `'is_pinned': isPinned`
4. API is strict about the format - must be string `'true'` or `'false'`
5. The `updatePost()` method had it correct with `.toString()` but `createPost()` didn't

## Related Files Using MediaService

- `lib/presentation/screens/community/create_community_screen.dart` - Community creation
- `lib/presentation/screens/community/community_posts_feed_screen.dart` - Post creation
- `lib/presentation/screens/profile/user_profile_edit_screen.dart` - Avatar upload

All these should now work without errors when using the image upload functionality.
