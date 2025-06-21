import 'package:flutter/material.dart';
import '../models/goal_data.dart';
import '../services/storage_service.dart';
import '../widgets/goal_card_enhanced.dart';
import 'goal_creation_wizard.dart';
import 'goal_detail_enhanced.dart';
import 'dashboard_screen.dart';
import 'weekly_planning_screen.dart';
import 'settings_screen.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen> {
  List<Goal> goals = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() => isLoading = true);
    final loadedGoals = await StorageService.loadGoals();
    setState(() {
      goals = loadedGoals;
      isLoading = false;
    });
  }

  Future<void> _saveGoals() async {
    await StorageService.saveGoals(goals);
  }

  void _addGoal(Goal goal) {
    setState(() {
      goals.add(goal);
    });
    _saveGoals();
  }

  void _updateGoal(Goal updatedGoal) {
    setState(() {
      final index = goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        goals[index] = updatedGoal;
      }
    });
    _saveGoals();
  }

  void _deleteGoal(Goal goal) {
    setState(() {
      goals.remove(goal);
    });
    _saveGoals();
  }

  void _navigateToGoalCreation() async {
    final newGoal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute(builder: (context) => const GoalCreationWizard()),
    );
    if (newGoal != null) {
      _addGoal(newGoal);
    }
  }

  void _navigateToGoalDetail(Goal goal) async {
    final updatedGoal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute(
        builder: (context) => GoalDetailEnhanced(goal: goal),
      ),
    );
    if (updatedGoal != null) {
      _updateGoal(updatedGoal);
    }
  }

  Widget _buildGoalsList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No 12-Week Goals Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first goal to start your\n12-week transformation journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToGoalCreation,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Sort goals by priority and current week
    final sortedGoals = List<Goal>.from(goals);
    sortedGoals.sort((a, b) {
      // First by completion status
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then by priority
      if (a.priority != b.priority) {
        return a.priority.index.compareTo(b.priority.index);
      }
      // Finally by start date
      return a.startDate.compareTo(b.startDate);
    });

    return RefreshIndicator(
      onRefresh: _loadGoals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedGoals.length,
        itemBuilder: (context, index) {
          final goal = sortedGoals[index];
          return Dismissible(
            key: Key(goal.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 32),
            ),
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Goal'),
                  content: Text('Are you sure you want to delete "${goal.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) => _deleteGoal(goal),
            child: GoalCardEnhanced(
              goal: goal,
              onTap: () => _navigateToGoalDetail(goal),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildGoalsList(),
      DashboardScreen(goals: goals),
      WeeklyPlanningScreen(
        goals: goals,
        onGoalUpdated: _updateGoal,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('12 Week Year'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _navigateToGoalCreation,
              tooltip: 'Add New Goal',
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Weekly Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}