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
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => GoalDetailEnhanced(goal: goal),
      ),
    );
    
    if (result != null) {
      if (result['action'] == 'update') {
        _updateGoal(result['goal']);
      } else if (result['action'] == 'delete') {
        _deleteGoal(result['goal']);
      }
    }
  }

  Widget _buildGoalsList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C63FF),
        ),
      );
    }

    if (goals.isEmpty) {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'No 12-Week Goals Yet',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Create your first goal to start your\n12-week transformation journey',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _navigateToGoalCreation,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Create Your First Goal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
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
      color: const Color(0xFF6C63FF),
      backgroundColor: const Color(0xFF111111),
      child: Container(
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
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sortedGoals.length,
          itemBuilder: (context, index) {
            final goal = sortedGoals[index];
            return Dismissible(
              key: Key(goal.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF5252)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
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
              },
              onDismissed: (direction) => _deleteGoal(goal),
              child: GoalCardEnhanced(
                goal: goal,
                onTap: () => _navigateToGoalDetail(goal),
              ),
            );
          },
        ),
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
      SettingsScreen(
        onDataCleared: () {
          setState(() {
            goals.clear();
          });
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '12 Week Year',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (_selectedIndex == 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: _navigateToGoalCreation,
                tooltip: 'Add New Goal',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_rounded),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Weekly Plan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}