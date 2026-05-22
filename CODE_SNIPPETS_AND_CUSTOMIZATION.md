# 💻 Code Snippets & Customization Guide

## 🎯 Common Customization Tasks

### 1. Change API Base URL

**File**: `lib/data/services/habit_service.dart`

```dart
// BEFORE
static const String _baseUrl = 'https://habit-api.rattanakmony.com/api/v1';

// AFTER (for your custom API)
static const String _baseUrl = 'https://your-api.com/api/v1';
```

### 2. Add Authentication Headers

**File**: `lib/data/services/habit_service.dart`

```dart
class HabitService {
  final Dio _dio;
  final String _authToken;

  HabitService(this._dio, this._authToken) {
    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $_authToken';
          return handler.next(options);
        },
      ),
    );
  }
}
```

### 3. Add More Categories

**File**: `lib/presentation/widgets/create_habit_modal.dart`

```dart
Widget _buildCategorySelector(bool isDark) {
  final categories = [
    'Health',
    'Fitness',
    'Learning',
    'Productivity',
    'Personal',
    'Finance',        // ADD NEW
    'Relationships',  // ADD NEW
    'Spirituality',   // ADD NEW
  ];
  // ... rest of code
}
```

### 4. Change Primary Colors

**File**: `lib/core/theme/app_colors.dart`

```dart
// Edit these colors
static const Color primaryPurple = Color(0xFF7C3AED);      // Change to your color
static const Color secondaryGreen = Color(0xFF10B981);    // Change to your color
static const Color primaryPurpleDark = Color(0xFF6D28D9); // Change to your color
```

### 5. Add More Frequency Options

**File**: `lib/data/providers/habit_provider.dart`

```dart
// In getHabitsForDate() method, add new case
switch (habit.frequency.toLowerCase()) {
  case 'daily':
    return true;
  case 'weekly':
    return date.weekday == habit.startDate.weekday;
  case 'biweekly':  // ADD NEW
    final daysDiff = date.difference(habit.startDate).inDays;
    return daysDiff % 14 == 0;
  case 'monthly':
    return date.day == habit.startDate.day;
  default:
    return true;
}
```

---

## 📝 Code Examples

### Create a Habit Programmatically

```dart
// In a button's onPressed handler:
await ref.read(habitsProvider.notifier).createHabit(
  categoryId: const Uuid().v4(),
  title: 'Drink Water',
  description: '8 glasses of water daily',
  frequencyType: 'daily',
  frequencyConfig: ['daily'],
  goalType: 'binary',
  targetValue: 1,
  targetUnit: 'completion',
  startDate: DateTime.now(),
  visibility: 'private',
);
```

### Get Habits for a Specific Date

```dart
// In your widget:
final specificDate = DateTime(2026, 5, 25);
ref.read(habitsProvider.notifier).selectDate(specificDate);

// Now access filtered habits
final habitsForDate = ref.watch(habitsForDateProvider);
```

### Update a Habit

```dart
await ref.read(habitsProvider.notifier).updateHabit(
  habitId,
  title: 'New Title',
  description: 'Updated description',
  frequencyType: 'weekly',
);
```

### Mark Habit Complete for Past Date

```dart
final pastDate = DateTime.now().subtract(Duration(days: 5));
await ref.read(habitsProvider.notifier).markHabitAsDone(
  habitId,
  pastDate,
);
```

### Listen to Habit State Changes

```dart
// In your ConsumerWidget:
ref.listen(habitsProvider, (previous, next) {
  if (next.error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${next.error}')),
    );
  }
});
```

---

## 🎨 UI Customization

### Change Calendar Colors

**File**: `lib/presentation/screens/home/home_dashboard_screen.dart`

```dart
calendarStyle: CalendarStyle(
  // Change selected day color
  selectedDecoration: BoxDecoration(
    color: Colors.blue,  // Change this
    shape: BoxShape.circle,
  ),
  // Change today color
  todayDecoration: BoxDecoration(
    color: Colors.orange.withOpacity(0.3),  // Change this
    shape: BoxShape.circle,
  ),
  // ... other properties
),
```

### Customize Habit Card Appearance

**File**: `lib/presentation/widgets/habit_card_widget.dart`

```dart
// Change card border color when complete
border: Border.all(
  color: isCompleted
      ? Colors.green  // Change this
      : Colors.grey,
  width: 2,
),
```

### Add Animation to Habit Cards

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Wrap HabitCardWidget with animation
HabitCardWidget(...)
  .animate()
  .slideX(begin: -0.1, duration: 300.ms)
  .fade(duration: 300.ms),
```

---

## 🔧 Advanced Configurations

### Add Logging

**File**: `lib/data/services/habit_service.dart`

```dart
HabitService(this._dio) {
  _dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        print('📱 API LOG: $obj');
      },
    ),
  );
}
```

### Add Retry Logic

```dart
import 'dio/dio_client_retry.dart'; // or use retry_interceptor package

_dio.interceptors.add(
  RetryInterceptor(
    dio: _dio,
    maxRetries: 3,
  ),
);
```

### Add Request Timeout

```dart
class HabitService {
  final Dio _dio;

  HabitService(this._dio) {
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);
  }
}
```

### Add Network Error Handling

```dart
Future<List<Habit>> getHabits() async {
  try {
    final response = await _dio.get('$_baseUrl/habits');
    return (response.data['data'] as List)
        .map((h) => Habit.fromJson(h))
        .toList();
  } on DioException catch (e) {
    if (e.isNoConnectionError) {
      throw Exception('No internet connection');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Connection timeout');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }
}

extension on DioException {
  bool get isNoConnectionError {
    return type == DioExceptionType.unknown &&
        error != null &&
        error is SocketException;
  }
}
```

---

## 📊 Adding Statistics

### Calculate Weekly Statistics

```dart
// Add to HabitsNotifier
int getWeeklyCompletionRate() {
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));

  final weekHabits = state.habits
      .where((h) =>
          h.startDate.isBefore(weekStart) &&
          (h.endDate == null || h.endDate!.isAfter(weekStart)))
      .toList();

  if (weekHabits.isEmpty) return 0;

  final completed = weekHabits
      .where((h) => h.completedDates.any((d) =>
          d.isAfter(weekStart) && d.isBefore(weekStart.add(Duration(days: 7)))))
      .length;

  return ((completed / weekHabits.length) * 100).toInt();
}
```

### Track Monthly Progress

```dart
Map<int, int> getMonthlyProgress(int month, int year) {
  final monthStart = DateTime(year, month, 1);
  final monthEnd = DateTime(year, month + 1, 0);

  final progressMap = <int, int>{};

  for (int day = 1; day <= monthEnd.day; day++) {
    final date = DateTime(year, month, day);
    final dayHabits = state.habits
        .where((h) => h.startDate.isBefore(date))
        .toList();

    final completed = dayHabits
        .where((h) => h.completedDates.any(
            (d) => d.year == year && d.month == month && d.day == day))
        .length;

    progressMap[day] = dayHabits.isEmpty ? 0 : ((completed / dayHabits.length) * 100).toInt();
  }

  return progressMap;
}
```

---

## 🔔 Adding Notifications

**File**: `lib/presentation/screens/home/home_dashboard_screen.dart`

```dart
import 'flutter_local_notifications/flutter_local_notifications.dart';

void _scheduleHabitReminder(Habit habit) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final time = TimeOfDay.fromDateTime(
    DateTime.parse('2000-01-01 ${habit.reminderTime}'),
  );

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'habit_reminder_channel',
    'Habit Reminders',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.showDailyAtTime(
    habit.id.hashCode,
    '${habit.title}',
    'Time to complete your daily habit!',
    time,
    platformChannelSpecifics,
  );
}
```

---

## 🧪 Testing Examples

### Unit Test for HabitsNotifier

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('HabitsNotifier', () {
    test('creates habit successfully', () async {
      final mockService = MockHabitService();
      final notifier = HabitsNotifier(mockService);

      when(mockService.createHabit(...))
          .thenAnswer((_) async => testHabit);

      await notifier.createHabit(...);

      expect(notifier.state.habits, contains(testHabit));
    });

    test('marks habit as done', () async {
      final mockService = MockHabitService();
      final notifier = HabitsNotifier(mockService);

      when(mockService.markHabitAsDone(...))
          .thenAnswer((_) async => {});

      await notifier.markHabitAsDone(habitId, date);

      expect(notifier.state.completedStatus[habitId], true);
    });
  });
}
```

### Widget Test for Habit Card

```dart
void main() {
  testWidgets('HabitCard shows completed state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HabitCardWidget(
            habit: testHabit,
            isCompleted: true,
            onToggle: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
```

---

## 🚀 Performance Tips

### 1. Use const constructors

```dart
// ✅ Good
const HabitCardWidget(...)

// ❌ Bad
HabitCardWidget(...)
```

### 2. Cache computed values

```dart
// Already done in habit_provider.dart
final habitsForDateProvider = Provider<List<Habit>>(...);
final todayCompletionRateProvider = Provider<int>(...);
```

### 3. Use pagination

```dart
// Already supported - use per_page parameter
await _service.getHabits(
  page: 1,
  perPage: 20,  // Load 20 at a time
);
```

---

## 📚 Resources

- [Riverpod Documentation](https://riverpod.dev)
- [Table Calendar Package](https://pub.dev/packages/table_calendar)
- [Dio Package](https://pub.dev/packages/dio)
- [Flutter Theme Documentation](https://flutter.dev/docs/cookbook/design/themes)
- [Clean Architecture Guide](https://medium.com/@iamvivekkaushik/clean-architecture-in-flutter-4a3c4e41c3b3)

---

## 🎓 Next Steps

1. **Add Notifications**: Implement daily reminders
2. **Add Analytics**: Track most completed habits
3. **Add Sync**: Cloud backup with Firestore
4. **Add Social**: Share habits with friends
5. **Add Insights**: Show trends and patterns
6. **Add Goals**: Tie habits to bigger goals
7. **Add Rewards**: Gamify the experience
8. **Add Export**: Generate habit reports

---

Have fun customizing! 🚀
