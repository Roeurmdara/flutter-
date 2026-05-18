# 🎯 HabitFlow - Modern Habit Tracking App

A beautiful, modern Flutter mobile app for building and tracking daily habits with a stunning UI/UX inspired by Notion, Duolingo, and Habitica.

## 📱 Features Implemented

### ✅ Onboarding System

- Beautiful swipeable intro slides
- 4 motivational screens with illustrations
- Smooth page indicator
- Skip and Next navigation

### ✅ Authentication

- Clean login screen with email/password fields
- Google and Apple OAuth integration (UI ready for API)
- Register new account flow
- "Forgot Password" option
- Terms and conditions acceptance

### ✅ Home Dashboard

- Greeting card with current streak and today's completion count
- Statistics cards (Current Streak, Total Habits, Monthly Progress)
- Today's Habits section with completion tracking
- Weekly progress chart visualization
- Recommendations for new habits
- Pull-to-refresh functionality

### ✅ Bottom Navigation (5 Main Tabs)

1. **Home** - Main dashboard with daily tracking
2. **Categories** - Browse habit categories (Fitness, Study, Health, Productivity, Lifestyle, Mindset)
3. **Community** - Join and view communities
4. **Profile** - User profile with statistics and achievements
5. **Settings** - App preferences and account management

### ✅ Categories Screen

- Grid view of all habit categories
- Category icons and member count
- Quick access to category details

### ✅ Community Screen

- Community discovery and browsing
- Join/leave functionality
- Member count display
- Beautiful community cards

### ✅ Profile Screen

- User avatar and name
- Statistics display (Streak, Total Habits, Badges)
- Achievement/Badge system visualization
- Edit profile option

### ✅ Settings Screen

- Dark/Light mode toggle with persistence
- Notification settings
- Smart reminders toggle
- Account management
- Privacy and language options
- Logout functionality

### ✅ Create Habit Modal

- Bottom sheet modal with draggable handle
- Habit title input
- Category selection dropdown
- Frequency selection (Daily/Weekly/Monthly)
- Create and Cancel buttons

### ✅ Theme System

- **Purple + Green Gradient**: Primary purple (#7C3AED) + Emerald green (#10B981)
- **Light Mode**: Clean white backgrounds with subtle borders
- **Dark Mode**: Deep blue backgrounds (#0F172A) with softer UI
- Soft shadows throughout the app
- Rounded corners (12-16px border radius)
- Smooth animations and transitions

## 📁 Project Structure

```
lib/
├── main.dart                           # App entry point with theme initialization
├── core/
│   ├── constants/
│   │   └── app_constants.dart         # App-wide constants and configuration
│   ├── theme/
│   │   ├── app_colors.dart            # Color palette and theming
│   │   ├── app_typography.dart        # Text styles and typography
│   │   └── app_theme.dart             # Material3 theme data
│   └── router/
│       └── (Prepare for GoRouter integration)
├── data/
│   ├── models/
│   │   ├── habit_model.dart           # Main Habit data model
│   │   ├── user_model.dart            # User profile model
│   │   ├── habit_template_model.dart  # Pre-built habit templates
│   │   └── community_model.dart       # Community and posts models
│   ├── datasources/
│   │   └── (API integration - local & remote)
│   └── repositories/
│       └── (Business logic layer)
├── di/
│   └── (Dependency injection setup)
├── presentation/
│   ├── screens/
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   ├── auth/
│   │   │   └── login_screen.dart      # Login + Register screens
│   │   ├── home/
│   │   │   ├── home_screen.dart       # Main tab navigation
│   │   │   └── home_dashboard_screen.dart
│   │   ├── categories/
│   │   │   └── categories_screen.dart
│   │   ├── community/
│   │   │   └── community_screen.dart
│   │   ├── profile/
│   │   │   └── profile_screen.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   └── habit/
│   │       └── (Habit detail, edit, create screens - ready for expansion)
│   ├── widgets/
│   │   ├── custom_buttons.dart        # Button components (Primary, Secondary, Gradient)
│   │   ├── custom_inputs.dart         # TextField, HabitProgressCard, EmptyState
│   │   └── (Additional reusable widgets)
│   └── providers/
│       └── (State management with Riverpod)
```

## 🎨 Design System

### Colors

- **Primary**: Purple (#7C3AED) - Main action color
- **Secondary**: Green (#10B981) - Accent color
- **Success**: #22C55E (Green)
- **Error**: #EF4444 (Red)
- **Warning**: #F59E0B (Amber)
- **Info**: #0EA5E9 (Blue)

### Typography

- **Display**: Poppins Bold (32px, 28px, 24px)
- **Headlines**: Poppins SemiBold (20px, 18px, 16px)
- **Body**: Inter Regular (16px, 14px, 12px)
- **Labels**: Poppins Medium (14px, 12px, 11px)

### Component Spacing

- Padding: 16px (default), 24px (sections)
- Border Radius: 12px (inputs, buttons), 16px (cards)
- Shadow: Soft shadows with 10% black opacity

## 🚀 Getting Started

### Prerequisites

- Flutter 3.0+
- Dart 3.0+
- VS Code or Android Studio

### Installation

1. **Clone the repository**

```bash
cd c:\dev\projects\flutter001\flutter001
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run the app**

```bash
flutter run
```

### Testing

- Onboarding flows automatically when first launched
- Use login credentials: (email/password required for API integration)
- All navigation and UI is functional without backend

## 📡 API Integration Ready

The app structure is prepared for Laravel API integration:

### API Endpoints Structure

```
Base URL: https://api.habitflow.local/api/v1

Auth:
- POST /auth/register
- POST /auth/login
- POST /auth/logout

Habits:
- GET /habits (list user habits)
- POST /habits (create habit)
- GET /habits/:id (get habit detail)
- PUT /habits/:id (update habit)
- DELETE /habits/:id (delete habit)
- POST /habits/:id/complete (mark complete)

Templates:
- GET /templates (list habit templates)
- GET /templates/:category (templates by category)

Community:
- GET /communities (list communities)
- POST /communities/:id/join (join community)
- GET /communities/:id/feed (community posts)
- POST /communities/:id/posts (create post)

Profile:
- GET /user/profile (get user info)
- PUT /user/profile (update profile)
- GET /user/achievements (badges/achievements)
```

### Models Ready for API

1. **Habit Model** - Complete with JSON serialization
   - Includes computed properties (completion rate, isCompletedToday)
   - Streak tracking and completion dates

2. **User Model** - Full user information
   - Preferences storage
   - Achievement system

3. **HabitTemplate Model** - Pre-built templates
   - Category, difficulty, tips
   - Usage statistics

4. **Community Model** - Social features
   - Community posts and comments
   - Member count and join status

## 🔧 How to Extend

### Adding a New Screen

1. Create screen file in `presentation/screens/[feature]/[feature]_screen.dart`
2. Implement `StatefulWidget` or `StatelessWidget`
3. Use existing theme and typography
4. Add route to navigation

### Adding a New Model

1. Create model file in `data/models/[model]_model.dart`
2. Implement `fromJson()` and `toJson()` methods
3. Add copyWith() for immutability

### State Management (Ready for API)

Currently using `provider` package. To implement:

```dart
// Example provider for habits
final habitsProvider = FutureProvider((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabits();
});
```

### Database Integration

SQLite is configured. To implement local caching:

1. Create database helper in `data/datasources/local_database.dart`
2. Use SQFLite to cache API responses
3. Implement offline-first architecture

## 📊 Key Files

| File                                     | Purpose                                    |
| ---------------------------------------- | ------------------------------------------ |
| `lib/core/constants/app_constants.dart`  | App configuration, routes, habit templates |
| `lib/core/theme/app_colors.dart`         | Color palette                              |
| `lib/core/theme/app_typography.dart`     | Text styles                                |
| `lib/main.dart`                          | App initialization and routing             |
| `lib/data/models/*.dart`                 | Data models with JSON serialization        |
| `lib/presentation/widgets/custom_*.dart` | Reusable UI components                     |

## 🎯 Next Steps (Ready to Build)

1. **Set up API integration**
   - Create `data/datasources/api_service.dart` using Dio
   - Implement auth interceptors

2. **Add repositories**
   - Create `data/repositories/habit_repository.dart`
   - Implement CRUD operations

3. **Implement state management**
   - Set up Riverpod providers for each feature
   - Connect to API repositories

4. **Add detailed screens**
   - Habit detail page with calendar view
   - Edit habit screen
   - Daily tracking with animations
   - Statistics and analytics screens
   - Community feed and post creation

5. **Local storage**
   - Implement SQLite caching
   - Offline support

6. **Testing**
   - Unit tests for models and repositories
   - Widget tests for screens
   - Integration tests with mock API

## 🎬 User Flow

```
App Start
  ↓
Has Seen Onboarding? → No → Onboarding Screen (4 slides)
  ↓ Yes
Is Logged In? → No → Login/Register Screen
  ↓ Yes
Home Screen (5 Tabs)
├── Home Dashboard (main tracking interface)
├── Categories (browse habit templates)
├── Community (social features)
├── Profile (user stats and achievements)
└── Settings (preferences and account)
```

## 🛠️ Technology Stack

- **Framework**: Flutter 3.0+
- **State Management**: Riverpod (prepared), Provider (current)
- **Navigation**: GoRouter (prepared)
- **HTTP Client**: Dio
- **Local Storage**: SQLite, SharedPreferences
- **UI**: Material 3, Google Fonts
- **Animations**: Flutter Animate, Lottie
- **Charts**: FL Chart

## 📝 Notes

- All screens support both light and dark modes
- Typography and colors are centralized for easy theme updates
- Widgets are reusable and well-organized
- Project structure follows clean architecture principles
- Ready for API integration with Laravel backend
- No hardcoded values (using AppConstants)

## 🚀 Deployment

### Build APK (Android)

```bash
flutter build apk
```

### Build AAB (Android App Bundle)

```bash
flutter build appbundle
```

### Build iOS

```bash
flutter build ios
```

### Build Web

```bash
flutter build web
```

## 📄 License

This project is created as a modern habit tracking application with professional UI/UX.

## 🤝 Support

For questions or issues, refer to the code comments and structure. The project is well-documented and ready for team collaboration.

---

**Made with ❤️ for habit building and personal growth.**
