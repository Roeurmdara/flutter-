# 🏗️ HabitFlow App Architecture & Navigation Flow

## 📊 Complete Navigation Map

```
┌─────────────────────────────────────────────────────────────┐
│                      APP INITIALIZATION                     │
│                    (lib/main.dart)                          │
│  • Initializes SharedPreferences                            │
│  • Checks onboarding status                                 │
│  • Checks login status                                      │
│  • Determines initial route                                 │
└──────────────┬──────────────────────────────────────────────┘
               │
       ┌───────┴──────────┬──────────────────┐
       │                  │                  │
       ▼                  ▼                  ▼
   ❓ First       ❓ Has Token      ❓ Has Token
   Time?          & Seen Onboarding?
   │              │                  │
   │ YES          │ NO               │ YES
   │              │                  │
   ▼              ▼                  ▼
┌──────────┐  ┌──────────┐      ┌───────────────┐
│Onboarding│→ │  Login/  │  → │ Home Screen   │
│  Screen  │  │ Register │     │  (5 Tabs)     │
└──────────┘  └──────────┘      └───────────────┘
```

---

## 🗺️ Home Navigation Structure

```
HOME SCREEN (lib/presentation/screens/home/home_screen.dart)
├─ Bottom Navigation Bar (5 Tabs)
│  └─ Current Tab Index = 0 (default)
│
├─ Tab 0: HOME ─────────────────────────────────────────┐
│  │                                                    │
│  ├─ HomeDashboardScreen (lib/.../home_dashboard...)  │
│  │  ├─ Greeting Card                                 │
│  │  ├─ Statistics Cards (3)                          │
│  │  ├─ Today's Habits (HabitProgressCard x 3)        │
│  │  ├─ Weekly Chart                                  │
│  │  └─ Recommendations                               │
│  │                                                    │
│  └─ FAB: "New Habit" (Tab 0 only)                     │
│     └─ Triggers CreateHabitModal                      │
│                                                       │
├─ Tab 1: CATEGORIES ───────────────────────────────────┤
│  │                                                    │
│  └─ CategoriesScreen (lib/.../categories_screen)     │
│     ├─ Fitness (💪)                                   │
│     ├─ Study (📚)                                     │
│     ├─ Health (🏥)                                    │
│     ├─ Productivity (⚡)                              │
│     ├─ Lifestyle (🌟)                                │
│     └─ Mindset (🧠)                                   │
│                                                       │
├─ Tab 2: COMMUNITY ────────────────────────────────────┤
│  │                                                    │
│  └─ CommunityScreen (lib/.../community_screen)       │
│     ├─ Community Card 1 (with Join button)           │
│     ├─ Community Card 2 (with Join button)           │
│     ├─ Community Card 3 (with Join button)           │
│     └─ Community Card 4 (with Join button)           │
│                                                       │
├─ Tab 3: PROFILE ─────────────────────────────────────┤
│  │                                                    │
│  └─ ProfileScreen (lib/.../profile_screen)           │
│     ├─ User Avatar & Name                            │
│     ├─ Statistics (Streak, Total, Badges)            │
│     └─ Achievements Section                          │
│                                                       │
└─ Tab 4: SETTINGS ────────────────────────────────────┘
   │
   └─ SettingsScreen (lib/.../settings_screen)
      ├─ Appearance (Dark/Light toggle)
      ├─ Notifications (toggles)
      ├─ Account Management
      ├─ Privacy & Language
      └─ Logout Button
```

---

## 📁 File Hierarchy & Responsibilities

### Core System Layer

```
lib/core/
├── constants/
│   └── app_constants.dart
│       • API endpoints (base URL, routes)
│       • App metadata (version, names)
│       • Habit categories list
│       • Frequencies (Daily/Weekly/Monthly)
│       • Reminder times
│       • SharedPreferences keys
│       • Notification and preferences keys
│
├── theme/
│   ├── app_colors.dart
│   │   • Color palette (light & dark modes)
│   │   • Gradient definitions
│   │   • Shadow colors
│   │
│   ├── app_typography.dart
│   │   • Text styles (display, headline, body, etc.)
│   │   • Uses GoogleFonts (Poppins, Inter)
│   │
│   └── app_theme.dart
│       • Material 3 theme configuration
│       • lightTheme() function
│       • darkTheme() function
│       • Component styling (buttons, cards, inputs)
│
└── router/ (Prepared for GoRouter)
    └── (Routes configuration when needed)
```

### Data Layer

```
lib/data/
├── models/
│   ├── habit_model.dart (✅ Complete)
│   │   • id, userId, title, category, icon, color
│   │   • frequency, duration, reminderTime, notes
│   │   • createdAt, startDate, endDate
│   │   • isActive, isArchived, currentStreak, bestStreak
│   │   • completedDates (list of dates)
│   │   • Computed: completionRate(), isCompletedToday()
│   │   • Methods: fromJson(), toJson(), copyWith()
│   │
│   ├── user_model.dart (✅ Complete)
│   │   • id, email, username, fullName, avatar, bio
│   │   • createdAt, lastLogin, emailVerified
│   │   • totalStreak, totalHabits, completedToday
│   │   • achievements, preferences
│   │
│   ├── habit_template_model.dart (✅ Complete)
│   │   • 9 pre-built templates (Run, Drink Water, etc.)
│   │   • icon, color, difficulty, frequency, tips
│   │
│   └── community_model.dart (✅ Complete)
│       • Community (id, name, description, members)
│       • CommunityPost (content, likes, comments)
│       • PostComment (content, likes)
│
├── datasources/
│   ├── api_service.dart (📋 Ready to create)
│   │   • Dio HTTP client with interceptors
│   │   • Auth token management
│   │   • Error handling
│   │   • Generic GET/POST/PUT/DELETE methods
│   │
│   └── local_database.dart (📋 Ready to create)
│       • SQLite integration via sqflite
│       • Offline caching
│       • Local CRUD operations
│
└── repositories/
    ├── auth_repository.dart (📋 Ready to create)
    │   • login(email, password)
    │   • register(email, password, etc.)
    │   • logout()
    │   • Token management
    │
    ├── habit_repository.dart (📋 Ready to create)
    │   • getHabits(), getHabit(id)
    │   • createHabit(), updateHabit(), deleteHabit()
    │   • markComplete(), getCompletedDates()
    │
    ├── user_repository.dart (📋 Ready to create)
    │   • getProfile(), updateProfile()
    │   • getAchievements()
    │
    └── community_repository.dart (📋 Ready to create)
        • getCommunities(), joinCommunity()
        • getFeeds(), createPost()
```

### Presentation Layer

```
lib/presentation/
├── screens/
│   ├── onboarding/
│   │   └── onboarding_screen.dart (✅ Complete)
│   │       • 4 swipeable slides
│   │       • SmoothPageIndicator
│   │       • Skip/Next navigation
│   │
│   ├── auth/
│   │   └── login_screen.dart (✅ Complete)
│   │       • LoginScreen: Email/password fields
│   │       • RegisterScreen: Name/email/password
│   │       • Password visibility toggle
│   │       • Terms checkbox (register only)
│   │       • Social auth buttons
│   │
│   ├── home/
│   │   ├── home_screen.dart (✅ Complete)
│   │   │   • 5-tab BottomNavigationBar
│   │   │   • Tab switching logic
│   │   │   • CreateHabitModal (DraggableScrollableSheet)
│   │   │   • FAB (New Habit) - Tab 0 only
│   │   │
│   │   └── home_dashboard_screen.dart (✅ Complete)
│   │       • Greeting card with streak
│   │       • Statistics cards (3)
│   │       • Today's habits list
│   │       • Weekly progress chart
│   │       • Recommendations section
│   │       • RefreshIndicator
│   │
│   ├── categories/
│   │   └── categories_screen.dart (✅ Complete)
│   │       • 6 category cards (GridView)
│   │       • Icon + name + member count
│   │       • Tapable for details
│   │
│   ├── community/
│   │   └── community_screen.dart (✅ Complete)
│   │       • 4 community cards (ListView)
│   │       • Join/Joined button
│   │       • Member count display
│   │
│   ├── profile/
│   │   └── profile_screen.dart (✅ Complete)
│   │       • User avatar + info
│   │       • Statistics boxes (3)
│   │       • Achievement badges (4)
│   │
│   ├── settings/
│   │   └── settings_screen.dart (✅ Complete)
│   │       • Appearance (dark/light toggle)
│   │       • Notifications settings
│   │       • Account management
│   │       • Language & Privacy
│   │       • Logout with confirmation
│   │
│   └── habit/ (📋 Ready to create)
│       ├── habit_detail_screen.dart
│       │   • Habit info display
│       │   • Calendar view of completions
│       │   • Edit/Delete buttons
│       │
│       ├── daily_tracking_screen.dart
│       │   • Mark complete button
│       │   • Add notes/mood
│       │   • Success animation
│       │
│       ├── timeline_screen.dart
│       │   • Calendar/heatmap view
│       │   • Completion patterns
│       │
│       └── statistics_screen.dart
│           • Charts using fl_chart
│           • Weekly/monthly trends
│           • Performance analytics
│
├── widgets/
│   ├── custom_buttons.dart (✅ Complete)
│   │   • PrimaryButton (solid purple)
│   │   • SecondaryButton (outlined)
│   │   • CustomTextButton (text-only)
│   │   • GradientButton (purple→green)
│   │
│   ├── custom_inputs.dart (✅ Complete)
│   │   • CustomTextField (with validation)
│   │   • HabitProgressCard (habit display)
│   │   • EmptyState (no data message)
│   │
│   └── (Additional widgets 📋 Ready to create)
│       • HabitDetailCard
│       • StatisticsCard
│       • CalendarHeatmap
│       • NotificationCard
│
├── providers/ (📋 Ready to create)
│   ├── auth_provider.dart
│   │   • loginProvider
│   │   • registerProvider
│   │   • currentUserProvider
│   │
│   ├── habit_provider.dart
│   │   • habitsProvider (get all)
│   │   • habitProvider (get single)
│   │   • createHabitProvider
│   │   • updateHabitProvider
│   │
│   ├── user_provider.dart
│   │   • userProfileProvider
│   │   • achievementsProvider
│   │
│   └── community_provider.dart
│       • communitiesProvider
│       • communityFeedProvider
│
└── di/ (📋 Ready to create)
    └── providers.dart (Dependency injection setup)
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                          │
│                   (UI - Widgets/Screens)                        │
└─────────────────┬───────────────────────────────────────────────┘
                  │ Displays/Updates UI
                  │ User interactions
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PROVIDER LAYER                               │
│              (State Management - Riverpod)                      │
└─────────────────┬───────────────────────────────────────────────┘
                  │ Provides data streams
                  │ Handles async operations
                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                   REPOSITORY LAYER                              │
│          (Business Logic - Data Orchestration)                  │
└─────────────────┬───────────────────────────────────────────────┘
                  │ Aggregates data from sources
                  │ Handles error conversion
                  ▼
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
┌──────────────────────────┐  ┌──────────────────────────┐
│ DATASOURCE LAYER         │  │ DATASOURCE LAYER         │
│ (Remote - API Service)   │  │ (Local - SQLite)         │
│                          │  │                          │
│ • ApiService (Dio)       │  │ • LocalDatabase (sqflite)│
│ • HTTP calls             │  │ • Offline cache          │
│ • Auth interceptor       │  │ • Local CRUD             │
│ • Error handling         │  │ • Sync status            │
└──────────────┬───────────┘  └──────────────┬───────────┘
               │                             │
               ▼                             ▼
        ┌─────────────┐            ┌─────────────┐
        │  LARAVEL    │            │   SQLITE    │
        │    API      │            │  DATABASE   │
        └─────────────┘            └─────────────┘
```

---

## 🎯 State Management Strategy

### Current Implementation: Provider + StatefulWidget

```
StatefulWidget
  │
  └─ setState()
     └─ Triggers rebuild
        └─ UI updates
```

### Ready for Upgrade: Riverpod

```
Screen (ConsumerWidget)
  │
  └─ FutureProvider / StateNotifierProvider
     │
     ├─ Fetches data from Repository
     │  │
     │  └─ Repository calls DataSource
     │
     └─ Rebuilds when data changes
```

---

## 🌓 Theme System Architecture

```
Theme Selection
    │
    ├─ Light Mode
    │  ├─ AppColors.lightText: #1F2937
    │  ├─ AppColors.lightSurface: #F9FAFB
    │  ├─ AppColors.lightBackground: #F3F4F6
    │  └─ Gradient: Purple → Green (bright)
    │
    └─ Dark Mode
       ├─ AppColors.darkText: #F3F4F6
       ├─ AppColors.darkSurface: #1F2937
       ├─ AppColors.darkBackground: #0F172A
       └─ Gradient: Purple → Green (muted)
```

---

## 📦 Build Configuration

### pubspec.yaml Dependencies

```
Included:
  flutter_riverpod    - State management (prepared)
  go_router          - Navigation (prepared)
  dio                - HTTP client (prepared)
  sqflite            - Local database (prepared)
  google_fonts       - Typography
  flutter_animate    - Animations
  smooth_page_indicator
  lottie             - Animated graphics
  table_calendar     - Calendar widget
  fl_chart           - Charts (prepared)
  provider           - State management (current)
  shared_preferences - Local preferences
  uuid               - ID generation
  permission_handler - Permissions
  image_picker       - Image selection
```

---

## ✅ Feature Completion Status

| Component            | Status      | Location                                         |
| -------------------- | ----------- | ------------------------------------------------ |
| Theme System         | ✅ Complete | `lib/core/theme/`                                |
| Data Models          | ✅ Complete | `lib/data/models/`                               |
| Onboarding           | ✅ Complete | `lib/presentation/screens/onboarding/`           |
| Authentication       | ✅ Complete | `lib/presentation/screens/auth/`                 |
| Home Dashboard       | ✅ Complete | `lib/presentation/screens/home/`                 |
| Navigation           | ✅ Complete | `lib/presentation/screens/home/home_screen.dart` |
| Categories           | ✅ Complete | `lib/presentation/screens/categories/`           |
| Community            | ✅ Complete | `lib/presentation/screens/community/`            |
| Profile              | ✅ Complete | `lib/presentation/screens/profile/`              |
| Settings             | ✅ Complete | `lib/presentation/screens/settings/`             |
| Custom Widgets       | ✅ Complete | `lib/presentation/widgets/`                      |
| API Service          | 📋 Planned  | `lib/data/datasources/`                          |
| Repositories         | 📋 Planned  | `lib/data/repositories/`                         |
| Providers (Riverpod) | 📋 Planned  | `lib/presentation/providers/`                    |
| Local Storage        | 📋 Planned  | `lib/data/datasources/`                          |

---

## 🚀 Next Development Phases

### Phase 1: State Management (In Progress)

- [ ] Set up Riverpod providers
- [ ] Connect screens to providers
- [ ] Implement state persistence

### Phase 2: API Integration

- [ ] Implement ApiService with Dio
- [ ] Create repositories for each feature
- [ ] Connect providers to repositories
- [ ] Implement authentication flow

### Phase 3: Advanced Features

- [ ] Habit detail screen with calendar
- [ ] Daily tracking with animations
- [ ] Analytics and statistics screens
- [ ] Community feed and interactions

### Phase 4: Polish & Deployment

- [ ] Error states and validation
- [ ] Loading indicators
- [ ] Success animations
- [ ] Performance optimization
- [ ] Build for Android/iOS

---

**This architecture is designed for scalability, maintainability, and easy API integration!** 🎉
