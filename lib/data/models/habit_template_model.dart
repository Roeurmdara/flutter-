// Habit Template Model
class HabitTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final String color;
  final String difficulty; // easy, medium, hard
  final String recommendedFrequency;
  final int recommendedDuration;
  final String tips;
  final int usageCount;
  final List<String> tags;

  HabitTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.recommendedFrequency,
    required this.recommendedDuration,
    required this.tips,
    required this.usageCount,
    required this.tags,
  });

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      difficulty: json['difficulty'] as String,
      recommendedFrequency: json['recommended_frequency'] as String,
      recommendedDuration: json['recommended_duration'] as int,
      tips: json['tips'] as String,
      usageCount: json['usage_count'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'color': color,
      'difficulty': difficulty,
      'recommended_frequency': recommendedFrequency,
      'recommended_duration': recommendedDuration,
      'tips': tips,
      'usage_count': usageCount,
      'tags': tags,
    };
  }
}

// Built-in templates for easy initialization
const List<HabitTemplate> defaultHabitTemplates = [
  // Fitness
  HabitTemplate(
    id: '1',
    title: 'Run 5km',
    description: 'Daily 5km running to build endurance',
    category: 'Fitness',
    icon: '🏃',
    color: '#FF6B6B',
    difficulty: 'hard',
    recommendedFrequency: 'Daily',
    recommendedDuration: 30,
    tips: 'Start slowly and gradually increase your pace',
    usageCount: 1240,
    tags: ['cardio', 'outdoor', 'exercise'],
  ),
  HabitTemplate(
    id: '2',
    title: 'Drink Water',
    description: 'Stay hydrated by drinking 8 glasses daily',
    category: 'Health',
    icon: '💧',
    color: '#4ECDC4',
    difficulty: 'easy',
    recommendedFrequency: 'Daily',
    recommendedDuration: 365,
    tips: 'Set reminders throughout the day',
    usageCount: 5430,
    tags: ['health', 'hydration', 'wellness'],
  ),
  HabitTemplate(
    id: '3',
    title: 'Gym Workout',
    description: '1 hour gym session 5 days a week',
    category: 'Fitness',
    icon: '🏋️',
    color: '#FFB84D',
    difficulty: 'hard',
    recommendedFrequency: 'Daily',
    recommendedDuration: 60,
    tips: 'Mix cardio with strength training',
    usageCount: 3210,
    tags: ['strength', 'workout', 'fitness'],
  ),
  // Study
  HabitTemplate(
    id: '4',
    title: 'Practice Coding',
    description: 'Code for 2 hours daily to improve skills',
    category: 'Study',
    icon: '💻',
    color: '#A8E6CF',
    difficulty: 'medium',
    recommendedFrequency: 'Daily',
    recommendedDuration: 120,
    tips: 'Build projects, not just tutorials',
    usageCount: 2150,
    tags: ['programming', 'learning', 'development'],
  ),
  HabitTemplate(
    id: '5',
    title: 'Read 20 Pages',
    description: 'Read 20 pages of a book daily',
    category: 'Study',
    icon: '📖',
    color: '#FFD93D',
    difficulty: 'easy',
    recommendedFrequency: 'Daily',
    recommendedDuration: 30,
    tips: 'Choose books you enjoy reading',
    usageCount: 4320,
    tags: ['reading', 'learning', 'education'],
  ),
  // Health
  HabitTemplate(
    id: '6',
    title: 'Meditate',
    description: '10 minutes of daily meditation',
    category: 'Mindset',
    icon: '🧘',
    color: '#C8B8FF',
    difficulty: 'easy',
    recommendedFrequency: 'Daily',
    recommendedDuration: 10,
    tips: 'Use a quiet space and meditation app',
    usageCount: 5890,
    tags: ['mindfulness', 'meditation', 'wellness'],
  ),
  HabitTemplate(
    id: '7',
    title: 'Sleep 8 Hours',
    description: 'Get 8 hours of quality sleep',
    category: 'Health',
    icon: '😴',
    color: '#95E1D3',
    difficulty: 'medium',
    recommendedFrequency: 'Daily',
    recommendedDuration: 480,
    tips: 'Keep a consistent sleep schedule',
    usageCount: 4560,
    tags: ['sleep', 'health', 'rest'],
  ),
  // Productivity
  HabitTemplate(
    id: '8',
    title: 'Morning Routine',
    description: 'Complete morning routine (1 hour)',
    category: 'Productivity',
    icon: '⏰',
    color: '#FFB4B4',
    difficulty: 'medium',
    recommendedFrequency: 'Daily',
    recommendedDuration: 60,
    tips: 'Include exercise, shower, and breakfast',
    usageCount: 3420,
    tags: ['routine', 'morning', 'productivity'],
  ),
  HabitTemplate(
    id: '9',
    title: 'Journaling',
    description: 'Write in journal for 15 minutes',
    category: 'Mindset',
    icon: '📔',
    color: '#FFD4A3',
    difficulty: 'easy',
    recommendedFrequency: 'Daily',
    recommendedDuration: 15,
    tips: 'Write without judgment, be honest',
    usageCount: 2890,
    tags: ['mindfulness', 'reflection', 'wellness'],
  ),
];
