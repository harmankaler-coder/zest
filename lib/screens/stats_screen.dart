import 'package:flutter/material.dart';

import '../goal_data.dart';

class StatsScreen extends StatelessWidget {
  final List<Goal> goals;

  const StatsScreen({super.key, required this.goals});

  AppBar _buildGradientAppBar({required String title}) {
    return AppBar(
      title: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [Colors.indigo.shade50, Colors.indigo.shade200],
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Text(title),
      ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Scaffold(
        appBar: _buildGradientAppBar(title: 'Stats'),
        body: Center(
          child: Text(
            'No goals to show stats for.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildGradientAppBar(title: 'Stats'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: goals
              .map(
                (goal) => Card(
              elevation: 5,
              shadowColor: Colors.indigo.shade100,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding:
                EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                title: Text(
                  goal.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 16,
                      backgroundColor: Colors.indigo.shade50,
                      valueColor:
                      AlwaysStoppedAnimation(Colors.indigo.shade600),
                    ),
                  ),
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade300.withOpacity(0.6),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  padding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    '${goal.completedWeeks}/12',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.indigo.shade900.withOpacity(0.8),
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}