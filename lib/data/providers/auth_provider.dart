import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart';

// Secure Storage Provider
final secureStorageProvider = Provider((ref) {
  return SecureStorageService();
});

// Auth Service Provider
final authServiceProvider = Provider((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthService(secureStorage: secureStorage);
});

// Auth State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserAuthInfo? user;
  final String? error;
  final String? errorCode;

  AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.user,
    this.error,
    this.errorCode,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserAuthInfo? user,
    bool clearUser = false,
    String? error,
    String? errorCode,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : user ?? this.user,
      error: error,
      errorCode: errorCode ?? this.errorCode,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService)
      : super(
          AuthState(
            isLoading: false,
            isAuthenticated: false,
            user: null,
            error: null,
          ),
        );

  /// Build a UserAuthInfo with token merged in from AuthData
  UserAuthInfo _mergeToken(UserAuthInfo user, String token) {
    return UserAuthInfo(
      id: user.id,
      email: user.email,
      username: user.username,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      role: user.role,
      status: user.status,
      isVerified: user.isVerified,
      isDeleted: user.isDeleted,
      keycloakSubject: user.keycloakSubject,
      verifiedAt: user.verifiedAt,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastActiveAt: user.lastActiveAt,
      token: token,
    );
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.register(
        email: email,
        username: username,
        password: password,
      );

      if (response.success && response.data?.user != null) {
        final token = response.data!.token ?? response.data!.user?.token ?? '';
        final userWithToken = _mergeToken(response.data!.user!, token);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: userWithToken,
          error: null,
        );

        await _saveAuthData(
          userWithToken,
          token,
          refreshToken: response.data!.refreshToken,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? response.message,
          errorCode: response.errorCode,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
      return false;
    }
  }

  /// Login user
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      if (response.success && response.data?.user != null) {
        // ✅ Token lives on AuthData.token — merge it into user
        final token = response.data!.token ?? response.data!.user?.token ?? '';
        final userWithToken = _mergeToken(response.data!.user!, token);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: userWithToken,
          error: null,
        );

        await _saveAuthData(
          userWithToken,
          token,
          refreshToken: response.data!.refreshToken,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? response.message,
          errorCode: response.errorCode,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(
      isAuthenticated: false,
      clearUser: true,
      error: null,
    );

    final prefs = await SharedPreferences.getInstance();
    await _authService.logout();
    await prefs.remove('auth_user_id');
    await prefs.remove('auth_user_email');
    await prefs.remove('auth_user_username');
    await prefs.remove('auth_user_avatar');
    await prefs.remove('auth_token');
    await prefs.remove('user_token');
  }

  /// Save auth data to local storage
  Future<void> _saveAuthData(
    UserAuthInfo user,
    String token, {
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (token.isNotEmpty) {
      await prefs.setString('auth_token', token);
      await prefs.setString('user_token', token);
      await _authService.saveAccessToken(token);
    }
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _authService.saveRefreshToken(refreshToken);
    }

    await prefs.setString('auth_user_id', user.id);
    await prefs.setString('auth_user_email', user.email);
    await prefs.setString('auth_user_username', user.username);
    if (user.avatarUrl != null) {
      await prefs.setString('auth_user_avatar', user.avatarUrl!);
    }
  }

  /// Check if user is logged in (restore session)
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('auth_user_id');
      final email = prefs.getString('auth_user_email');
      final username = prefs.getString('auth_user_username');
      final avatar = prefs.getString('auth_user_avatar');
      final token = prefs.getString('auth_token');

      if (userId != null && email != null && username != null) {
        final user = UserAuthInfo(
          id: userId,
          email: email,
          username: username,
          avatarUrl: avatar,
          token: token, // ✅ restored from prefs
        );
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null, errorCode: null);
  }

  /// Request password reset
  Future<bool> requestPasswordReset({
    required String email,
    required String redirectUri,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.requestPasswordReset(
        email: email,
        redirectUri: redirectUri,
      );

      if (response.success) {
        state = state.copyWith(isLoading: false, error: null);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? response.message,
          errorCode: response.errorCode,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
      return false;
    }
  }

  /// Login with Google OAuth
  Future<bool> loginWithGoogle(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.loginWithGoogle(context);

      if (response.success && response.data?.user != null) {
        final token = response.data!.token ?? response.data!.user?.token ?? '';
        final userWithToken = _mergeToken(response.data!.user!, token);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: userWithToken,
          error: null,
        );

        await _saveAuthData(
          userWithToken,
          token,
          refreshToken: response.data!.refreshToken,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? response.message,
          errorCode: response.errorCode,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        errorCode: 'GOOGLE_AUTH_FAILED',
      );
      return false;
    }
  }

  /// Login with GitHub OAuth
  Future<bool> loginWithGithub(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.loginWithGithub(context);

      if (response.success && response.data?.user != null) {
        final token = response.data!.token ?? response.data!.user?.token ?? '';
        final userWithToken = _mergeToken(response.data!.user!, token);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: userWithToken,
          error: null,
        );

        await _saveAuthData(
          userWithToken,
          token,
          refreshToken: response.data!.refreshToken,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? response.message,
          errorCode: response.errorCode,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        errorCode: 'GITHUB_AUTH_FAILED',
      );
      return false;
    }
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Helper provider to check if user is logged in
final isAuthenticatedProvider = Provider((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

// Helper provider to get current user
final currentUserProvider = Provider((ref) {
  return ref.watch(authProvider).user;
});
