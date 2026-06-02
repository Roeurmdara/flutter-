# 🎯 Habit Template System - Implementation Guide

## Overview

This is a complete habit template discovery and management system that allows users to:

- **Browse** templates with search and filtering
- **View Details** to understand template requirements
- **Edit Templates** to customize them
- **Use Templates** to quickly create new habits

## 📁 File Structure

```
lib/
├── data/
│   └── providers/
│       └── template_provider.dart          # Main template state management
│
└── presentation/
    └── screens/
        └── discover/
            ├── discover_templates_screen.dart    # Main templates list
            ├── template_detail_screen.dart       # Full template details
            └── template_edit_screen.dart         # Edit template form
```

## 🚀 Quick Start - How to Integrate

### 1. Add Route to Your Router

If using `go_router`, add this to your route configuration:

```dart
GoRoute(
  path: '/discover/templates',
  builder: (context, state) => const DiscoverTemplatesScreen(),
  routes: [
    GoRoute(
      path: 'detail',
      builder: (context, state) => const TemplateDetailScreen(),
    ),
    GoRoute(
      path: 'edit',
      builder: (context, state) {
        final template = state.extra as HabitTemplate?;
        return template != null
          ? TemplateEditScreen(template: template)
          : const Scaffold(body: Center(child: Text('No template')));
      },
    ),
  ],
)
```

### 2. Add Navigation Button

Add a button in your home, community, or discover page to navigate:

```dart
// In your screen
ElevatedButton(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DiscoverTemplatesScreen(),
      ),
    );
  },
  child: const Text('Browse Templates'),
)

// Or with go_router
ElevatedButton(
  onPressed: () => context.go('/discover/templates'),
  child: const Text('Browse Templates'),
)
```

### 3. Access in Community/Discover Tab

Update your community or discover screen to include templates:

```dart
DefaultTabController(
  length: 2,
  child: Column(
    children: [
      TabBar(
        tabs: const [
          Tab(text: 'Communities'),
          Tab(text: 'Templates'),
        ],
      ),
      Expanded(
        child: TabBarView(
          children: [
            CommunityScreen(),
            DiscoverTemplatesScreen(),  // Add templates here
          ],
        ),
      ),
    ],
  ),
)
```

## 📊 Provider Usage

### Watch Templates

```dart
final templates = ref.watch(allTemplatesProvider);
final filtered = ref.watch(filteredTemplatesProvider);
final selected = ref.watch(selectedTemplateProvider);
```

### Perform Actions

```dart
final notifier = ref.read(templateProvider.notifier);

// Filter by category
notifier.setCategory('fitness');

// Select template
notifier.selectTemplate('tpl_001');

// Update template
await notifier.updateTemplate(updatedTemplate);

// Increment usage
await notifier.incrementUsageCount('tpl_001');

// Delete template
await notifier.deleteTemplate('tpl_001');

// Search
final results = notifier.searchTemplates('running');
```

## 🎨 Template Data Structure

```dart
HabitTemplate(
  id: 'tpl_001',
  title: 'Morning Run',
  description: 'Start your day with a refreshing run',
  category: 'fitness',           // fitness, learning, health, etc.
  icon: '🏃',                     // emoji icon
  color: '#FF6B6B',               // hex color
  difficulty: 'medium',           // easy, medium, hard
  recommendedFrequency: 'daily',  // daily, 2x per week, etc.
  recommendedDuration: 30,        // minutes
  tips: 'Start slow, increase gradually',
  usageCount: 234,                // auto-tracked
  tags: ['cardio', 'morning', 'outdoor'],
)
```

## 🔄 Workflow: From Template to Habit

```
1. User browsing templates
   ↓
2. Click "Use Template" button
   ↓
3. Usage count incremented
   ↓
4. Show confirmation message
   ↓
5. Navigate to Create Habit page
   ↓
6. Pre-fill form with template data
   ↓
7. User customizes and creates habit
```

## 🎯 Key Features Explained

### Search & Filter

- Real-time search by title, description, or tags
- Category-based filtering
- Combined search + filter results

### Template Card

Shows at a glance:

- Template icon, title, category
- Usage count badge
- Difficulty level
- Frequency & duration
- Tags (first 2 + count)
- Edit & Use buttons

### Template Details

Complete information:

- Full description
- Tips section
- All tags
- Recommended values
- Usage statistics

### Edit Template

Customize:

- Title, description
- Difficulty & frequency
- Duration (slider: 1-180 min)
- Category & icon picker
- Color picker (8 colors)
- Tips text
- Tags management

## 📱 UI/UX Highlights

✨ **Beautiful Cards** - Gradient backgrounds, icons, colored badges
✨ **Smooth Navigation** - Material transitions between screens
✨ **Dark Mode Support** - All screens adapt to theme
✨ **Intuitive Controls** - Sliders, pickers, chips
✨ **Responsive Design** - Works on all screen sizes
✨ **Empty States** - Shows helpful message when no results

## 🔌 Connecting to Backend (Optional)

Replace the mock data with API calls in `template_provider.dart`:

```dart
class TemplateNotifier extends StateNotifier<TemplateState> {
  final TemplateService service;

  Future<void> _loadTemplates() async {
    state = state.copyWith(isLoading: true);
    try {
      final templates = await service.fetchTemplates();
      state = state.copyWith(
        templates: templates,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateTemplate(HabitTemplate updated) async {
    await service.updateTemplate(updated);
    // Update local state
  }
}
```

## 🎓 Sample Scenarios

### Scenario 1: Fitness User

1. Open Discover Templates
2. Filter by "Fitness"
3. See "Morning Run", "Workout", etc.
4. Click on "Morning Run"
5. View full details and tips
6. Click "Use Template"
7. Create habit with pre-filled values

### Scenario 2: Learner

1. Search "coding"
2. Find "Study Coding" template
3. Edit to increase duration to 60 min
4. Save changes
5. Use it to create habit

### Scenario 3: Community Share

1. User creates popular template
2. Share in community
3. Others discover and use it
4. Track usage count

## 🛠️ Customization Options

### Change Sample Data

Edit `_sampleTemplates` in `template_provider.dart` to add your templates.

### Add More Categories

Update category filter in `discover_templates_screen.dart`:

```dart
_buildCategoryChip('new-category', '🎯 New Category'),
```

### Modify Colors

Edit color picker in `template_edit_screen.dart`:

```dart
'#FF6B6B',  // Add/remove colors
'#10B981',
// ...
```

### Customize UI

All screens use:

- `AppColors` - centralized color system
- `AppTypography` - typography styles
- Easy to theme or reskin

## 📊 Analytics & Tracking

The system automatically tracks:

- Template usage count
- Last modified time
- Popular templates (by usage)
- Search queries (if needed)

Access this data:

```dart
final popular = templates.sorted((a, b) => b.usageCount.compareTo(a.usageCount));
```

## 🐛 Debugging Tips

Enable debug logging:

```dart
// In template_provider.dart
print('Loading templates...');
print('Templates loaded: ${state.templates.length}');
print('Filtered: ${state.filteredTemplates.length}');
```

Test without API:

- System uses mock data by default
- Modify `_sampleTemplates` to test different scenarios
- UI works offline

## ✅ Testing Checklist

- [ ] Search works with multiple keywords
- [ ] Category filter switches correctly
- [ ] Template detail shows all info
- [ ] Edit form saves changes
- [ ] Usage count increments on use
- [ ] Dark mode looks good
- [ ] Navigation is smooth
- [ ] No console errors

## 🚀 Future Enhancements

Potential additions:

- [ ] Share templates to community
- [ ] Rate/review templates
- [ ] Create custom templates
- [ ] Duplicate templates
- [ ] Export/import templates
- [ ] Template recommendations based on user
- [ ] Trending templates widget
- [ ] Template preview animation
- [ ] Batch operations
- [ ] API integration
