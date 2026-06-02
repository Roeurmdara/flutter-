# 🔧 Template Fetching Error - Troubleshooting Guide

## Error Message

```
Error fetching templates: DioException [connection error]: The connection errored:
The XMLHttpRequest onError callback was called.
```

---

## 🎯 Root Cause Analysis

Your app is trying to fetch templates from:

```
https://habit-api.rattanakmony.com/api/v1/categories/{id}/templates
```

**But the request is failing with a connection error.**

### Common Causes (In Order of Likelihood):

1. **API Server is Down** ❌ (Most Common)
2. **No Internet Connection** 📡
3. **SSL Certificate Issue** 🔒
4. **Network Timeout** ⏱️
5. **Firewall/Proxy Blocking** 🛡️
6. **API Endpoint Changed** 🔗

---

## 🔍 Diagnostic Steps

### Step 1: Check Network Connectivity

```bash
# Open terminal and test if the API is reachable
# On Windows (PowerShell):
Invoke-WebRequest -Uri "https://habit-api.rattanakmony.com/api/v1/categories" -UseBasicParsing

# On Mac/Linux:
curl https://habit-api.rattanakmony.com/api/v1/categories
```

**Expected Response:** HTTP 200 with JSON data  
**If you get connection error:** The API server is unreachable

---

### Step 2: Check API Server Status

Visit the API URL directly in your browser:

```
https://habit-api.rattanakmony.com/api/v1/categories
```

- ✅ **If it loads**: Server is working, issue is with your app
- ❌ **If it doesn't load**: Server is down or unreachable

---

### Step 3: Check Console Logs

Run your app with debugging:

```bash
flutter run -v
```

Look for logs that start with `[HabitCategoryService]`:

```
[HabitCategoryService] Fetching categories from: https://habit-api.rattanakmony.com/api/v1/categories
[HabitCategoryService] Dio error - Type: DioExceptionType.connectionError, Message: ...
```

The error type tells you exactly what's wrong:

- `connectionError` → Can't reach the server
- `connectionTimeout` → Server took too long to respond
- `badCertificate` → SSL certificate issue
- `sendTimeout` → Can't send request

---

## 🛠️ Solutions

### **Solution 1: Use a Fallback/Mock API (Quick Fix)**

If the live API is down, use mock data temporarily:

**File:** `lib/data/providers/category_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_category_model.dart';
import '../models/discover_template_model.dart';
import '../services/habit_category_service.dart';

// Service provider
final habitCategoryServiceProvider = Provider<HabitCategoryService>((ref) {
  return HabitCategoryService();
});

// Categories provider with fallback
final categoriesProvider = FutureProvider<List<HabitCategory>>((ref) async {
  try {
    final service = ref.watch(habitCategoryServiceProvider);
    return await service.getCategories();
  } catch (e) {
    print('Error loading categories: $e');
    // Return mock categories as fallback
    return _getMockCategories();
  }
});

// Templates provider with fallback
final categoryTemplatesProvider =
    FutureProvider.family<List<DiscoverTemplate>, String>(
        (ref, categoryId) async {
  try {
    final service = ref.watch(habitCategoryServiceProvider);
    return await service.getCategoryTemplates(categoryId);
  } catch (e) {
    print('Error loading templates for $categoryId: $e');
    // Return mock templates as fallback
    return _getMockTemplates(categoryId);
  }
});

// Mock data functions
List<HabitCategory> _getMockCategories() {
  return [
    HabitCategory(
      id: '1',
      name: 'Health & Fitness',
      icon: '🏃',
      color: '#FF6B6B',
    ),
    HabitCategory(
      id: '2',
      name: 'Learning',
      icon: '📚',
      color: '#4ECDC4',
    ),
    HabitCategory(
      id: '3',
      name: 'Productivity',
      icon: '⚡',
      color: '#95E1D3',
    ),
  ];
}

List<DiscoverTemplate> _getMockTemplates(String categoryId) {
  final allMockTemplates = {
    '1': [ // Health & Fitness
      DiscoverTemplate(
        id: 't1',
        categoryId: '1',
        title: 'Morning Run',
        description: 'Start your day with a 30-minute run',
        suggestedFrequency: 'daily',
        targetValue: '30',
        targetUnit: 'minutes',
        durationDays: 30,
        tips: 'Start slow, increase pace gradually',
        isPublished: true,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
    '2': [ // Learning
      DiscoverTemplate(
        id: 't2',
        categoryId: '2',
        title: 'Read a Book',
        description: 'Read for 30 minutes every day',
        suggestedFrequency: 'daily',
        targetValue: '30',
        targetUnit: 'minutes',
        durationDays: 30,
        tips: 'Find a quiet place, minimize distractions',
        isPublished: true,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
  };

  return allMockTemplates[categoryId] ?? [];
}
```

---

### **Solution 2: Change API Endpoint**

If you have a different API server, update the base URL:

**File:** `lib/data/services/habit_category_service.dart`

```dart
class HabitCategoryService {
  // Change this to your API endpoint
  static const String _baseUrl =
      'https://your-api.com/api/v1/categories';

  // Or for local testing:
  // static const String _baseUrl =
  //     'http://localhost:8000/api/v1/categories';
```

---

### **Solution 3: Fix SSL Certificate Issues**

If you're getting SSL certificate errors, add this temporary fix:

**File:** `lib/data/services/habit_category_service.dart`

```dart
HabitCategoryService({Dio? dio})
    : _dio = dio ?? Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) => status != null && status < 500,
        ),
      ) {
    // Disable SSL verification (NOT for production!)
    (_dio.httpClientAdapter as dynamic).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }
```

**⚠️ WARNING:** Only use this for development! Remove before production.

---

### **Solution 4: Increase Timeout Duration**

If the server is slow, increase timeout:

**File:** `lib/data/services/habit_category_service.dart`

```dart
HabitCategoryService({Dio? dio})
    : _dio = dio ?? Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 60), // Increased from 30
          receiveTimeout: const Duration(seconds: 60), // Increased from 30
          validateStatus: (status) => status != null && status < 500,
        ),
      );
```

---

### **Solution 5: Check and Retry Logic**

Add automatic retry on network failure:

**File:** `lib/data/services/habit_category_service.dart`

```dart
Future<List<DiscoverTemplate>> getCategoryTemplates(String categoryId) async {
  const maxRetries = 3;
  int attempt = 0;

  while (attempt < maxRetries) {
    try {
      print('[HabitCategoryService] Attempt ${attempt + 1} to fetch templates');
      final url = '$_baseUrl/$categoryId/templates';

      final response = await _dio.get(
        url,
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> templatesData =
            data['data'] as List<dynamic>? ?? [];

        return templatesData
            .map((json) =>
                DiscoverTemplate.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      attempt++;
      if (attempt < maxRetries) {
        print('[HabitCategoryService] Retry in 2 seconds...');
        await Future.delayed(const Duration(seconds: 2));
      } else {
        rethrow;
      }
    }
  }

  throw Exception('Failed after $maxRetries retries');
}
```

---

## ✅ Quick Checklist

- [ ] Run `flutter clean` and `flutter pub get`
- [ ] Check internet connection is working
- [ ] Verify API server is running
- [ ] Check console logs for detailed error messages
- [ ] Try accessing the API URL in a web browser
- [ ] If using a new API, update the `_baseUrl` in `HabitCategoryService`
- [ ] If SSL error, check certificate validity
- [ ] Restart your Flutter app after making changes

---

## 📞 Still Not Working?

1. **Check the terminal output** - Look for `[HabitCategoryService]` log messages
2. **Share the exact error message** - Post it in your logs
3. **Check API server health** - Make sure `https://habit-api.rattanakmony.com` is accessible
4. **Try with mock data** - Use Solution 1 to verify your app works with local data

---

## 📝 Changes Made (May 28, 2026)

✅ Added detailed logging to `HabitCategoryService`  
✅ Improved error messages in categories screen  
✅ Added timeout configuration to Dio client  
✅ Created error type categorization for better debugging
