import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        backgroundColor: Colors.indigo,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        goal.isCompleted ? Icons.check_circle : Icons.flag,
                        color: goal.isCompleted ? Colors.green : Colors.indigo,
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
                              ),
                            ),
                            Text(
                              goal.categoryDisplayName,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: goal.isOnTrack ? Colors.green : Colors.red,
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
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Weeks Complete',
                          '${goal.completedWeeks}/12',
                          Icons.calendar_today,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Days Left',
                          '${goal.daysRemaining}',
                          Icons.timer,
                        ),
                      ),
                    ],
                  ),
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
          const Text(
            'Weekly Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isCurrent ? Colors.indigo.withOpacity(0.1) : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCompleted
                      ? Colors.green
                      : isCurrent
                      ? Colors.indigo
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
                subtitle: Text(
                  weekActions.isEmpty
                      ? 'No actions planned'
                      : '$completedActions/${weekActions.length} actions completed',
                ),
                trailing: isCurrent
                    ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
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
          TabBar(
            isScrollable: true,
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            tabs: List.generate(12, (index) => Tab(text: 'W${index + 1}')),
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
                      Text(
                        'Week ${weekIndex + 1} Actions',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (actions.isEmpty)
                        const Center(
                          child: Column(
                            children: [
                              Icon(Icons.add_task, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'No actions planned for this week',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
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
                            },
                            onDelete: () {
                              setState(() {
                                goal.weeklyActions[weekIndex].remove(action);
                              });
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
          TabBar(
            isScrollable: true,
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            tabs: List.generate(12, (index) => Tab(text: 'W${index + 1}')),
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
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