import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal_data.dart';
import '../widgets/goal_progress_chart.dart';
import 'goal_creation_wizard.dart';

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
  final List<TextEditingController> _reflectionControllers = [];
  final List<FocusNode> _reflectionFocusNodes = [];

  @override
  void initState() {
    super.initState();
    goal = widget.goal;
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize reflection controllers and focus nodes
    for (int i = 0; i < 12; i++) {
      _reflectionControllers.add(
        TextEditingController(text: goal.weeklyReflections[i])
      );
      _reflectionFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _reflectionControllers) {
      controller.dispose();
    }
    for (var focusNode in _reflectionFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _updateGoal() {
    Navigator.pop(context, {'action': 'update', 'goal': goal});
  }

  void _deleteGoal() {
    Navigator.pop(context, {'action': 'delete', 'goal': goal});
  }

  void _toggleGoalCompletion() {
    setState(() {
      goal.isCompleted = !goal.isCompleted;
      goal.completedDate = goal.isCompleted ? DateTime.now() : null;
    });
    
    // Show congratulations if goal is completed
    if (goal.isCompleted) {
      _showGoalCompletionCongratulations();
    }
    
    _updateGoal();
  }

  void _showGoalCompletionCongratulations() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E1E1E) 
            : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🎉 Congratulations! 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You have successfully completed your goal:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '"${goal.title}"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Final Execution Score: ${goal.executionScore.toInt()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weeks Completed: ${goal.completedWeeks}/12',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You\'ve proven that focused execution over 12 weeks can achieve remarkable results. Keep up the momentum!',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Thank You!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editGoal() async {
    final updatedGoal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute(
        builder: (context) => GoalEditWizard(goal: goal),
      ),
    );
    
    if (updatedGoal != null) {
      setState(() {
        goal = updatedGoal;
      });
      _updateGoal();
    }
  }

  void _saveReflection(int weekIndex, String reflection) {
    // Update the goal's reflection without triggering navigation
    goal.weeklyReflections[weekIndex] = reflection;
    // Don't call _updateGoal() here to prevent navigation
  }

  void _saveAllReflections() {
    // Save all reflections when leaving the screen
    _updateGoal();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope(
      onWillPop: () async {
        // Save all reflections when user tries to leave the screen
        _saveAllReflections();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(goal.title),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF667eea),
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
                } else if (value == 'edit') {
                  _editGoal();
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
              Tab(text: 'Reflection'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildProgressTab(),
            _buildReflectionTab(),
          ],
        ),
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
                      const Icon(Icons.play_arrow, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text('Started: ${DateFormat('MMM dd, yyyy').format(goal.startDate)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.flag, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text('Target: ${DateFormat('MMM dd, yyyy').format(goal.endDate)}'),
                    ],
                  ),
                  if (goal.isCompleted && goal.completedDate != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
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
                          color: const Color(0xFF667eea),
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

  Widget _buildReflectionTab() {
    return DefaultTabController(
      length: 12,
      initialIndex: goal.currentWeek,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary,
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
                        controller: _reflectionControllers[weekIndex],
                        focusNode: _reflectionFocusNodes[weekIndex],
                        onChanged: (value) {
                          // Only update the reflection text, don't save immediately
                          _saveReflection(weekIndex, value);
                        },
                        onEditingComplete: () {
                          // Save when user finishes editing (presses done/enter)
                          _reflectionFocusNodes[weekIndex].unfocus();
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
              _deleteGoal(); // Delete and return to previous screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Goal Edit Wizard
class GoalEditWizard extends StatefulWidget {
  final Goal goal;

  const GoalEditWizard({super.key, required this.goal});

  @override
  State<GoalEditWizard> createState() => _GoalEditWizardState();
}

class _GoalEditWizardState extends State<GoalEditWizard> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _visionController;
  late List<TextEditingController> _whyControllers;
  
  late DateTime _startDate;
  late GoalCategory _category;
  late Priority _priority;
  late double _targetScore;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _descriptionController = TextEditingController(text: widget.goal.description);
    _visionController = TextEditingController(text: widget.goal.vision ?? '');
    
    _whyControllers = List.generate(3, (index) {
      return TextEditingController(
        text: index < widget.goal.whyReasons.length 
            ? widget.goal.whyReasons[index] 
            : '',
      );
    });
    
    _startDate = widget.goal.startDate;
    _category = widget.goal.category;
    _priority = widget.goal.priority;
    _targetScore = widget.goal.targetScore;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _visionController.dispose();
    for (var controller in _whyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveGoal() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title')),
      );
      return;
    }

    final updatedGoal = Goal(
      id: widget.goal.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _startDate.add(const Duration(days: 84)),
      category: _category,
      priority: _priority,
      targetScore: _targetScore,
      vision: _visionController.text.trim().isNotEmpty 
          ? _visionController.text.trim() 
          : null,
      whyReasons: _whyControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList(),
    );

    // Copy over existing progress and actions
    updatedGoal.weeklyProgress = widget.goal.weeklyProgress;
    updatedGoal.weeklyActions = widget.goal.weeklyActions;
    updatedGoal.weeklyReflections = widget.goal.weeklyReflections;
    updatedGoal.isCompleted = widget.goal.isCompleted;
    updatedGoal.completedDate = widget.goal.completedDate;

    Navigator.of(context).pop(updatedGoal);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Goal'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF667eea),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveGoal,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: GoalCategory.values.map((category) {
                final isSelected = _category == category;
                return FilterChip(
                  label: Text(Goal(title: '', startDate: DateTime.now(), category: category).categoryDisplayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _category = category);
                  },
                  selectedColor: const Color(0xFF667eea).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF667eea),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...Priority.values.map((priority) {
              return RadioListTile<Priority>(
                title: Text(priority.name.toUpperCase()),
                value: priority,
                groupValue: _priority,
                onChanged: (value) {
                  if (value != null) setState(() => _priority = value);
                },
                activeColor: const Color(0xFF667eea),
              );
            }),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _visionController,
              decoration: const InputDecoration(
                labelText: 'Vision Statement',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            const Text('Why Reasons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _whyControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Reason ${index + 1}',
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 16),
            
            const Text('Target Execution Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _targetScore,
              min: 50,
              max: 100,
              divisions: 10,
              label: '${_targetScore.toInt()}%',
              activeColor: const Color(0xFF667eea),
              onChanged: (value) => setState(() => _targetScore = value),
            ),
          ],
        ),
      ),
    );
  }
}