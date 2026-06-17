import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to securely store and retrieve tokens using FlutterSecureStorage
/// This prevents sensitive data like JWT tokens from being exposed
class SecureStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userUsernameKey = 'user_username';
  // SharedPreferences keys for backward compatibility
  static const String _sharedPrefTokenKey = 'auth_token';
  static const String _sharedPrefLegacyTokenKey = 'user_token';

  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save access token securely - save to both SecureStorage and SharedPreferences
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sharedPrefTokenKey, token);
      await prefs.setString(_sharedPrefLegacyTokenKey, token);
    } catch (e) {
      // SharedPreferences might not be available on all platforms
    }
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get access token - prefer SecureStorage, then migrate legacy prefs token.
  Future<String?> getAccessToken() async {
    final secureToken = await _storage.read(key: _accessTokenKey);
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final sharedToken = prefs.getString(_sharedPrefTokenKey);
      if (sharedToken != null && sharedToken.isNotEmpty) {
        await _storage.write(key: _accessTokenKey, value: sharedToken);
        return sharedToken;
      }
    } catch (e) {
      // SharedPreferences might not be available on all platforms
    }

    return null;
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save user data
  Future<void> saveUserData({
    required String userId,
    required String email,
    String? username,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _userEmailKey, value: email),
      if (username != null)
        _storage.write(key: _userUsernameKey, value: username),
    ]);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Get user username
  Future<String?> getUserUsername() async {
    return await _storage.read(key: _userUsernameKey);
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userUsernameKey),
    ]);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sharedPrefTokenKey);
      await prefs.remove(_sharedPrefLegacyTokenKey);
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_user_email');
      await prefs.remove('auth_user_username');
      await prefs.remove('auth_user_avatar');
    } catch (e) {
      // SharedPreferences might not be available on all platforms
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
