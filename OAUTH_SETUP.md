# OAuth Setup Guide - Google & GitHub

Complete setup guide for Flutter social authentication with Google and GitHub OAuth.

## Backend Configuration

Your backend API already handles OAuth:

- Base URL: `https://habit-api.rattanakmony.com/api/v1`
- Google OAuth: `GET /auth/social/google`
- GitHub OAuth: `GET /auth/social/github`
- Callback: `GET /auth/social/{provider}/callback?code=xxx&state=yyy`

## Frontend Configuration

### 1. Dependencies (Already Added)

```yaml
flutter_web_auth_2: ^1.5.0
flutter_secure_storage: ^9.0.0
```

### 2. App Configuration

#### Android Setup

**File: `android/app/build.gradle.kts`**

```gradle
android {
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.myapp"  // Change to your package name
        minSdk = 21
        targetSdk = 34
    }
}
```

**File: `android/app/src/main/AndroidManifest.xml`**

Add intent filter for deep linking:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <activity
            android:name=".MainActivity"
            android:exported="true">

            <!-- Existing launcher intent filter -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- Add OAuth callback intent filter -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="myapp"
                    android:host="callback" />
            </intent-filter>

        </activity>
    </application>
</manifest>
```

#### iOS Setup

**File: `ios/Runner/Info.plist`**

Add OAuth schemes:

```xml
<dict>
    <!-- Existing content -->

    <!-- Add OAuth URL schemes -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>myapp</string>
            </array>
        </dict>
    </array>

    <!-- For Google OAuth -->
    <key>GIDClientID</key>
    <string>YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com</string>

</dict>
```

#### Web Setup

**File: `web/index.html`**

No special configuration needed. The redirect callback works automatically.

### 3. Code Implementation

#### Secure Storage Service

Stores tokens securely:

```dart
final secureStorage = SecureStorageService();
await secureStorage.saveAccessToken('token123');
final token = await secureStorage.getAccessToken();
```

#### Auth Service

Handles OAuth flow:

```dart
final authService = AuthService();

// Login with Google
final response = await authService.loginWithGoogle();
if (response.success) {
    final user = response.user;
    final tokens = response.tokens;
}

// Login with GitHub
final response = await authService.loginWithGithub();
```

#### Auth Provider (Riverpod)

State management:

```dart
final authState = ref.watch(authProvider);

// Login
await ref.read(authProvider.notifier).loginWithGoogle();

// Check authentication
if (authState.isAuthenticated) {
    // Navigate to home
}

// Logout
await ref.read(authProvider.notifier).logout();
```

### 4. Google OAuth Setup (Optional - if backend doesn't handle it)

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project
3. Enable Google+ API
4. Create OAuth 2.0 credentials:
   - Type: Web application
   - Authorized redirect URIs: `myapp://callback`
5. Copy Client ID

### 5. GitHub OAuth Setup (Optional - if backend doesn't handle it)

1. Go to [GitHub Settings → Developer settings](https://github.com/settings/developers)
2. Create New OAuth App
3. Fill in:
   - Application name: Your app name
   - Homepage URL: Your website
   - Authorization callback URL: `https://habit-api.rattanakmony.com/auth/callback`
4. Copy Client ID and Secret

## OAuth Flow Explained

```
1. User clicks "Sign in with Google" button
   ↓
2. App opens browser using flutter_web_auth_2
   ↓
3. Browser navigates to:
   https://habit-api.rattanakmony.com/api/v1/auth/social/google
   ↓
4. Backend redirects to Google (or GitHub)
   ↓
5. User authenticates with Google/GitHub
   ↓
6. Google redirects to:
   myapp://callback?code=xxx&state=yyy
   ↓
7. Flutter extracts code and state from callback URL
   ↓
8. Flutter sends code to backend:
   GET /auth/social/google/callback?code=xxx&state=yyy
   ↓
9. Backend exchanges code for JWT tokens
   ↓
10. Backend returns:
    {
      "user": { "id": "...", "email": "..." },
      "tokens": { "access_token": "...", "refresh_token": "..." }
    }
   ↓
11. Flutter saves tokens to secure storage
   ↓
12. User logged in successfully!
```

## Testing

### Local Testing

1. Run the app
2. Click "Sign in with Google" or "Sign in with GitHub"
3. Browser opens
4. Authenticate with your account
5. Browser redirects to callback
6. Check Logcat (Android) or Console (iOS) for callback URL
7. App should navigate to home screen

### Debugging Callbacks

To see callback URL in Android:

```bash
adb logcat | grep "flutter"
```

To see callback URL in iOS:

```bash
# Check system logs in Xcode
```

## Error Handling

Common errors and solutions:

| Error                    | Cause                | Solution                   |
| ------------------------ | -------------------- | -------------------------- |
| `UserCancelledException` | User cancelled login | Show user-friendly message |
| `PlatformException`      | Browser/system issue | Check internet, retry      |
| `No authorization code`  | Invalid callback     | Verify URL scheme          |
| `401 Unauthorized`       | Invalid token        | Ask user to login again    |

## Token Management

### Auto-login on App Start

```dart
@override
void initState() {
  super.initState();
  ref.read(authProvider.notifier).checkAuthStatus();
}
```

### Token Refresh (Optional)

If backend supports refresh tokens:

```dart
Future<void> refreshToken() async {
  final refreshToken = await secureStorage.getRefreshToken();
  // Send to backend
  // Get new access token
  // Save to storage
}
```

### Token in API Requests

The `DioClient` automatically adds token to headers:

```dart
final response = await dio.get('/habits');
// Authorization: Bearer {token} is added automatically
```

## Security Best Practices

✅ **DO:**

- Use `flutter_secure_storage` for tokens (never SharedPreferences)
- Validate state parameter in callback
- Use HTTPS for all API calls
- Implement token refresh
- Clear tokens on logout

❌ **DON'T:**

- Store tokens in plain text
- Log tokens to console in production
- Hardcode API keys
- Skip SSL certificate validation

## Troubleshooting

### App doesn't recognize callback URL

Check:

1. Android: Intent filter in AndroidManifest.xml
2. iOS: CFBundleURLSchemes in Info.plist
3. Scheme must match: `myapp://callback`

### "No authorization code received"

Check:

1. Backend OAuth endpoint is working
2. Provider (Google/GitHub) redirects correctly
3. Callback URL scheme matches configuration

### Token not saved

Check:

1. `flutter_secure_storage` initialized
2. Has required permissions
3. Storage space available

### CORS errors

Backend should handle CORS. If not:

1. Check backend CORS configuration
2. Verify origin is whitelisted
3. Ask backend team to fix

## Production Checklist

- [ ] Add Google OAuth credentials to backend
- [ ] Add GitHub OAuth credentials to backend
- [ ] Update Android package name and signing
- [ ] Update iOS bundle ID and signing
- [ ] Test OAuth flow end-to-end
- [ ] Implement token refresh logic
- [ ] Add comprehensive error handling
- [ ] Hide debug logs in production
- [ ] Test logout flow
- [ ] Test auto-login
- [ ] Verify secure storage works on device

## Additional Resources

- [Flutter Web Auth 2 Docs](https://pub.dev/packages/flutter_web_auth_2)
- [Flutter Secure Storage Docs](https://pub.dev/packages/flutter_secure_storage)
- [Google OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)
- [GitHub OAuth Documentation](https://docs.github.com/en/developers/apps/building-oauth-apps)
