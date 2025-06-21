class Goal {
  String title;
  DateTime startDate;
  List<bool> weeklyProgress;

  Goal({
    required this.title,
    required this.startDate,
  }) : weeklyProgress = List.filled(12, false);

  int get completedWeeks =>
      weeklyProgress.where((completed) => completed).length;

  double get progress => completedWeeks / 12;
}