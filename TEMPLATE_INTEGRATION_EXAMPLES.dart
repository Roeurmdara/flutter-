// INTEGRATION EXAMPLES
// Copy these examples to add template discovery to your app

// ─────────────────────────────────────────────────────────────────────────
// EXAMPLE 1: Add Templates to Existing Community Screen
// ─────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'discover/discover_templates_screen.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '👥 Communities'),
              Tab(text: '🎯 Templates'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Communities tab
            CommunityScreen(),
            
            // Templates tab
            DiscoverTemplatesScreen(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EXAMPLE 2: Add Templates Button to Home Screen
// ─────────────────────────────────────────────────────────────────────────

class HomeScreenWithTemplates extends ConsumerWidget {
  const HomeScreenWithTemplates({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Add templates button in app bar
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DiscoverTemplatesScreen(),
                ),
              );
            },
            tooltip: 'Browse Habit Templates',
          ),
        ],
      ),
      body: Column(
        children: [
          // Existing home content...
          
          // Add templates section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Start with Templates',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DiscoverTemplatesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmark),
                  label: const Text('Browse Templates'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EXAMPLE 3: Create Habit from Template (Integration with Habit Creation)
// ─────────────────────────────────────────────────────────────────────────

class CreateHabitWithTemplate extends ConsumerStatefulWidget {
  final HabitTemplate? template;

  const CreateHabitWithTemplate({
    super.key,
    this.template,
  });

  @override
  ConsumerState<CreateHabitWithTemplate> createState() =>
      _CreateHabitWithTemplateState();
}

class _CreateHabitWithTemplateState
    extends ConsumerState<CreateHabitWithTemplate> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late String selectedFrequency;
  late int selectedDuration;

  @override
  void initState() {
    super.initState();
    // Pre-fill from template if provided
    titleController = TextEditingController(
      text: widget.template?.title ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.template?.description ?? '',
    );
    selectedFrequency = widget.template?.recommendedFrequency ?? 'daily';
    selectedDuration = widget.template?.recommendedDuration ?? 30;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Habit'),
        subtitle: widget.template != null
            ? Text('Using: ${widget.template!.title}')
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Template info card (if template provided)
            if (widget.template != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Text(
                      widget.template!.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Template',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            widget.template!.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Title input
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Habit Title',
                hintText: 'e.g., Morning 5K Run',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description input
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Why do you want this habit?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Frequency dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedFrequency,
              decoration: InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                'daily',
                '2x per week',
                '3x per week',
                'weekly',
              ]
                  .map((freq) => DropdownMenuItem(
                        value: freq,
                        child: Text(freq),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedFrequency = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Duration slider
            Slider(
              value: selectedDuration.toDouble(),
              min: 1,
              max: 180,
              divisions: 35,
              label: '${selectedDuration}min',
              onChanged: (value) {
                setState(() => selectedDuration = value.toInt());
              },
            ),
            Text('Duration: $selectedDuration minutes'),
            const SizedBox(height: 24),

            // Create button
            ElevatedButton(
              onPressed: () {
                // Save habit logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Habit "${titleController.text}" created!',
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EXAMPLE 4: Navigation Flow in main.dart or router
// ─────────────────────────────────────────────────────────────────────────

// Using GoRouter (if you have go_router package)
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // Discover templates route
        GoRoute(
          path: 'discover/templates',
          builder: (context, state) => const DiscoverTemplatesScreen(),
          routes: [
            GoRoute(
              path: 'detail',
              builder: (context, state) => const TemplateDetailScreen(),
            ),
            GoRoute(
              path: 'edit',
              builder: (context, state) => const TemplateEditScreen(
                template: /* pass template */,
              ),
            ),
          ],
        ),
        
        // Create habit from template
        GoRoute(
          path: 'habit/create',
          builder: (context, state) {
            final template = state.extra as HabitTemplate?;
            return CreateHabitWithTemplate(template: template);
          },
        ),
      ],
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────
// EXAMPLE 5: Template Widget for Dashboard
// ─────────────────────────────────────────────────────────────────────────

class TemplateOfTheWeekWidget extends ConsumerWidget {
  const TemplateOfTheWeekWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(allTemplatesProvider);
    
    // Get most used template
    final topTemplate = templates.isNotEmpty
        ? templates.reduce((a, b) => a.usageCount > b.usageCount ? a : b)
        : null;

    if (topTemplate == null) return const SizedBox();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular This Week 🔥',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Text(topTemplate.icon, style: const TextStyle(fontSize: 32)),
              title: Text(topTemplate.title),
              subtitle: Text('${topTemplate.usageCount} people using'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DiscoverTemplatesScreen(),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// EXAMPLE 6: Quick Action Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────

void showQuickStartSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quick Start Your Habit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DiscoverTemplatesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.bookmark),
            label: const Text('Use Template'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to create custom habit
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Custom'),
          ),
        ],
      ),
    ),
  );
}

