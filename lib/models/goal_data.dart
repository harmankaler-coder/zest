enum GoalCategory {
  personal,
  professional,
  health,
  financial,
  relationships,
  learning,
  spiritual,
  other
}

enum Priority {
  high,
  medium,
  low
}

class WeeklyAction {
  String id;
  String description;
  bool isCompleted;
  DateTime? completedDate;
  String? notes;

  WeeklyAction({
    required this.id,
    required this.description,
    this.isCompleted = false,
    this.completedDate,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'isCompleted': isCompleted,
    'completedDate': completedDate?.toIso8601String(),
    'notes': notes,
  };

  factory WeeklyAction.fromJson(Map<String, dynamic> json) => WeeklyAction(
    id: json['id'],
    description: json['description'],
    isCompleted: json['isCompleted'] ?? false,
    completedDate: json['completedDate'] != null
        ? DateTime.parse(json['completedDate'])
        : null,
    notes: json['notes'],
  );
}

class Goal {
  String id;
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;
  GoalCategory category;
  Priority priority;
  List<bool> weeklyProgress;
  List<List<WeeklyAction>> weeklyActions; // Actions for each week
  List<String> weeklyReflections; // Weekly reflection notes
  double targetScore; // Target execution score (0-100)
  bool isCompleted;
  DateTime? completedDate;
  String? vision; // Personal vision statement
  List<String> whyReasons; // Why this goal matters

  Goal({
    String? id,
    required this.title,
    this.description = '',
    required this.startDate,
    DateTime? endDate,
    this.category = GoalCategory.personal,
    this.priority = Priority.medium,
    this.targetScore = 85.0,
    this.isCompleted = false,
    this.completedDate,
    this.vision,
    List<String>? whyReasons,
  }) :
        id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        endDate = endDate ?? startDate.add(const Duration(days: 84)), // 12 weeks
        weeklyProgress = List.filled(12, false),
        weeklyActions = List.generate(12, (index) => <WeeklyAction>[]),
        weeklyReflections = List.filled(12, ''),
        whyReasons = whyReasons ?? [];

  int get completedWeeks => weeklyProgress.where((completed) => completed).length;
  double get progress => completedWeeks / 12;

  int get currentWeek {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return 12;

    final daysDiff = now.difference(startDate).inDays;
    return (daysDiff / 7).floor().clamp(0, 11);
  }

  double get executionScore {
    if (weeklyActions.isEmpty) return 0.0;

    int totalActions = 0;
    int completedActions = 0;

    for (int i = 0; i <= currentWeek && i < 12; i++) {
      totalActions += weeklyActions[i].length;
      completedActions += weeklyActions[i].where((action) => action.isCompleted).length;
    }

    return totalActions > 0 ? (completedActions / totalActions) * 100 : 0.0;
  }

  bool get isOnTrack => executionScore >= targetScore;

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  String get categoryDisplayName {
    switch (category) {
      case GoalCategory.personal:
        return 'Personal';
      case GoalCategory.professional:
        return 'Professional';
      case GoalCategory.health:
        return 'Health & Fitness';
      case GoalCategory.financial:
        return 'Financial';
      case GoalCategory.relationships:
        return 'Relationships';
      case GoalCategory.learning:
        return 'Learning & Growth';
      case GoalCategory.spiritual:
        return 'Spiritual';
      case GoalCategory.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'category': category.index,
    'priority': priority.index,
    'weeklyProgress': weeklyProgress,
    'weeklyActions': weeklyActions.map((week) =>
        week.map((action) => action.toJson()).toList()).toList(),
    'weeklyReflections': weeklyReflections,
    'targetScore': targetScore,
    'isCompleted': isCompleted,
    'completedDate': completedDate?.toIso8601String(),
    'vision': vision,
    'whyReasons': whyReasons,
  };

  factory Goal.fromJson(Map<String, dynamic> json) {
    final goal = Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: GoalCategory.values[json['category'] ?? 0],
      priority: Priority.values[json['priority'] ?? 1],
      targetScore: json['targetScore']?.toDouble() ?? 85.0,
      isCompleted: json['isCompleted'] ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      vision: json['vision'],
      whyReasons: List<String>.from(json['whyReasons'] ?? []),
    );

    if (json['weeklyProgress'] != null) {
      goal.weeklyProgress = List<bool>.from(json['weeklyProgress']);
    }

    if (json['weeklyActions'] != null) {
      goal.weeklyActions = (json['weeklyActions'] as List)
          .map((week) => (week as List)
          .map((action) => WeeklyAction.fromJson(action))
          .toList())
          .toList();
    }

    if (json['weeklyReflections'] != null) {
      goal.weeklyReflections = List<String>.from(json['weeklyReflections']);
    }

    return goal;
  }
}