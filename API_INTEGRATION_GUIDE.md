# 🔌 API Integration Guide - HabitFlow

Complete guide for integrating the Flutter HabitFlow app with your Laravel backend.

## 📋 Table of Contents

1. [API Setup](#api-setup)
2. [Authentication](#authentication)
3. [Data Models & Serialization](#data-models--serialization)
4. [Repository Pattern](#repository-pattern)
5. [State Management](#state-management)
6. [Error Handling](#error-handling)
7. [Offline Support](#offline-support)

---

## 🔧 API Setup

### 1. Create API Service

Create `lib/data/datasources/api_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl = AppConstants.baseUrl;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyUserToken);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    return handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Handle token expiration
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUserToken);
      // Navigate to login
    }
    return handler.next(err);
  }

  // Generic GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // Generic DELETE request
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException error) {
    print('API Error: ${error.message}');
    print('Response: ${error.response?.data}');
  }
}
```

---

## 🔐 Authentication

### 2. Authentication Repository

Create `lib/data/repositories/auth_repository.dart`:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/api_service.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository(this.apiService);

  // Login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    // Save token
    final token = response['data']['token'];
    final user = User.fromJson(response['data']['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserToken, token);
    await prefs.setString(AppConstants.keyUserId, user.id);
    await prefs.setString(AppConstants.keyUserEmail, user.email);

    return user;
  }

  // Register
  Future<User> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
  }) async {
    final response = await apiService.post(
      '/auth/register',
      data: {
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
      },
    );

    final token = response['data']['token'];
    final user = User.fromJson(response['data']['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserToken, token);
    await prefs.setString(AppConstants.keyUserId, user.id);

    return user;
  }

  // Logout
  Future<void> logout() async {
    await apiService.post('/auth/logout');

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyUserToken);
    await prefs.remove(AppConstants.keyUserId);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserToken) != null;
  }
}
```

---

## 📦 Data Models & Serialization

Your models are already set up with `fromJson()` and `toJson()` methods:

```dart
// Usage in repository
final habit = Habit.fromJson(apiResponse);
final json = habit.toJson();

// For API calls
final response = await apiService.post(
  '/habits',
  data: habit.toJson(),
);
```

### Models Ready:

- ✅ `Habit` - Full model with JSON serialization
- ✅ `User` - User profile and preferences
- ✅ `HabitTemplate` - Pre-built templates
- ✅ `Community` - Community and posts

---

## 📚 Repository Pattern

### 3. Habit Repository

Create `lib/data/repositories/habit_repository.dart`:

```dart
import '../datasources/api_service.dart';
import '../models/habit_model.dart';

class HabitRepository {
  final ApiService apiService;

  HabitRepository(this.apiService);

  // Get all habits
  Future<List<Habit>> getHabits() async {
    final response = await apiService.get('/habits');
    return (response['data'] as List)
        .map((h) => Habit.fromJson(h))
        .toList();
  }

  // Get single habit
  Future<Habit> getHabit(String habitId) async {
    final response = await apiService.get('/habits/$habitId');
    return Habit.fromJson(response['data']);
  }

  // Create habit
  Future<Habit> createHabit(Habit habit) async {
    final response = await apiService.post(
      '/habits',
      data: habit.toJson(),
    );
    return Habit.fromJson(response['data']);
  }

  // Update habit
  Future<Habit> updateHabit(String habitId, Habit habit) async {
    final response = await apiService.put(
      '/habits/$habitId',
      data: habit.toJson(),
    );
    return Habit.fromJson(response['data']);
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    await apiService.delete('/habits/$habitId');
  }

  // Mark habit as complete
  Future<void> markComplete(String habitId, DateTime date) async {
    await apiService.post(
      '/habits/$habitId/complete',
      data: {'date': date.toIso8601String()},
    );
  }

  // Get completed dates (for calendar)
  Future<List<DateTime>> getCompletedDates(String habitId) async {
    final response = await apiService.get('/habits/$habitId/completed-dates');
    return (response['data'] as List)
        .map((d) => DateTime.parse(d))
        .toList();
  }
}
```

---

## 🔄 State Management with Riverpod

### 4. Set Up Providers

Create `lib/presentation/providers/habit_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/models/habit_model.dart';

// API Service provider
final apiServiceProvider = Provider((ref) => ApiService());

// Repository provider
final habitRepositoryProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return HabitRepository(apiService);
});

// Get all habits
final habitsProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabits();
});

// Get single habit
final habitProvider = FutureProvider.autoDispose.family(
  (ref, String habitId) async {
    final repository = ref.watch(habitRepositoryProvider);
    return repository.getHabit(habitId);
  },
);

// State notifier for creating habits
final createHabitProvider = StateNotifierProvider.autoDispose((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return CreateHabitNotifier(repository);
});

class CreateHabitNotifier extends StateNotifier<AsyncValue<void>> {
  final HabitRepository _repository;

  CreateHabitNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> createHabit(Habit habit) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createHabit(habit);
    });
  }
}
```

---

## ⚠️ Error Handling

### 5. Custom Exception Class

Create `lib/data/exceptions/app_exceptions.dart`:

```dart
class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({String? message})
      : super(message: message ?? 'Network error');
}

class AuthException extends AppException {
  AuthException({String? message})
      : super(message: message ?? 'Authentication failed');
}

class ValidationException extends AppException {
  ValidationException({String? message})
      : super(message: message ?? 'Validation error');
}
```

---

## 💾 Offline Support

### 6. Local Storage with SQLite

Create `lib/data/datasources/local_database.dart`:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit_model.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  factory LocalDatabase() {
    return _instance;
  }

  LocalDatabase._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'habitflow.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        frequency TEXT NOT NULL,
        duration INTEGER NOT NULL,
        reminder_time TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_active INTEGER NOT NULL,
        is_archived INTEGER NOT NULL,
        current_streak INTEGER NOT NULL,
        best_streak INTEGER NOT NULL,
        completed_dates TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  // Save habit locally
  Future<void> saveHabit(Habit habit) async {
    final db = await database;
    await db.insert(
      'habits',
      {
        ...habit.toJson(),
        'completed_dates': habit.completedDates
            .map((d) => d.toIso8601String())
            .join(','),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all local habits
  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final results = await db.query('habits');
    return results
        .map((r) => Habit.fromJson(_parseRecord(r)))
        .toList();
  }

  Map<String, dynamic> _parseRecord(Map<String, dynamic> record) {
    final completedDates = (record['completed_dates'] as String)
        .split(',')
        .map((d) => d)
        .toList();

    return {
      ...record,
      'completed_dates': completedDates,
    };
  }
}
```

---

## 🚀 Usage Example

### 7. Using in Screens

```dart
// In a screen with Riverpod
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
      data: (habits) => ListView(
        children: habits
            .map((habit) => HabitCard(habit: habit))
            .toList(),
      ),
    );
  }
}

// Creating a habit
class CreateHabitButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final habit = Habit(
          id: 'unique-id',
          userId: 'user-id',
          title: 'Morning Run',
          category: 'Fitness',
          icon: '🏃',
          color: '#FF6B6B',
          frequency: 'Daily',
          duration: 30,
          createdAt: DateTime.now(),
          startDate: DateTime.now(),
          isActive: true,
          isArchived: false,
          currentStreak: 0,
          bestStreak: 0,
          completedDates: [],
        );

        await ref.read(createHabitProvider.notifier).createHabit(habit);
      },
      child: const Text('Create Habit'),
    );
  }
}
```

---

## 📝 Laravel API Endpoints

Ensure your Laravel backend implements these endpoints:

```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
GET    /api/v1/habits
POST   /api/v1/habits
GET    /api/v1/habits/{id}
PUT    /api/v1/habits/{id}
DELETE /api/v1/habits/{id}
POST   /api/v1/habits/{id}/complete
GET    /api/v1/habits/{id}/completed-dates
GET    /api/v1/user/profile
PUT    /api/v1/user/profile
GET    /api/v1/communities
POST   /api/v1/communities/{id}/join
```

---

## 🔍 Testing the Integration

1. **Mock the API Service** for testing
2. **Use Riverpod Testing** utilities
3. **Test repositories** independently
4. **Integration tests** with real API

---

## ✅ Checklist for API Integration

- [ ] Create `ApiService` class
- [ ] Implement authentication interceptor
- [ ] Create repository classes for each feature
- [ ] Set up Riverpod providers
- [ ] Implement error handling
- [ ] Add local database caching
- [ ] Connect screens to providers
- [ ] Test with mock data first
- [ ] Connect to real Laravel API
- [ ] Implement offline support

---

**Your HabitFlow app is now ready for complete API integration!** 🎉
