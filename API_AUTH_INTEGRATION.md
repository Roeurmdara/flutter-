# Flutter App API Integration Guide

## Overview

Your Flutter app has been integrated with the Habit Tracker API for user registration and login functionality.

## API Endpoints

- **Register**: `POST https://habit-api.rattanakmony.com/api/v1/auth/register`
- **Login**: `POST https://habit-api.rattanakmony.com/api/v1/auth/login`

## Architecture

### 1. **Models** (`lib/data/models/auth_models.dart`)

- `RegisterRequest`: Request model for registration (email, username, password)
- `LoginRequest`: Request model for login (username, password)
- `AuthResponse`: Response model from API
- `AuthData`: Contains user info from response
- `UserAuthInfo`: User data structure

### 2. **Service** (`lib/data/services/auth_service.dart`)

- `AuthService`: Handles API calls using Dio HTTP client
- Methods:
  - `register()`: Register a new user
  - `login()`: Login existing user
  - Handles errors gracefully with proper error codes

### 3. **State Management** (`lib/data/providers/auth_provider.dart`)

- `AuthNotifier`: Manages authentication state using Riverpod
- `AuthState`: Contains loading state, auth status, user info, and error messages
- Providers:
  - `authProvider`: Main auth state
  - `authServiceProvider`: Dio-based auth service
  - `isAuthenticatedProvider`: Helper to check if user is logged in
  - `currentUserProvider`: Helper to get current user info
- Features:
  - Auto-saves user info to local storage (SharedPreferences)
  - Session restoration via `checkAuthStatus()`

### 4. **Updated Login Screen** (`lib/presentation/screens/auth/login_screen.dart`)

- Converted to `ConsumerStatefulWidget` to use Riverpod
- Features:
  - Real-time validation
  - Error message display with dismissal button
  - Loading state management
  - Successful login/registration triggers callback
  - API integration with proper error handling

## How It Works

### Registration Flow

```
User fills form → Click "Create account"
→ Validates inputs (passwords match, terms agreed)
→ Calls authNotifier.register()
→ API request sent to register endpoint
→ Response handled, user data saved locally
→ onLoginSuccess() callback triggered
```

### Login Flow

```
User enters credentials → Click "Sign in"
→ Validates inputs (not empty)
→ Calls authNotifier.login()
→ API request sent to login endpoint
→ Response handled, user data saved locally
→ onLoginSuccess() callback triggered
```

## Usage in Your App

### Check Authentication Status

```dart
// In your main.dart or initial navigation logic
final authNotifier = ref.read(authProvider.notifier);
await authNotifier.checkAuthStatus(); // Restores session from local storage
```

### Monitor Auth State

```dart
// In a Consumer widget
final authState = ref.watch(authProvider);
if (authState.isAuthenticated) {
  // Show home screen
} else {
  // Show login screen
}
```

### Access Current User

```dart
final user = ref.watch(currentUserProvider);
print(user?.username); // Access user data
```

### Logout

```dart
final authNotifier = ref.read(authProvider.notifier);
await authNotifier.logout();
```

## Local Storage

User info is automatically saved to SharedPreferences on successful login/registration:

- `auth_user_id`
- `auth_user_email`
- `auth_user_username`
- `auth_user_avatar` (if available)

## Error Handling

Errors are displayed in the login form UI:

- Field validation errors (via SnackBar)
- API errors (displayed in error banner below tabs)
- Network errors are handled gracefully

## Next Steps

1. **Update main.dart** to handle auth state for navigation:

   ```dart
   final authNotifier = ref.read(authProvider.notifier);
   await authNotifier.checkAuthStatus();
   ```

2. **Add Bearer Token** to API requests (if your API returns tokens):
   - Update `AuthResponse` model to include token
   - Store token in SharedPreferences
   - Add interceptor to Dio to include token in all requests

3. **Implement Protected Routes**:
   - Use GoRouter with auth state guards
   - Navigate to login if unauthenticated
   - Navigate to home if authenticated

4. **Add Refresh Token Logic** (if API supports):
   - Implement token refresh endpoint
   - Auto-refresh expired tokens

## API Response Examples

### Successful Registration (201)

```json
{
  "success": true,
  "message": "Resource created successfully.",
  "status": 201,
  "data": {
    "user": {
      "id": "user123",
      "email": "user@example.com",
      "username": "john_doe",
      "avatar_url": null,
      "bio": null,
      "is_verified": false,
      "created_at": "2026-05-20T01:51:35.374Z"
    },
    "message": "Registration completed successfully."
  }
}
```

### Failed Login (401)

```json
{
  "success": false,
  "message": "Invalid username or password.",
  "status": 401,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid username or password."
  }
}
```

## Testing

### Test Registration

1. Go to "Create account" tab
2. Enter:
   - Username: `testuser`
   - Email: `test@example.com`
   - Password: `Password123!`
   - Confirm Password: `Password123!`
3. Check "I agree to the terms and conditions"
4. Click "Create account"

### Test Login

1. Go to "Sign in" tab
2. Enter:
   - Username: `testuser`
   - Password: `Password123!`
3. Click "Sign in"

## Files Created/Modified

- ✅ Created: `lib/data/models/auth_models.dart`
- ✅ Created: `lib/data/services/auth_service.dart`
- ✅ Created: `lib/data/providers/auth_provider.dart`
- ✅ Modified: `lib/presentation/screens/auth/login_screen.dart`
