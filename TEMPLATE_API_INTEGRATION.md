# Template Discovery API Integration Guide

## ✅ Status: API Integration Complete

Your Flutter app is now fully integrated with the Habit API template endpoints at `https://habit-api.rattanakmony.com/api/v1/templates`

---

## What Was Updated

### 1. **HabitTemplate Model** (`lib/data/models/habit_template_model.dart`)

Updated to parse the real API response structure:

```dart
// Now handles real API fields:
final String categoryId;        // category UUID
final String targetValue;       // e.g., "1.00"
final String targetUnit;        // e.g., "times"
final int durationDays;         // total duration in days

// Automatically extracts from nested category object:
final String icon;              // from category.icon (emoji)
final String color;             // from category.color_hex
final String category;          // from category.name

// Auto-derives based on frequency:
final String difficulty;        // easy/medium/hard (derived from frequency)
```

**Key Feature:** Automatic `fromJson()` parsing that:

- Extracts icon & color from nested `category` object
- Maps API field names to model properties (`suggested_frequency` → `recommendedFrequency`)
- Auto-derives difficulty from frequency
- Handles missing fields gracefully with defaults

---

### 2. **TemplateService** (`lib/data/services/template_service.dart`)

All API endpoints ready with proper response handling:

```dart
// Fetch all templates with pagination
final templates = await templateService.fetchTemplates();

// Fetch templates by category UUID
final categoryTemplates = await templateService
  .fetchTemplatesByCategory('019e4961-3459-72d6-84a1-b120528b8894');

// Get single template details
final template = await templateService.fetchTemplate('019e52a6-f92d-73d6-8153-0edf43b60e80');

// Create, update, delete templates
await templateService.updateTemplate(updatedTemplate);
await templateService.deleteTemplate(templateId);
await templateService.createTemplate(newTemplate);

// Track template usage
await templateService.incrementTemplateUsage(templateId);
```

**Response Handling:** Properly unwraps paginated responses:

```json
{
  "success": true,
  "data": [
    /* templates */
  ],
  "meta": { "page": 1, "totalPages": 3 /* ... */ }
}
```

---

### 3. **TemplateProvider** (`lib/data/providers/template_provider.dart`)

Riverpod state management with API integration:

```dart
// Main provider - loads templates from API on init
final templateProvider = StateNotifierProvider<TemplateNotifier, TemplateState>((ref) {
  final service = ref.watch(templateServiceProvider);
  return TemplateNotifier(service);  // ← Dependency injection
});

// Filtered/derived providers
final allTemplatesProvider;           // Get all templates
final templatesByCategoryProvider;    // Get templates by category
final filteredTemplatesProvider;      // Get filtered templates
final selectedTemplateProvider;       // Get selected template
final searchResultsProvider;          // Search templates
```

**Fallback Strategy:** If API fails, uses 8 sample templates for offline testing

---

## Usage Examples

### Load Templates on App Start

```dart
// This happens automatically when templateProvider is first watched!
// The TemplateNotifier constructor calls _loadTemplates() automatically

// In your widget:
final templates = ref.watch(templateProvider).templates;
```

### Display Templates by Category

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Load category-specific templates
  final templates = ref.watch(templateProvider);

  // Filter by category
  ref.read(templateProvider.notifier).loadTemplatesByCategory('fitness');

  return ListView(
    children: templates.filteredTemplates.map((t) => TemplateCard(t)).toList(),
  );
}
```

### Search Templates

```dart
// Set search query
ref.read(searchTemplatesProvider.notifier).state = 'morning';

// Get search results
final results = ref.watch(searchResultsProvider);
```

### Use Template to Create Habit

```dart
// 1. Select a template
ref.read(templateProvider.notifier).selectTemplate(template.id);

// 2. Increment usage tracking
await ref.read(templateProvider.notifier).incrementUsageCount(template.id);

// 3. Pass template data to habit creation:
final template = ref.watch(selectedTemplateProvider);
// Pass: title, description, recommendedFrequency, recommendedDuration, tips
```

---

## Real API Response Examples

### List Templates with Pagination

```
GET https://habit-api.rattanakmony.com/api/v1/templates?page=1&per_page=10&category_id=019e4961-3459-72d6-84a1-b120528b8894

Response:
{
  "success": true,
  "message": "Resource list retrieved successfully.",
  "status": 200,
  "data": [
    {
      "id": "019e52a6-f92d-73d6-8153-0edf43b60e80",
      "category_id": "019e4961-3459-72d6-84a1-b120528b8894",
      "title": "dara",
      "description": "dara",
      "suggested_frequency": "daily",
      "target_value": "1.00",
      "target_unit": "times",
      "duration_days": 30,
      "tips": "dara",
      "is_published": true,
      "created_by": "019de16a-0981-72d9-b8f1-217194120bca",
      "created_at": "2026-05-23T02:25:35.000000Z",
      "updated_at": "2026-05-26T14:48:16.000000Z",
      "category": {
        "id": "019e4961-3459-72d6-84a1-b120528b8894",
        "name": "kiminoto",
        "icon": "🎯",
        "color_hex": "#6366f1"
      }
    }
  ],
  "meta": {
    "page": 1,
    "size": 1,
    "totalElements": 3,
    "totalPages": 3,
    "hasNext": true,
    "hasPrevious": false,
    "per_page": 1,
    "total": 3,
    "last_page": 3
  }
}
```

### Get Single Template

```
GET https://habit-api.rattanakmony.com/api/v1/templates/019e52a6-f92d-73d6-8153-0edf43b60e80

Response: { "data": { template object } }
```

---

## File Structure

```
lib/
├── data/
│   ├── models/
│   │   └── habit_template_model.dart          ✅ Updated with API parsing
│   ├── services/
│   │   └── template_service.dart              ✅ All endpoints ready
│   ├── providers/
│   │   ├── template_provider.dart             ✅ API integrated
│   │   ├── auth_provider.dart                 (Bearer token auth)
│   │   └── session_provider.dart
│   └── ...
├── presentation/
│   └── screens/
│       └── discover/
│           ├── discover_templates_screen.dart ✅ Ready to use
│           ├── template_detail_screen.dart    ✅ Ready to use
│           └── template_edit_screen.dart      ✅ Ready to use
└── core/
    └── constants/
        └── app_constants.dart                 (baseUrl configuration)
```

---

## Next Steps: Categories Integration

To complete the "discover page integration with categories" workflow:

### 1. **Add Templates Section to Categories Screen**

Update `lib/presentation/screens/categories/categories_screen.dart`:

```dart
// Show templates when user taps a category
// Display TemplateCard for each template in that category
// Add "Use Template" button that navigates to habit creation
```

### 2. **Create Template → Habit Flow**

```dart
// When user clicks "Use Template":
// 1. Pre-fill habit creation form with template data
// 2. User customizes if needed
// 3. User creates habit
// 4. Template usage is tracked
```

### 3. **Integration Points**

- Categories → Show templates section
- Template card → View details / Edit / Use
- Use template → Create habit with pre-filled data
- Track usage → Analytics

---

## Testing

### Test with Sample Data (Offline)

If API is down, the system automatically uses 8 sample templates included in the code. No changes needed.

### Test with Real API

1. Ensure app has internet connectivity
2. User must be logged in (auth token available)
3. API calls are authenticated with Bearer token
4. Check network traffic in debugger to verify endpoints

### Debug API Issues

```dart
// TemplateService logs all errors to console:
// "Error fetching templates: ..."
// Check Firebase Console or VS Code debugger
```

---

## Architecture Overview

```
API Response
    ↓
TemplateService (HTTP Layer)
    ↓ parses & transforms
HabitTemplate Model
    ↓
TemplateProvider (State Management)
    ↓ watches & provides
Riverpod Consumers (UI Widgets)
    ↓ displays
Template Cards / Details / Edit Screens
```

---

## Key Features Included

✅ **Dependency Injection**: TemplateService properly injected via Riverpod
✅ **Offline Fallback**: Sample templates when API unavailable
✅ **Auto Bearer Token**: Auth headers automatically added via interceptor
✅ **Proper Response Handling**: Unwraps paginated responses correctly
✅ **Error Handling**: Graceful fallbacks and error state management
✅ **Search & Filter**: Real-time template search and category filtering
✅ **CRUD Operations**: Create, Read, Update, Delete templates
✅ **Usage Tracking**: Track how often templates are used

---

## API Endpoints Summary

| Method | Endpoint                          | Purpose                        |
| ------ | --------------------------------- | ------------------------------ |
| GET    | `/templates`                      | List all templates (paginated) |
| GET    | `/templates?category_id=uuid`     | Filter by category             |
| GET    | `/templates/{id}`                 | Get single template            |
| POST   | `/templates`                      | Create new template            |
| PUT    | `/templates/{id}`                 | Update template                |
| DELETE | `/templates/{id}`                 | Delete template                |
| POST   | `/templates/{id}/increment-usage` | Track usage                    |

All requests include `Authorization: Bearer {token}` header automatically.

---

## Configuration

API Base URL: Set in `lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  static const String baseUrl = 'https://habit-api.rattanakmony.com/api/v1';
  // ...
}
```

---

**Status**: ✅ Ready for Categories Screen Integration
**Last Updated**: May 27, 2026
**API**: habit-api.rattanakmony.com/api/v1/templates
