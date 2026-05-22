# User Profile Implementation Guide

## Overview

This implementation adds complete user profile functionality to your Flutter Habit Tracker app, allowing users to:

- **View** their profile data (username, bio, avatar)
- **Edit** their profile information
- **Refresh** their profile data from the API
- **Error handling** with user-friendly messages

## API Integration

**Endpoint:** `https://habit-api.rattanakmony.com/api/v1/users/me`

### Requirements

- **Bearer Token:** Authentication requires a valid Bearer token in the `Authorization` header
- **Token Storage:** Store the auth token in `SharedPreferences` with key `'auth_token'` (typically done during login)

## Files Created/Modified

### 1. **Profile Model**

📄 `lib/data/models/profile_model.dart`

Defines the data structures for user profile:

- `UserProfile` - User profile data (username, avatarUrl, bio)
- `UserProfileUpdateRequest` - Request payload for profile updates
- `ProfileResponse` - API response wrapper

```dart
UserProfile(
  username: 'john_doe',
  avatarUrl: 'https://example.com/avatar.jpg',
  bio: 'Passionate about building better habits'
)
```

### 2. **Profile Service**

📄 `lib/data/services/profile_service.dart`

Handles all HTTP requests to the API:

- `getUserProfile()` - Fetches current user profile (GET /users/me)
- `updateUserProfile()` - Updates user profile (PUT /users/me)
- Token management and error handling

**Key Methods:**

```dart
void setAuthToken(String token)  // Set Bearer token
Future<ProfileResponse> getUserProfile()
Future<ProfileResponse> updateUserProfile({
  required String username,
  String? avatarUrl,
  String? bio,
})
```

### 3. **Profile Provider**

📄 `lib/data/providers/profile_provider.dart`

Riverpod state management for profile data:

- `profileProvider` - Manages profile state and notifications
- `ProfileState` - Holds loading, profile, error states
- `ProfileNotifier` - Handles fetch and update operations

**Usage:**

```dart
final profileState = ref.watch(profileProvider);
ref.read(profileProvider.notifier).fetchUserProfile();
ref.read(profileProvider.notifier).updateUserProfile(
  username: 'new_name',
  bio: 'New bio'
);
```

### 4. **Updated Profile Screen**

📄 `lib/presentation/screens/profile/profile_screen.dart`

Complete UI overhaul with features:

- **View Mode:** Display user info with profile header and stats
- **Edit Mode:** Edit username and bio with form validation
- **Avatar Display:** Shows uploaded avatar or generates avatar from username initial
- **Loading States:** Shimmer effect while loading
- **Error Handling:** Shows error messages to users
- **Quick Actions:** Refresh profile or navigate to settings

**Features:**

- ✅ Automatic profile fetch on screen load
- ✅ Edit mode toggle with save/cancel
- ✅ Loading indicators during API calls
- ✅ Error messages with retry options
- ✅ Theme support (light/dark mode)
- ✅ Glass morphism UI effects

## Integration Steps

### Step 1: Ensure Auth Token is Saved

In your login/auth flow, save the token:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', response.data.token);
```

### Step 2: Import Required Dependencies

Verify your `pubspec.yaml` has:

```yaml
flutter_riverpod: ^2.5.1
dio: ^5.4.1
shared_preferences: ^2.2.3
cached_network_image: ^3.3.1
shimmer: ^3.0.0
```

### Step 3: Use ProfileScreen

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In your app
ProfileScreen(
  onNavigateToSettings: () {
    // Handle navigation to settings
  },
)
```

### Step 4: Handle Auth Token in ProfileService

The profile provider automatically retrieves the token from SharedPreferences. Ensure:

1. Token is stored with key `'auth_token'`
2. Token is in format: `'Bearer <token>'` (handled automatically)

## API Response Format

### Success Response (200 OK)

```json
{
  "success": true,
  "message": "Profile retrieved successfully",
  "status": 200,
  "data": {
    "username": "john_doe",
    "avatar_url": "https://example.com/avatar.jpg",
    "bio": "Passionate about building better habits"
  }
}
```

### Error Response (401 Unauthorized)

```json
{
  "success": false,
  "message": "A valid Bearer token is required.",
  "status": 401,
  "error": {
    "code": "AUTH_TOKEN_MISSING",
    "message": "A valid Bearer token is required."
  }
}
```

## Usage Examples

### Fetch Profile

```dart
ref.read(profileProvider.notifier).fetchUserProfile();
```

### Update Profile

```dart
final success = await ref.read(profileProvider.notifier).updateUserProfile(
  username: 'new_username',
  avatarUrl: 'https://example.com/new_avatar.jpg',
  bio: 'Updated bio text'
);

if (success) {
  print('Profile updated!');
} else {
  print('Update failed: ${ref.read(profileProvider).error}');
}
```

### Watch Profile State

```dart
final profileState = ref.watch(profileProvider);

if (profileState.isLoading) {
  // Show loading
} else if (profileState.error != null) {
  // Show error
} else if (profileState.profile != null) {
  // Show profile
  Text(profileState.profile!.username)
}
```

## Error Handling

The implementation handles:

- **Missing Token:** 401 Unauthorized
- **Network Errors:** Connection timeouts, DNS failures
- **Invalid Data:** Malformed API responses
- **Server Errors:** 500+ status codes

All errors are displayed to users via:

- SnackBars for in-app notifications
- Error containers in the UI
- Console logs for debugging

## Customization

### Theme Colors

Update `AppColors.primaryPurple` in your theme to match your app

### Avatar Placeholder

Current: Uses first letter of username
Customize in `_buildProfileHeader()` method

### Edit Fields

Add more fields by:

1. Update `UserProfile` model
2. Add TextEditingController in `ProfileScreen`
3. Add TextField in `_buildEditForm()`
4. Include in `updateUserProfile()` call

## Testing

### Test Profile Fetch

```dart
void testProfileFetch() {
  // Ensure token is set in SharedPreferences
  final notifier = ref.read(profileProvider.notifier);
  final success = await notifier.fetchUserProfile();
  expect(success, true);
}
```

### Test Profile Update

```dart
void testProfileUpdate() {
  final notifier = ref.read(profileProvider.notifier);
  final success = await notifier.updateUserProfile(
    username: 'test_user',
    bio: 'Test bio'
  );
  expect(success, true);
}
```

## Troubleshooting

### "A valid Bearer token is required"

- **Issue:** Token not set or invalid
- **Solution:** Ensure token is saved in SharedPreferences during login

### Profile not loading on screen open

- **Issue:** Token may not be available yet
- **Solution:** Check that login flow saves the token before navigating to profile

### Images not loading

- **Issue:** Avatar URL might be invalid or CORS blocked
- **Solution:** Test URL in browser, ensure server allows image serving

### State not updating

- **Issue:** Provider not watching for changes
- **Solution:** Use `ref.watch(profileProvider)` not `ref.read()`

## Next Steps

1. **Connect Login Flow:** Ensure auth token is saved after successful login
2. **Test API Integration:** Verify API endpoint and token format
3. **Customize UI:** Adjust colors, spacing, and animations
4. **Add Avatar Upload:** Implement image picker for profile pictures
5. **Add More Fields:** Extend profile with additional user data

## Support

For issues or questions:

1. Check error messages in the app
2. Review console logs for detailed errors
3. Verify API endpoint and token format
4. Check network connectivity
