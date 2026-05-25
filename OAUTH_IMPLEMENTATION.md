# OAuth Implementation Guide - Quick Start

## Files Created/Modified

### New Files Created:

1. **`lib/data/services/secure_storage_service.dart`**
   - Securely stores and retrieves JWT tokens
   - Methods: `saveAccessToken()`, `getAccessToken()`, `logout()`, etc.

2. **`lib/data/services/dio_client.dart`**
   - HTTP client with automatic Authorization header injection
   - Interceptors for token management

3. **`lib/data/services/auth_service.dart`** (Updated)
   - Added `loginWithGoogle()` and `loginWithGithub()` methods
   - OAuth flow: opens browser → extracts code → exchanges for tokens

4. **`lib/data/providers/auth_provider.dart`** (Updated)
   - Added Riverpod state management for OAuth
   - Methods: `loginWithGoogle()`, `loginWithGithub()`, `logout()`

5. **`lib/presentation/widgets/social_login_button.dart`**
   - Reusable Google and GitHub login buttons
   - Handles loading states and errors

6. **`lib/presentation/screens/auth/login_screen.dart`** (Updated)
   - Integrated OAuth buttons into login UI
   - Social login row with Google and GitHub buttons

7. **`pubspec.yaml`** (Updated)
   - Added dependencies: `flutter_web_auth_2`, `flutter_secure_storage`

### Configuration Files:

8. **`OAUTH_SETUP.md`**
   - Complete setup guide for Android, iOS, and Web
   - Deep linking configuration
   - Security best practices

---

## Usage Examples

### Example 1: Login with Google

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/data/providers/auth_provider.dart';

class MyLoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).loginWithGoogle();
            },
            child: const Text('Sign in with Google'),
          ),

          if (authState.isLoading)
            const CircularProgressIndicator(),

          if (authState.error != null)
            Text('Error: ${authState.error}'),

          if (authState.isAuthenticated)
            Text('Welcome, ${authState.user?.username}!'),
        ],
      ),
    );
  }
}
```

### Example 2: Login with GitHub

```dart
ElevatedButton(
  onPressed: () async {
    await ref.read(authProvider.notifier).loginWithGithub();
  },
  child: const Text('Sign in with GitHub'),
),
```

### Example 3: Auto-login on App Start

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).checkAuthStatus();

    final authState = ref.watch(authProvider);

    return MaterialApp(
      home: authState.isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }
}
```

### Example 4: Check if User is Logged In

```dart
final authState = ref.watch(authProvider);

if (authState.isAuthenticated) {
  print('User: ${authState.user?.email}');
} else {
  print('Not logged in');
}
```

### Example 5: Logout

```dart
ElevatedButton(
  onPressed: () async {
    await ref.read(authProvider.notifier).logout();
  },
  child: const Text('Logout'),
),
```

### Example 6: Access Token in API Calls

Tokens are automatically added by DioClient:

```dart
import 'package:your_app/data/services/dio_client.dart';

final dioClient = DioClient();

// Token is automatically added to Authorization header
final response = await dioClient.get('/habits');
```

### Example 7: Using the SocialLoginButton Widget

```dart
import 'package:your_app/presentation/widgets/social_login_button.dart';

Column(
  children: [
    SocialLoginButton.google(
      onPressed: () => ref.read(authProvider.notifier).loginWithGoogle(),
      isLoading: authState.isLoading,
    ),
    const SizedBox(height: 12),
    SocialLoginButton.github(
      onPressed: () => ref.read(authProvider.notifier).loginWithGithub(),
      isLoading: authState.isLoading,
    ),
  ],
),
```

---

## OAuth Flow Diagram

```
┌─ User clicks "Sign in with Google" ─┐
│                                       │
└──────────────────┬────────────────────┘
                   │
                   ▼
       ┌─ App opens browser ─┐
       │                     │
       └────────────┬────────┘
                    │
                    ▼
    ┌─ Browser navigates to ─┐
    │ /auth/social/google    │
    └────────────┬───────────┘
                 │
                 ▼
  ┌─ Backend redirects to Google ─┐
  │                               │
  └──────────────┬────────────────┘
                 │
                 ▼
   ┌─ User authenticates ─┐
   │                      │
   └────────────┬─────────┘
                │
                ▼
┌─ Google redirects to ─┐
│ myapp://callback?    │
│ code=xxx&state=yyy   │
└─────────────┬────────┘
              │
              ▼
┌─ Flutter extracts code & state ─┐
│                                  │
└──────────────┬───────────────────┘
               │
               ▼
┌─ Sends to /auth/social/google/callback ─┐
│ ?code=xxx&state=yyy                     │
└──────────────┬──────────────────────────┘
               │
               ▼
    ┌─ Backend returns ─┐
    │ access_token      │
    │ refresh_token     │
    │ user data         │
    └────────────┬──────┘
                 │
                 ▼
  ┌─ Flutter saves tokens securely ─┐
  │                                 │
  └────────────┬────────────────────┘
               │
               ▼
    ┌─ User logged in! ─┐
    │ Navigate to Home  │
    └───────────────────┘
```

---

## State Management with Riverpod

### Watch Auth State

```dart
final authState = ref.watch(authProvider);

// Access properties:
authState.isAuthenticated    // bool
authState.isLoading          // bool
authState.user               // UserAuthInfo?
authState.error              // String?
authState.errorCode          // String?
```

### Call Auth Methods

```dart
final authNotifier = ref.read(authProvider.notifier);

await authNotifier.loginWithGoogle();
await authNotifier.loginWithGithub();
await authNotifier.logout();
await authNotifier.register(...);
await authNotifier.login(...);
```

### Helper Providers

```dart
final isAuthenticated = ref.watch(isAuthenticatedProvider);
final currentUser = ref.watch(currentUserProvider);
```

---

## Testing OAuth Locally

### 1. Android Emulator

```bash
flutter run -d emulator-5554
```

The emulator has built-in browser support for OAuth.

### 2. iOS Simulator

```bash
flutter run -d "iPhone 15"
```

The simulator supports OAuth callbacks via Safari.

### 3. Web

```bash
flutter run -d chrome
```

Web automatically handles OAuth redirects.

### 4. Physical Device

```bash
flutter run -d <device-id>
```

Device must have browser installed (Chrome/Safari).

---

## Error Handling

### Handle Login Errors

```dart
try {
  await ref.read(authProvider.notifier).loginWithGoogle();
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Login failed: $e')),
  );
}
```

### Watch Error State

```dart
final authState = ref.watch(authProvider);

if (authState.error != null) {
  print('Error: ${authState.error}');
  print('Error code: ${authState.errorCode}');
}
```

### Common Errors

- **`CANCELLED`**: User cancelled the login
- **`PLATFORM_ERROR`**: System/browser error
- **`GOOGLE_AUTH_FAILED`**: Google OAuth failed
- **`GITHUB_AUTH_FAILED`**: GitHub OAuth failed
- **`NETWORK_ERROR`**: Network connectivity issue

---

## Security Considerations

✅ **Token Storage**: Uses `flutter_secure_storage` (encrypted)
✅ **Auto-included in Requests**: DioClient adds Authorization header
✅ **HTTPS Only**: All API calls use HTTPS
✅ **Token Refresh**: Implement if backend supports

❌ **Don't**: Store tokens in SharedPreferences (plain text)
❌ **Don't**: Log tokens in production
❌ **Don't**: Hardcode API keys

---

## Next Steps

1. **Run the app:**

   ```bash
   flutter pub get
   flutter run
   ```

2. **Test OAuth flow**:
   - Click "Sign in with Google"
   - Browser opens
   - Complete authentication
   - App should navigate to home

3. **Configure backend OAuth** (if needed):
   - Add Google OAuth credentials
   - Add GitHub OAuth credentials
   - Test callback endpoints

4. **Implement Additional Features**:
   - Token refresh
   - Biometric login
   - Social account linking
   - Account verification

---

## FAQ

**Q: How are tokens stored?**
A: Using `flutter_secure_storage` which encrypts on device.

**Q: Are tokens sent with every request?**
A: Yes, automatically via DioClient interceptor.

**Q: What if user cancels OAuth?**
A: App shows error message and returns to login screen.

**Q: Can I link multiple OAuth accounts?**
A: Yes, modify the backend and add linking logic.

**Q: How do I implement token refresh?**
A: Add refresh logic to DioClient interceptor (see DioClient implementation).

**Q: Is HTTPS required?**
A: Yes, for security. OAuth won't work over HTTP.

**Q: Can I customize the OAuth buttons?**
A: Yes, edit `SocialLoginButton` widget or use `_SocialBtn` in login_screen.dart.

---

## Support

For issues:

1. Check [OAUTH_SETUP.md](OAUTH_SETUP.md) for configuration
2. Review error messages and error codes
3. Check browser console for callback URL
4. Verify backend OAuth endpoints are working
5. Test with `curl` or Postman
