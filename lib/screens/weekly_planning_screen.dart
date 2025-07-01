import 'package:flutter/material.dart';
import '../models/goal_data.dart';
import '../widgets/weekly_action_tile.dart';

class WeeklyPlanningScreen extends StatefulWidget {
  final List<Goal> goals;
  final Function(Goal) onGoalUpdated;

  const WeeklyPlanningScreen({
    super.key,
    required this.goals,
    required this.onGoalUpdated,
  });

  @override
  State<WeeklyPlanningScreen> createState() => _WeeklyPlanningScreenState();
}

class _WeeklyPlanningScreenState extends State<WeeklyPlanningScreen> {
  int selectedWeek = 0;
  Goal? selectedGoal;

  @override
  void initState() {
    super.initState();
    final activeGoals = widget.goals.where((g) => !g.isCompleted).toList();
    if (activeGoals.isNotEmpty) {
      selectedGoal = activeGoals.first;
      selectedWeek = selectedGoal!.currentWeek;
    }
  }

  @override
  void didUpdateWidget(WeeklyPlanningScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected goal if goals list changed
    if (selectedGoal != null) {
      final updatedGoal = widget.goals.firstWhere(
        (g) => g.id == selectedGoal!.id,
        orElse: () {
          final activeGoals = widget.goals.where((g) => !g.isCompleted).toList();
          return activeGoals.isNotEmpty ? activeGoals.first : Goal(title: '', startDate: DateTime.now());
        },
      );
      if (updatedGoal.title.isNotEmpty) {
        selectedGoal = updatedGoal;
      }
    }
  }

  void _addAction() {
    if (selectedGoal == null) return;

    showDialog(
      context: context,
      builder: (context) => _AddActionDialog(
        weekNumber: selectedWeek + 1,
        onAdd: (description) {
          final action = WeeklyAction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            description: description,
          );
          
          setState(() {
            selectedGoal!.weeklyActions[selectedWeek].add(action);
          });
          
          widget.onGoalUpdated(selectedGoal!);
        },
      ),
    );
  }

  void _toggleAction(WeeklyAction action) {
    setState(() {
      action.isCompleted = !action.isCompleted;
      action.completedDate = action.isCompleted ? DateTime.now() : null;
    });
    widget.onGoalUpdated(selectedGoal!);
  }

  void _deleteAction(WeeklyAction action) {
    setState(() {
      selectedGoal!.weeklyActions[selectedWeek].remove(action);
    });
    widget.onGoalUpdated(selectedGoal!);
  }

  void _updateReflection(String reflection) {
    if (selectedGoal == null) return;
    
    setState(() {
      selectedGoal!.weeklyReflections[selectedWeek] = reflection;
    });
    widget.onGoalUpdated(selectedGoal!);
  }

  void _markWeekComplete() {
    if (selectedGoal == null) return;
    
    setState(() {
      selectedGoal!.weeklyProgress[selectedWeek] = true;
    });
    widget.onGoalUpdated(selectedGoal!);
    
    // Show week completion congratulations
    _showWeekCompletionCongratulations();
  }

  void _showWeekCompletionCongratulations() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E1E1E) 
            : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 Week Completed! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Congratulations on completing Week ${selectedWeek + 1}!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Week ${selectedWeek + 1} Score: ${_calculateWeekScore()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep up the excellent work!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateWeekScore() {
    if (selectedGoal == null) return 0;
    final weekActions = selectedGoal!.weeklyActions[selectedWeek];
    if (weekActions.isEmpty) return 0;
    final completedActions = weekActions.where((a) => a.isCompleted).length;
    return ((completedActions / weekActions.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final activeGoals = widget.goals.where((g) => !g.isCompleted).toList();
    
    if (activeGoals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Plan'),
          automaticallyImplyLeading: false,
        ),
        body: Container(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF121212) 
              : Colors.white,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Active Goals',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Create a goal to start weekly planning',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Ensure selectedGoal is valid
    if (selectedGoal == null || !activeGoals.contains(selectedGoal)) {
      selectedGoal = activeGoals.first;
      selectedWeek = selectedGoal!.currentWeek;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Goal Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Goal',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: DropdownButton<String>(
                    value: selectedGoal?.id,
                    isExpanded: true,
                    underline: Container(),
                    items: activeGoals.map((goal) {
                      return DropdownMenuItem<String>(
                        value: goal.id,
                        child: Text(
                          goal.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (goalId) {
                      if (goalId != null) {
                        final goal = activeGoals.firstWhere((g) => g.id == goalId);
                        setState(() {
                          selectedGoal = goal;
                          selectedWeek = goal.currentWeek;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Week Selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 12,
              itemBuilder: (context, index) {
                final isCurrentWeek = index == selectedGoal!.currentWeek;
                final isSelected = index == selectedWeek;
                final isCompleted = selectedGoal!.weeklyProgress[index];
                
                return GestureDetector(
                  onTap: () => setState(() => selectedWeek = index),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : (isCompleted 
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                      border: isCurrentWeek 
                          ? Border.all(color: Colors.orange, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'W${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        if (isCompleted)
                          Icon(
                            Icons.check,
                            size: 16,
                            color: isSelected ? Colors.white : Colors.green,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Actions List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Week ${selectedWeek + 1} Actions',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addAction,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (selectedGoal!.weeklyActions[selectedWeek].isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(Icons.add_task, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'No actions planned for this week',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Tap + to add your first action',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...selectedGoal!.weeklyActions[selectedWeek].map((action) {
                      return WeeklyActionTile(
                        action: action,
                        onToggle: () => _toggleAction(action),
                        onDelete: () => _deleteAction(action),
                      );
                    }),
                  
                  const SizedBox(height: 24),
                  
                  // Weekly Reflection
                  const Text(
                    'Weekly Reflection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'What did you learn this week? What will you do differently?',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: selectedGoal!.weeklyReflections[selectedWeek],
                    ),
                    onChanged: _updateReflection,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Week Completion Button
                  if (!selectedGoal!.weeklyProgress[selectedWeek])
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedGoal!.weeklyActions[selectedWeek].isNotEmpty
                            ? _markWeekComplete
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Mark Week as Complete',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Week Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddActionDialog extends StatefulWidget {
  final Function(String) onAdd;
  final int weekNumber;

  const _AddActionDialog({required this.onAdd, required this.weekNumber});

  @override
  State<_AddActionDialog> createState() => _AddActionDialogState();
}

class _AddActionDialogState extends State<_AddActionDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Week ${widget.weekNumber} Action'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'What specific action will you take this week?',
          border: OutlineInputBorder(),
        ),
        maxLines: 2,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              widget.onAdd(_controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}