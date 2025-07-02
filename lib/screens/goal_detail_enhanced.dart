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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🎉 Congratulations! 🎉',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You have successfully completed your goal:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '"${goal.title}"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: const Color(0xFF6C63FF),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4ECDC4).withOpacity(0.1),
                    const Color(0xFF44A08D).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Final Execution Score: ${goal.executionScore.toInt()}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4ECDC4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Weeks Completed: ${goal.completedWeeks}/12',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'You\'ve proven that focused execution over 12 weeks can achieve remarkable results. Keep up the momentum!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
    return WillPopScope(
      onWillPop: () async {
        // Save all reflections when user tries to leave the screen
        _saveAllReflections();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(goal.title),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: goal.isCompleted 
                      ? [const Color(0xFFFFB74D), const Color(0xFFFF9800)]
                      : [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(goal.isCompleted ? Icons.undo_rounded : Icons.check_rounded, size: 18),
                onPressed: _toggleGoalCompletion,
                tooltip: goal.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded),
                      SizedBox(width: 8),
                      Text('Edit Goal'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Color(0xFFFF6B6B)),
                      SizedBox(width: 8),
                      Text('Delete Goal', style: TextStyle(color: Color(0xFFFF6B6B))),
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
            unselectedLabelColor: Colors.white54,
            indicatorColor: const Color(0xFF6C63FF),
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Progress'),
              Tab(text: 'Reflection'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF000000),
                Color(0xFF111111),
              ],
            ),
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildProgressTab(),
              _buildReflectionTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card with enhanced design
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: goal.isCompleted 
                    ? [const Color(0xFF4ECDC4), const Color(0xFF44A08D)]
                    : [const Color(0xFF6C63FF), const Color(0xFF9C88FF)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (goal.isCompleted 
                      ? const Color(0xFF4ECDC4) 
                      : const Color(0xFF6C63FF)).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          goal.isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              goal.categoryDisplayName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          goal.isOnTrack ? 'On Track' : 'Behind',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Execution Score',
                          '${goal.executionScore.toInt()}%',
                          Icons.trending_up_rounded,
                          Colors.white,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Weeks Complete',
                          '${goal.completedWeeks}/12',
                          Icons.calendar_today_rounded,
                          Colors.white,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Days Left',
                          '${goal.daysRemaining}',
                          Icons.timer_rounded,
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Timeline Card
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timeline',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineItem(
                    Icons.play_arrow_rounded,
                    'Started',
                    DateFormat('MMM dd, yyyy').format(goal.startDate),
                    const Color(0xFF4ECDC4),
                  ),
                  const SizedBox(height: 12),
                  _buildTimelineItem(
                    Icons.flag_rounded,
                    'Target',
                    DateFormat('MMM dd, yyyy').format(goal.endDate),
                    const Color(0xFFFF6B6B),
                  ),
                  if (goal.isCompleted && goal.completedDate != null) ...[
                    const SizedBox(height: 12),
                    _buildTimelineItem(
                      Icons.check_circle_rounded,
                      'Completed',
                      DateFormat('MMM dd, yyyy').format(goal.completedDate!),
                      const Color(0xFF4ECDC4),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description
          if (goal.description.isNotEmpty) ...[
            _buildInfoCard(
              'Description',
              goal.description,
              Icons.description_rounded,
              const Color(0xFF6C63FF),
            ),
            const SizedBox(height: 24),
          ],
          
          // Vision
          if (goal.vision != null && goal.vision!.isNotEmpty) ...[
            _buildInfoCard(
              'Vision',
              goal.vision!,
              Icons.visibility_rounded,
              const Color(0xFF9C88FF),
            ),
            const SizedBox(height: 24),
          ],
          
          // Why Reasons
          if (goal.whyReasons.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Why This Matters',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...goal.whyReasons.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB74D).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFFFFB74D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Chart
          GoalProgressChart(goal: goal),
          
          const SizedBox(height: 24),
          
          // Weekly Breakdown
          Text(
            'Week by Week',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
                border: isCurrent 
                    ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted 
                          ? [const Color(0xFF4ECDC4), const Color(0xFF44A08D)]
                          : isCurrent 
                              ? [const Color(0xFF6C63FF), const Color(0xFF9C88FF)]
                              : [Colors.grey.shade700, Colors.grey.shade600],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : Icons.calendar_today_rounded,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  'Week ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekActions.isEmpty 
                          ? 'No actions planned'
                          : '$completedActions/${weekActions.length} actions completed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (weekActions.isNotEmpty)
                      Text(
                        'Score: ${weekScore.toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: weekScore >= goal.targetScore 
                              ? const Color(0xFF4ECDC4) 
                              : const Color(0xFFFF6B6B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                trailing: isCurrent 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Current',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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
            color: const Color(0xFF111111),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: const Color(0xFF6C63FF),
              indicatorWeight: 3,
              tabs: List.generate(12, (index) => Tab(text: 'W${index + 1}')),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: List.generate(12, (weekIndex) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF000000),
                        Color(0xFF111111),
                      ],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week ${weekIndex + 1} Reflection',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            maxLines: 12,
                            decoration: const InputDecoration(
                              hintText: 'What did you learn this week?\nWhat worked well?\nWhat would you do differently?\nHow did you feel about your progress?',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(20),
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
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C63FF).withOpacity(0.1),
                                const Color(0xFF9C88FF).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Reflection Prompts',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '• What specific actions moved you closer to your goal?\n'
                                '• What obstacles did you encounter and how did you handle them?\n'
                                '• What patterns are you noticing in your behavior?\n'
                                '• How can you improve your execution next week?\n'
                                '• What are you most proud of this week?',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(IconData icon, String title, String date, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          '$title: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          date,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _deleteGoal(); // Delete and return to previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// Goal Edit Wizard with enhanced design
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
        SnackBar(
          content: const Text('Please enter a goal title'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Goal'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: TextButton(
              onPressed: _saveGoal,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF111111),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
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
                    selectedColor: const Color(0xFF6C63FF).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF6C63FF),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...Priority.values.map((priority) {
                return RadioListTile<Priority>(
                  title: Text(priority.name.toUpperCase()),
                  value: priority,
                  groupValue: _priority,
                  onChanged: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                  activeColor: const Color(0xFF6C63FF),
                );
              }),
              
              const SizedBox(height: 20),
              
              TextField(
                controller: _visionController,
                decoration: const InputDecoration(
                  labelText: 'Vision Statement',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Why Reasons',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _whyControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Reason ${index + 1}',
                    ),
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              Text(
                'Target Execution Score',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '${_targetScore.toInt()}%',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Slider(
                      value: _targetScore,
                      min: 50,
                      max: 100,
                      divisions: 10,
                      activeColor: const Color(0xFF6C63FF),
                      onChanged: (value) => setState(() => _targetScore = value),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}