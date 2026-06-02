# 🎯 Habit Template System - Quick Reference

## 📍 Where to Find Everything

### Core Files

```
lib/
├── data/providers/
│   └── template_provider.dart              ← State management & sample data
│
└── presentation/screens/discover/
    ├── discover_templates_screen.dart      ← Main browse interface
    ├── template_detail_screen.dart         ← Full template info
    └── template_edit_screen.dart           ← Edit template form
```

### Documentation

```
├── TEMPLATE_SYSTEM_GUIDE.md                ← Implementation guide
├── TEMPLATE_INTEGRATION_EXAMPLES.dart      ← 6 code examples
├── TEMPLATE_SYSTEM_SUMMARY.md              ← Complete overview
└── TEMPLATE_QUICK_REFERENCE.md             ← This file
```

---

## 🚀 Quick Start (30 seconds)

### 1. Import the screen

```dart
import 'presentation/screens/discover/discover_templates_screen.dart';
```

### 2. Add navigation

```dart
// Option A: Direct navigation
ElevatedButton(
  onPressed: () => Navigator.push(context,
    MaterialPageRoute(builder: (_) => const DiscoverTemplatesScreen())
  ),
  child: const Text('Browse Templates'),
)

// Option B: In navigation bar
IconButton(
  icon: const Icon(Icons.bookmark),
  onPressed: () => Navigator.push(context,
    MaterialPageRoute(builder: (_) => const DiscoverTemplatesScreen())
  ),
)
```

### 3. That's it! 🎉

Templates are ready to use with sample data.

---

## 🎨 Template Data Structure

```dart
HabitTemplate(
  id: String,                      // Unique ID
  title: String,                   // "Morning Run"
  description: String,             // Full description
  category: String,                // 'fitness', 'learning', etc.
  icon: String,                    // Emoji: '🏃'
  color: String,                   // Hex: '#FF6B6B'
  difficulty: String,              // 'easy' | 'medium' | 'hard'
  recommendedFrequency: String,    // 'daily', '2x per week', etc.
  recommendedDuration: int,        // Minutes: 30
  tips: String,                    // Usage tips
  usageCount: int,                 // Times used: 234
  tags: List<String>,              // ['cardio', 'morning']
)
```

---

## 🔧 Common Operations

### Browse & Filter

```dart
final templates = ref.watch(allTemplatesProvider);
final filtered = ref.watch(filteredTemplatesProvider);
ref.read(templateProvider.notifier).setCategory('fitness');
```

### Search

```dart
final query = ref.watch(searchTemplatesProvider);
ref.read(searchTemplatesProvider.notifier).state = 'running';
```

### Select & View

```dart
ref.read(templateProvider.notifier).selectTemplate('tpl_001');
final selected = ref.watch(selectedTemplateProvider);
```

### Edit

```dart
await ref.read(templateProvider.notifier)
  .updateTemplate(updatedTemplate);
```

### Use

```dart
await ref.read(templateProvider.notifier)
  .incrementUsageCount('tpl_001');
```

---

## 🎯 Usage Tracking

### Get Usage Stats

```dart
// Total usage
int totalUses = templates.fold(0, (sum, t) => sum + t.usageCount);

// Most popular
HabitTemplate mostPopular = templates.reduce(
  (a, b) => a.usageCount > b.usageCount ? a : b
);

// Trending
List<HabitTemplate> trending = templates
  .where((t) => t.usageCount > 100)
  .toList();
```

---

## 🎨 UI Components Reference

### Template Card

- Shows: Icon, title, category, description, difficulty, frequency, duration, tags, usage count
- Actions: Tap for details, Edit button, Use button

### Detail Screen

- Shows: Full header with icon & title
- Stats cards: Difficulty, Duration, Usage count
- Sections: About, Frequency, Category, Tips, Tags
- Actions: Back button, Use Template button

### Edit Screen

- Fields: Title, Description, Difficulty, Frequency, Duration (slider)
- Pickers: Category, Icon (12 options), Color (8 options)
- Input: Tips text, Tags management
- Actions: Cancel, Save Changes

---

## 🌈 Available Colors & Icons

### Icons (Emoji)

```
🏃 🧘 📚 💧 💪 💻 📝 🥗 🎵 ✍️ 🚴 ⛹️
```

### Colors

```
#FF6B6B  Red
#10B981  Green
#3B82F6  Blue
#8B5CF6  Purple
#FBBf24  Amber
#EC4899  Pink
#06B6D4  Cyan
#6366F1  Indigo
```

---

## 🔄 Sample Categories

```
fitness          💪
learning         📚
health           🏥
mindfulness      🧘
productivity     ⚡
lifestyle        🌟
other            🎯
```

---

## 🚦 Difficulty Levels

```
easy    → Green  (1 badge)
medium  → Orange (2 badges)
hard    → Red    (3 badges)
```

---

## 📊 Frequency Options

```
daily
2x per week
3x per week
weekly
monthly
custom
```

---

## 🔍 Search & Filter Flow

```
User types query
    ↓
Real-time search in titles, descriptions, tags
    ↓
Results update instantly
    ↓
Click category chip to filter
    ↓
Combined search + category results
```

---

## 💾 State Management

### Watch (Read values)

```dart
ref.watch(templateProvider)              // Entire state
ref.watch(allTemplatesProvider)          // All templates list
ref.watch(filteredTemplatesProvider)     // Filtered by category
ref.watch(selectedTemplateProvider)      // Current selection
ref.watch(searchTemplatesProvider)       // Search query
```

### Read (Perform actions)

```dart
ref.read(templateProvider.notifier)      // Get notifier for actions
```

### Modify

```dart
notifier.setCategory(category)
notifier.selectTemplate(id)
notifier.updateTemplate(template)
notifier.createTemplate(template)
notifier.deleteTemplate(id)
notifier.incrementUsageCount(id)
notifier.searchTemplates(query)
```

---

## 🎓 Integration Patterns

### In Bottom Navigation

```dart
DefaultTabController(
  length: 2,
  child: Scaffold(
    bottomNavigationBar: TabBar(tabs: [
      Tab(text: 'Communities'),
      Tab(text: 'Templates'),
    ]),
    body: TabBarView(children: [
      CommunityScreen(),
      DiscoverTemplatesScreen(),
    ]),
  ),
)
```

### In Drawer/Menu

```dart
ListTile(
  leading: Icon(Icons.bookmark),
  title: Text('Browse Templates'),
  onTap: () => Navigator.push(context,
    MaterialPageRoute(builder: (_) => DiscoverTemplatesScreen())
  ),
)
```

### FAB Button

```dart
FloatingActionButton(
  onPressed: () => Navigator.push(context,
    MaterialPageRoute(builder: (_) => DiscoverTemplatesScreen())
  ),
  child: Icon(Icons.bookmark),
)
```

---

## 🐛 Debugging

### Check Templates Loading

```dart
final state = ref.watch(templateProvider);
print('Loading: ${state.isLoading}');
print('Templates: ${state.templates.length}');
print('Error: ${state.error}');
```

### Verify Selection

```dart
final selected = ref.watch(selectedTemplateProvider);
print('Selected: ${selected?.title}');
```

### Test Search

```dart
final notifier = ref.read(templateProvider.notifier);
final results = notifier.searchTemplates('run');
print('Found: ${results.length}');
```

---

## 🔗 Provider Dependencies

```
templateProvider (StateNotifier)
    ├── allTemplatesProvider
    ├── filteredTemplatesProvider
    ├── selectedTemplateProvider
    └── searchResultsProvider
        └── searchTemplatesProvider (StateProvider)
```

---

## 🎯 Key Methods

### In TemplateNotifier

```
_loadTemplates()           // Load all templates
setCategory(String)        // Filter by category
selectTemplate(String)     // Select for viewing
clearSelection()           // Clear selection
updateTemplate()           // Edit template
createTemplate()           // Add new template
deleteTemplate()           // Remove template
incrementUsageCount()      // Track usage
searchTemplates()          // Find templates
```

---

## 📱 Screen Flow

```
Discover Templates Screen
    │
    ├─→ Search/Filter
    │
    ├─→ Click Card
    │   ├─→ Template Detail Screen
    │   │   ├─→ Use Template
    │   │   └─→ Back
    │   │
    │   └─→ Create Habit (with prefill)
    │
    └─→ Click Edit
        └─→ Template Edit Screen
            ├─→ Save Changes
            └─→ Cancel
```

---

## ⚙️ Configuration

### Add Template

```dart
HabitTemplate(
  id: 'tpl_custom',
  title: 'Your Title',
  description: 'Your description',
  category: 'fitness',
  icon: '🏃',
  color: '#FF6B6B',
  difficulty: 'easy',
  recommendedFrequency: 'daily',
  recommendedDuration: 30,
  tips: 'Your tips',
  usageCount: 0,
  tags: ['tag1', 'tag2'],
)
```

### Dark Mode Support

✅ All screens automatically adapt to theme
✅ No special configuration needed
✅ Uses `Theme.of(context).brightness`

---

## 🎨 Styling

### App Colors Used

- `AppColors.primaryPurple` - Main accent color
- `AppColors.darkBackground` - Dark theme background
- `AppColors.darkCardBackground` - Dark card background
- `AppColors.lightBackground` - Light theme background
- `AppColors.darkText` - Dark text
- `AppColors.lightText` - Light text

### Typography

- `AppTypography.heading2` - Large titles
- `AppTypography.heading3` - Section titles
- `AppTypography.heading4` - Subsection titles
- `AppTypography.bodyMedium` - Body text
- `AppTypography.bodySmall` - Small text

---

## ✅ Verification Checklist

After integration, verify:

- [ ] Discover Templates screen opens
- [ ] Search works in real-time
- [ ] Category filter updates list
- [ ] Template cards render correctly
- [ ] Clicking card opens detail screen
- [ ] Edit button opens edit screen
- [ ] Use button shows confirmation
- [ ] Dark mode looks good
- [ ] No console errors
- [ ] Navigation is smooth

---

## 📞 Common Issues & Solutions

### Issue: Templates not loading

**Solution**: Check template provider initialization

```dart
final notifier = ref.read(templateProvider.notifier);
// Triggers _loadTemplates() automatically
```

### Issue: Search not working

**Solution**: Ensure searchTemplatesProvider is watched

```dart
final results = ref.watch(searchResultsProvider);
```

### Issue: Dark mode colors wrong

**Solution**: Check `isDark` flag

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
```

### Issue: Edit changes not saving

**Solution**: Ensure template is updated in notifier

```dart
await notifier.updateTemplate(updated);
```

---

## 🚀 Performance Tips

1. **Use `ref.watch()` carefully** - Only watch what you need
2. **Lazy load** - Load templates on-demand, not at startup
3. **Memoize searches** - Cache search results
4. **Limit list items** - Use pagination for large lists
5. **Debounce search** - Wait before searching to reduce rebuilds

---

## 📚 Related Documentation

- `TEMPLATE_SYSTEM_GUIDE.md` - Full setup guide
- `TEMPLATE_INTEGRATION_EXAMPLES.dart` - Code examples
- `TEMPLATE_SYSTEM_SUMMARY.md` - Complete overview

---

## 🎉 You're All Set!

Your habit template system is ready to use. Start with:

1. Add navigation button
2. Test the main screen
3. Try search & filter
4. Test edit functionality
5. Integrate with habit creation

Happy coding! 🚀
