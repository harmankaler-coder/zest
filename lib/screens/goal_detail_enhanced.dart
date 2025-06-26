import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal_data.dart';
import '../widgets/goal_progress_chart.dart';
import '../widgets/weekly_action_tile.dart';

class GoalDetailEnhanced extends StatefulWidget {
  final Goal goal;

  const GoalDetailEnhanced({super.key, required this.goal});

  @override
  State<GoalDetailEnhanced> createState() => _GoalDetailEnhancedState();
}

class _GoalDetailEnhancedState extends State<GoalDetailEnhanced>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Goal goal;

  @override
  void initState() {
    super.initState();
    goal = widget.goal;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateGoal() {
    Navigator.pop(context, goal);
  }

  void _toggleGoalCompletion() {
    setState(() {
      goal.isCompleted = !goal.isCompleted;
      goal.completedDate = goal.isCompleted ? DateTime.now() : null;
    });
    _updateGoal();
  }

  void _addWeeklyAction(int weekIndex) {
    showDialog(
      context: context,
      builder: (context) => _AddActionDialog(
        weekNumber: weekIndex + 1,
        onAdd: (description) {
          final action = WeeklyAction(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            description: description,
          );
          
          setState(() {
            goal.weeklyActions[weekIndex].add(action);
          });
          
          _updateGoal();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(goal.isCompleted ? Icons.undo : Icons.check),
            onPressed: _toggleGoalCompletion,
            tooltip: goal.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Goal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Goal', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Progress'),
            Tab(text: 'Actions'),
            Tab(text: 'Reflection'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildProgressTab(),
          _buildActionsTab(),
          _buildReflectionTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: goal.isCompleted 
                    ? [Colors.green.shade400, Colors.green.shade600]
                    : [const Color(0xFF667eea), const Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          goal.isCompleted ? Icons.check_circle : Icons.flag,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                goal.categoryDisplayName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            goal.isOnTrack ? 'On Track' : 'Behind',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Execution Score',
                            '${goal.executionScore.toInt()}%',
                            Icons.trending_up,
                            Colors.white,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Weeks Complete',
                            '${goal.completedWeeks}/12',
                            Icons.calendar_today,
                            Colors.white,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Days Left',
                            '${goal.daysRemaining}',
                            Icons.timer,
                            Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Timeline
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Timeline',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.play_arrow, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text('Started: ${DateFormat('MMM dd, yyyy').format(goal.startDate)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.flag, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text('Target: ${DateFormat('MMM dd, yyyy').format(goal.endDate)}'),
                    ],
                  ),
                  if (goal.isCompleted && goal.completedDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text('Completed: ${DateFormat('MMM dd, yyyy').format(goal.completedDate!)}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          if (goal.description.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(goal.description),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Vision
          if (goal.vision != null && goal.vision!.isNotEmpty) ...[
            const Text(
              'Vision',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Your Vision',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(goal.vision!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Why Reasons
          if (goal.whyReasons.isNotEmpty) ...[
            const Text(
              'Why This Matters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Your Reasons',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...goal.whyReasons.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${entry.key + 1}. '),
                            Expanded(child: Text(entry.value)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Chart
          GoalProgressChart(goal: goal),
          
          const SizedBox(height: 24),
          
          // Weekly Breakdown
          const Text(
            'Week by Week',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          ...List.generate(12, (index) {
            final isCompleted = goal.weeklyProgress[index];
            final isCurrent = index == goal.currentWeek;
            final weekActions = goal.weeklyActions[index];
            final completedActions = weekActions.where((a) => a.isCompleted).length;
            final weekScore = weekActions.isNotEmpty 
                ? (completedActions / weekActions.length) * 100 
                : 0.0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isCurrent ? const Color(0xFF667eea).withOpacity(0.1) : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCompleted 
                      ? Colors.green 
                      : isCurrent 
                          ? const Color(0xFF667eea)
                          : Colors.grey.withOpacity(0.3),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.calendar_today,
                    color: isCompleted || isCurrent ? Colors.white : Colors.grey,
                  ),
                ),
                title: Text(
                  'Week ${index + 1}',
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekActions.isEmpty 
                          ? 'No actions planned'
                          : '$completedActions/${weekActions.length} actions completed',
                    ),
                    if (weekActions.isNotEmpty)
                      Text(
                        'Score: ${weekScore.toInt()}%',
                        style: TextStyle(
                          color: weekScore >= goal.targetScore ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: isCurrent 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionsTab() {
    return DefaultTabController(
      length: 12,
      initialIndex: goal.currentWeek,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: List.generate(12, (index) => Tab(text: 'W${index + 1}')),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: List.generate(12, (weekIndex) {
                final actions = goal.weeklyActions[weekIndex];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Week ${weekIndex + 1} Actions',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: IconButton(
                              onPressed: () => _addWeeklyAction(weekIndex),
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (actions.isEmpty)
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
                        ...actions.map((action) {
                          return WeeklyActionTile(
                            action: action,
                            onToggle: () {
                              setState(() {
                                action.isCompleted = !action.isCompleted;
                                action.completedDate = action.isCompleted ? DateTime.now() : null;
                              });
                              _updateGoal();
                            },
                            onDelete: () {
                              setState(() {
                                goal.weeklyActions[weekIndex].remove(action);
                              });
                              _updateGoal();
                            },
                          );
                        }),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionTab() {
    return DefaultTabController(
      length: 12,
      initialIndex: goal.currentWeek,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: List.generate(12, (index) => Tab(text: 'W${index + 1}')),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: List.generate(12, (weekIndex) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week ${weekIndex + 1} Reflection',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        maxLines: 10,
                        decoration: const InputDecoration(
                          hintText: 'What did you learn this week?\nWhat worked well?\nWhat would you do differently?\nHow did you feel about your progress?',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(
                          text: goal.weeklyReflections[weekIndex],
                        ),
                        onChanged: (value) {
                          goal.weeklyReflections[weekIndex] = value;
                          _updateGoal();
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.lightbulb, color: Colors.blue[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Reflection Prompts',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• What specific actions moved you closer to your goal?\n'
                              '• What obstacles did you encounter and how did you handle them?\n'
                              '• What patterns are you noticing in your behavior?\n'
                              '• How can you improve your execution next week?\n'
                              '• What are you most proud of this week?',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, null); // Return to previous screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: ElevatedButton(
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                widget.onAdd(_controller.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: const Text('Add'),
          ),
        ),
      ],
    );
  }
}