# Android OAuth Configuration Example

Copy this into your `android/app/src/main/AndroidManifest.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.habittracker">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:label="Habit Tracker"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- Launcher intent filter -->
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>

            <!-- ═══════════════════════════════════════════════════════════ -->
            <!-- OAuth Callback Intent Filter - REQUIRED FOR OAUTH TO WORK   -->
            <!-- ═══════════════════════════════════════════════════════════ -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <!--
                    This tells Android to capture URLs like:
                    myapp://callback?code=xxx&state=yyy

                    The scheme "myapp" MUST match the callbackUrlScheme
                    in FlutterWebAuthorizationPlugin.authenticate()
                -->
                <data
                    android:scheme="myapp"
                    android:host="callback" />
            </intent-filter>

        </activity>

        <!-- ═══════════════════════════════════════════════════════════ -->
        <!-- Provider Definitions -->
        <!-- ═══════════════════════════════════════════════════════════ -->

        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths" />
        </provider>

    </application>

</manifest>
```

## Key Points:

1. **Package Name**: Change `com.example.habittracker` to your actual package name
2. **OAuth Intent Filter**: Required for deep linking to work
3. **Scheme**: Must match `callbackUrlScheme: "myapp"` in code
4. **Host**: Can be anything, we use "callback" for clarity
5. **Permissions**: INTERNET is required for OAuth

## How It Works:

When user completes OAuth:

1. Browser redirects to: `myapp://callback?code=xxx&state=yyy`
2. Android OS sees this URL scheme in the intent filter
3. Android launches MainActivity with the callback URL
4. flutter_web_auth_2 plugin captures the URL
5. App extracts code and state
6. App exchanges code for tokens

## Testing:

To test if intent filter is working:

```bash
adb shell am start -a android.intent.action.VIEW \
  -d "myapp://callback?code=test&state=test"
```

If it opens the app, intent filter is working!

## Common Issues:

**App doesn't receive callback URL:**

- Check scheme matches exactly (case-sensitive)
- Verify package name in manifest
- Ensure intent-filter is on MainActivity
- Check exported="true"

**App force closes:**

- Check syntax of XML
- Verify all tags are properly closed
- Check for special characters in scheme

**URL not recognized:**

- Scheme must start with lowercase letter
- No special characters except underscore
- Must be exactly: `myapp://callback`
