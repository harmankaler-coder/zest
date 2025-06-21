import 'package:flutter/material.dart';
import '../goal_data.dart';

class GoalListScreen extends StatefulWidget {
  const GoalListScreen({super.key});

  @override
  GoalListScreenState createState() => GoalListScreenState();
}

class GoalListScreenState extends State<GoalListScreen> {
  final List<Goal> goals = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addGoal(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      goals.add(Goal(
        title: title.trim(),
        startDate: DateTime.now(),
      ));
    });
    _controller.clear();
  }

  void _toggleWeek(Goal goal, int weekIndex) {
    setState(() {
      goal.weeklyProgress[weekIndex] = !goal.weeklyProgress[weekIndex];
    });
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Goal'),
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(hintText: 'Enter goal title'),
            onSubmitted: (value) {
              _addGoal(value);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addGoal(_controller.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                _controller.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekToggle(Goal goal, int weekIndex) {
    bool completed = goal.weeklyProgress[weekIndex];
    return GestureDetector(
      onTap: () => _toggleWeek(goal, weekIndex),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: completed ? Colors.indigo : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.indigo),
        ),
        child: Center(
          child: Text(
            '${weekIndex + 1}',
            style: TextStyle(
                color: completed ? Colors.white : Colors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(Goal goal) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900]),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              minHeight: 8,
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  12,
                  (index) => _buildWeekToggle(goal, index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('12 Week Year Goals'),
        centerTitle: true,
      ),
      body: goals.isEmpty
          ? Center(
              child: Text(
                'No goals yet.\nTap + to add your first goal!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 12, bottom: 80),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return _buildGoalCard(goals[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        tooltip: 'Add Goal',
        child: Icon(Icons.add),
      ),
    );
  }
}