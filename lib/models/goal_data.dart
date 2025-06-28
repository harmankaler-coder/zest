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
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    description: json['description'] ?? '',
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
  List<List<WeeklyAction>> weeklyActions;
  List<String> weeklyReflections;
  double targetScore;
  bool isCompleted;
  DateTime? completedDate;
  String? vision;
  List<String> whyReasons;

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
        endDate = endDate ?? startDate.add(const Duration(days: 84)),
        weeklyProgress = List.filled(12, false),
        weeklyActions = List.generate(12, (index) => <WeeklyAction>[]),
        weeklyReflections = List.filled(12, ''),
        whyReasons = whyReasons ?? [];

  int get completedWeeks => weeklyProgress.where((completed) => completed).length;

  double get progress {
    if (weeklyProgress.isEmpty) return 0.0;
    final progressValue = completedWeeks / 12.0;
    return progressValue.clamp(0.0, 1.0);
  }

  int get currentWeek {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return 11;

    final daysDiff = now.difference(startDate).inDays;
    final week = (daysDiff / 7).floor();
    return week.clamp(0, 11);
  }

  double get executionScore {
    if (weeklyActions.isEmpty) return 0.0;

    int totalActions = 0;
    int completedActions = 0;

    final maxWeek = (currentWeek + 1).clamp(1, 12);

    for (int i = 0; i < maxWeek; i++) {
      if (i < weeklyActions.length) {
        totalActions += weeklyActions[i].length;
        completedActions += weeklyActions[i].where((action) => action.isCompleted).length;
      }
    }

    if (totalActions == 0) return 0.0;
    final score = (completedActions / totalActions) * 100;
    return score.clamp(0.0, 100.0);
  }

  bool get isOnTrack => executionScore >= targetScore;

  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    final remaining = endDate.difference(now).inDays;
    return remaining.clamp(0, double.infinity).toInt();
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
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? 'Untitled Goal',
      description: json['description'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 84)),
      category: json['category'] != null && json['category'] < GoalCategory.values.length
          ? GoalCategory.values[json['category']]
          : GoalCategory.personal,
      priority: json['priority'] != null && json['priority'] < Priority.values.length
          ? Priority.values[json['priority']]
          : Priority.medium,
      targetScore: (json['targetScore'] ?? 85.0).toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'])
          : null,
      vision: json['vision'],
      whyReasons: json['whyReasons'] != null
          ? List<String>.from(json['whyReasons'])
          : [],
    );

    if (json['weeklyProgress'] != null) {
      final progressList = List.from(json['weeklyProgress']);
      goal.weeklyProgress = List.generate(12, (index) =>
      index < progressList.length ? progressList[index] == true : false);
    }

    if (json['weeklyActions'] != null) {
      final actionsList = List.from(json['weeklyActions']);
      goal.weeklyActions = List.generate(12, (index) {
        if (index < actionsList.length && actionsList[index] is List) {
          return (actionsList[index] as List)
              .map((action) => WeeklyAction.fromJson(Map<String, dynamic>.from(action)))
              .toList();
        }
        return <WeeklyAction>[];
      });
    }

    if (json['weeklyReflections'] != null) {
      final reflectionsList = List.from(json['weeklyReflections']);
      goal.weeklyReflections = List.generate(12, (index) =>
      index < reflectionsList.length ? reflectionsList[index].toString() : '');
    }

    return goal;
  }
}