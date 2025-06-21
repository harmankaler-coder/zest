import 'package:flutter/material.dart';

import '../goal_data.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  GoalDetailScreenState createState() => GoalDetailScreenState();
}

class GoalDetailScreenState extends State<GoalDetailScreen> with SingleTickerProviderStateMixin {
  late Goal editableGoal;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    editableGoal = Goal(
      title: widget.goal.title,
      startDate: widget.goal.startDate,
    )..weeklyProgress.setAll(0, widget.goal.weeklyProgress);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleWeek(int index) {
    setState(() {
      editableGoal.weeklyProgress[index] = !editableGoal.weeklyProgress[index];
      _animationController.reset();
      _animationController.forward();
    });
  }

  void saveAndExit() {
    Navigator.of(context).pop(editableGoal);
  }

  Widget _buildWeekToggle(int index) {
    bool completed = editableGoal.weeklyProgress[index];

    return GestureDetector(
      onTap: () => _toggleWeek(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(6),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: completed ? Colors.indigo.shade600 : Colors.grey[300],
          borderRadius: BorderRadius.circular(14),
          boxShadow: completed
              ? [
                  BoxShadow(
                      color: Colors.indigo.shade400.withOpacity(0.7),
                      blurRadius: 12,
                      offset: const Offset(0, 6))
                ]
              : [],
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: completed ? Colors.white : Colors.indigo.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: completed
                  ? [
                      Shadow(
                          color: Colors.indigo.shade900.withOpacity(0.6),
                          blurRadius: 4,
                          offset: const Offset(1, 1))
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int completedWeeks = editableGoal.completedWeeks;
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.indigo.shade50, Colors.indigo.shade200],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(editableGoal.title),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Progress',
            onPressed: saveAndExit,
            splashRadius: 24,
            color: Colors.white,
          )
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade700, Colors.indigo.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Date: ${editableGoal.startDate.day.toString().padLeft(2, '0')}/${editableGoal.startDate.month.toString().padLeft(2, '0')}/${editableGoal.startDate.year}',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.indigo.shade700,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'Progress: $completedWeeks / 12 weeks',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: editableGoal.progress,
                minHeight: 14,
                backgroundColor: Colors.indigo.shade100,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Mark each week completed:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo.shade800),
            ),
            const SizedBox(height: 16),
            Wrap(
              children: List.generate(12, (index) => _buildWeekToggle(index)),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: saveAndExit,
              icon: const Icon(Icons.save, size: 28, color: Colors.white),
              label: const Text(
                'Save Progress',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                backgroundColor: Colors.indigo.shade700,
                elevation: 8,
                shadowColor: Colors.indigo.shade300,
              ),
            )
          ],
        ),
      ),
    );
  }
}