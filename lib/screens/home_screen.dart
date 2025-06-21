import 'package:flutter/material.dart';
import 'package:twelve_week/screens/stats_screen.dart';

import '../goal_data.dart';
import 'goal_card.dart';
import 'goal_detail_screen.dart';
import 'goal_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Goal> goals = [];

  void _addGoal(Goal goal) {
    setState(() {
      goals.add(goal);
    });
  }

  void _updateGoal(Goal oldGoal, Goal updatedGoal) {
    setState(() {
      int idx = goals.indexOf(oldGoal);
      if (idx != -1) {
        goals[idx] = updatedGoal;
      }
    });
  }

  void _deleteGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Goal'),
          content: Text('Are you sure you want to delete "${goal.title}"?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  goals.remove(goal);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddGoal() async {
    final newGoal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute(builder: (context) => GoalEditScreen()),
    );
    if (newGoal != null) {
      _addGoal(newGoal);
    }
  }

  void _navigateToGoalDetail(Goal goal) async {
    final updatedGoal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute(builder: (context) => GoalDetailScreen(goal: goal)),
    );
    if (updatedGoal != null) {
      _updateGoal(goal, updatedGoal);
    }
  }

  void _navigateToStats() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => StatsScreen(goals: goals)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.indigo.shade50, Colors.indigo.shade200],
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text('ZEST'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: _navigateToStats,
            tooltip: 'View Stats',
            splashRadius: 24,
            splashColor: Colors.indigo.shade300.withOpacity(0.3),
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
      body: goals.isEmpty
          ? Center(
        child: Text(
          'No goals yet.\nTap + to add your first goal!',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return Dismissible(
            key: Key(goal.title + goal.startDate.toIso8601String()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              bool confirm = false;
              await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Delete Goal'),
                  content: Text('Are you sure you want to delete "${goal.title}"?'),
                  actions: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        confirm = false;
                      },
                    ),
                    TextButton(
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        confirm = true;
                      },
                    ),
                  ],
                ),
              );
              return confirm;
            },
            onDismissed: (direction) {
              setState(() {
                goals.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${goal.title}"')),
              );
            },
            child: GestureDetector(
              onTap: () => _navigateToGoalDetail(goal),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.shade100.withOpacity(0.5),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: GoalCard(goal: goal),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddGoal,
        tooltip: 'Add Goal',
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 8,
        splashColor: Colors.indigo.shade100,
        child: Icon(Icons.add, size: 30),
      ),
    );
  }
}