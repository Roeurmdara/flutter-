# Habit Tracker Implementation Guide

## 🎯 Overview

Your Flutter habit tracking app now has a complete CRUD system with calendar navigation, dark mode support, and API integration with the habit-api.rattanakmony.com backend.

## 📁 Files Created/Modified

### Data Layer

#### 1. **HabitService** (`lib/data/services/habit_service.dart`)

- Handles all API calls to the habit API
- Methods:
  - `createHabit()` - POST new habit
  - `getHabits()` - GET habits with pagination
  - `getHabit()` - GET specific habit
  - `updateHabit()` - PUT update habit
  - `markHabitAsDone()` - POST mark complete
  - `unmarkHabitAsDone()` - DELETE unmark
  - `deleteHabit()` - DELETE habit

#### 2. **HabitProvider** (`lib/data/providers/habit_provider.dart`)

- Riverpod state management for habits
- **HabitsNotifier** - Main state management class
- **HabitState** - Contains:
  - List of habits
  - Loading/updating states
  - Selected date
  - Completion status tracking
- **Computed Providers**:
  - `habitsForDateProvider` - Filters habits by selected date
  - `todayCompletionRateProvider` - Calculates completion percentage

### UI Layer

#### 3. **UpdatedHomeDashboardScreen** (`lib/presentation/screens/home/home_dashboard_screen.dart`)

- Main dashboard with:
  - ✅ Calendar date picker (table_calendar)
  - ✅ Forward/backward date navigation
  - ✅ Habit list for selected date
  - ✅ Completion statistics
  - ✅ Dark mode support
  - ✅ Empty state handling
  - ✅ Error state handling

#### 4. **HabitCardWidget** (`lib/presentation/widgets/habit_card_widget.dart`)

- Individual habit card displaying:
  - Checkbox (mark as done/incomplete)
  - Habit title with strikethrough when complete
  - Frequency badge (Daily/Weekly/Monthly)
  - Category badge with color coding
  - Current streak counter
  - Completion progress bar
  - Edit/Delete options (long press)

#### 5. **CreateHabitModal** (`lib/presentation/widgets/create_habit_modal.dart`)

- Modal for creating and editing habits
- Features:
  - Title input
  - Description input
  - Category selector (Health, Fitness, Learning, Productivity, Personal)
  - Frequency selector (Daily, Weekly, Monthly)
  - Start date picker
  - End date picker (optional)
  - Create/Update buttons

## 🚀 Features Implemented

### Calendar & Date Navigation

```
- Click date button to toggle calendar
- Click specific date to jump to that date
- Arrow buttons for previous/next day
- Real-time UI updates when date changes
```

### Habit Management

```
✅ Create habits with:
  - Title, description
  - Frequency (daily/weekly/monthly)
  - Start and end dates
  - Category and visibility

✅ Read habits:
  - Filter by selected date
  - Check frequency rules (daily/weekly/monthly)
  - Display completion status

✅ Update habits:
  - Edit title, description, frequency
  - Change dates
  - Update category

✅ Delete habits:
  - With confirmation dialog
  - Removes from UI immediately
```

### Habit Tracking

```
✅ Mark habits as done/incomplete for any date
✅ Track completion streaks
✅ Calculate completion rate (daily/overall)
✅ Visual indicators (checkmark, green border, progress bar)
```

### UI/UX Features

```
✅ Dark mode support throughout
✅ Color-coded categories
✅ Smooth transitions
✅ Loading states
✅ Error handling
✅ Empty state messaging
✅ Completion progress visualization
```

## 🔌 API Integration

### Base URL

```
https://habit-api.rattanakmony.com/api/v1
```

### Endpoints Used

#### Create Habit

```
POST /habits
Body: {
  "category_id": "uuid",
  "title": "string",
  "description": "string",
  "status": "created",
  "frequency_type": "daily|weekly|monthly",
  "frequency_config": ["string"],
  "goal_type": "binary",
  "target_value": 0,
  "target_unit": "string",
  "start_date": "2026-05-21T09:04:39.136Z",
  "end_date": "2026-05-21T09:04:39.136Z",
  "visibility": "private"
}
```

#### Get Habits

```
GET /habits?page=1&per_page=10&status=created&category_id=uuid
```

#### Mark as Done

```
POST /habits/{habitId}/mark-done
Body: {
  "date": "2026-05-21"
}
```

#### Unmark as Done

```
DELETE /habits/{habitId}/mark-done
Body: {
  "date": "2026-05-21"
}
```

#### Update Habit

```
PUT /habits/{habitId}
Body: { ...updated fields }
```

#### Delete Habit

```
DELETE /habits/{habitId}
```

## 💾 State Management (Riverpod)

### Main Provider

```dart
final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitState>
```

### Usage in UI

```dart
// Watch entire habit state
final habitState = ref.watch(habitsProvider);

// Watch habits for selected date
final habitsForDate = ref.watch(habitsForDateProvider);

// Watch today's completion rate
final completionRate = ref.watch(todayCompletionRateProvider);

// Create habit
await ref.read(habitsProvider.notifier).createHabit(...);

// Mark as done
await ref.read(habitsProvider.notifier).markHabitAsDone(habitId, date);

// Delete habit
await ref.read(habitsProvider.notifier).deleteHabit(habitId);
```

## 🎨 Dark Mode

The implementation fully supports dark mode:

- `AppColors.darkSurface`, `AppColors.darkBackground`, `AppColors.darkBorder` for dark theme
- `AppColors.lightSurface`, `AppColors.lightBackground`, `AppColors.lightBorder` for light theme
- Automatic theme detection: `Theme.of(context).brightness == Brightness.dark`

## 📱 User Flow

### Create Habit

1. User taps FAB on Home tab
2. CreateHabitModal appears
3. User enters habit details
4. Tap Create → API call → Habit added to list

### View Habits by Date

1. User taps date button → Calendar opens
2. User clicks desired date or uses arrow buttons
3. Habits for that date automatically display
4. Respects frequency rules (daily, weekly, monthly)

### Mark Habit Complete

1. User taps checkbox on habit card
2. Calls `markHabitAsDone()` → API updates
3. Card shows green border + checkmark + "Done" badge
4. Completion rate updates

### Edit Habit

1. User long-presses habit card
2. Options menu appears (Edit/Delete)
3. Tap Edit → CreateHabitModal opens with pre-filled data
4. Update and submit

### Delete Habit

1. Long-press habit card → Options menu
2. Tap Delete → Confirmation dialog
3. Confirm → Habit deleted from API and UI

## ⚙️ Configuration

### Required Packages (already in pubspec.yaml)

```yaml
flutter_riverpod: ^2.5.1
table_calendar: ^3.1.0
intl: ^0.19.0
dio: ^5.4.1
uuid: ^4.0.0
```

### API Configuration

The DIO client is initialized in HabitService:

```dart
final Dio _dio;
static const String _baseUrl = 'https://habit-api.rattanakmony.com/api/v1';
```

## 🐛 Error Handling

- **API Errors**: Displayed in snackbars and error state in UI
- **Validation**: Empty title check before create
- **Network**: Dio automatically handles connection errors
- **State**: Error message persists until cleared

## 📊 Statistics Displayed

- **Total Habits**: Count of habits for selected date
- **Completed**: Count of completed habits
- **Progress %**: (Completed / Total) \* 100
- **Completion Rate**: Shown in greeting card

## 🔄 Frequency Logic

Habits show on the selected date if:

- **Daily**: Always show (if within start/end dates)
- **Weekly**: Show if weekday matches start date's weekday
- **Monthly**: Show if day of month matches start date's day

## 📝 Next Steps (Optional)

1. **Notifications**: Add `flutter_local_notifications` for daily reminders
2. **Habit Templates**: Pre-built habit suggestions
3. **Analytics**: Weekly/monthly progress charts
4. **Goals**: Target values and tracking
5. **Social**: Share habits with community
6. **Export**: CSV export of habit data

## 🎓 Testing the Implementation

### Test Create Habit

```dart
await ref.read(habitsProvider.notifier).createHabit(
  categoryId: 'test-category',
  title: 'Test Habit',
  description: 'Test Description',
  frequencyType: 'daily',
  frequencyConfig: ['daily'],
  goalType: 'binary',
  targetValue: 1,
  targetUnit: 'completion',
  startDate: DateTime.now(),
  visibility: 'private',
);
```

### Test Mark Complete

```dart
await ref.read(habitsProvider.notifier).markHabitAsDone(
  'habit-id',
  DateTime.now(),
);
```

### Test Date Navigation

```dart
ref.read(habitsProvider.notifier).selectDate(
  DateTime.now().add(Duration(days: 1))
);
```

## 🎉 Summary

Your habit tracking app now has:

- ✅ Full CRUD operations for habits
- ✅ Calendar date navigation
- ✅ Completion tracking and streaks
- ✅ Dark mode support
- ✅ Professional UI/UX
- ✅ Robust error handling
- ✅ Efficient state management with Riverpod
- ✅ API integration ready to go

The system is production-ready and can handle real-world usage patterns!
