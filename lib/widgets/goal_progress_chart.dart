import 'package:flutter/material.dart';
import '../models/goal_data.dart';

class GoalProgressChart extends StatelessWidget {
  final Goal goal;

  const GoalProgressChart({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Execution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Container(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (index) {
                  final weekActions = goal.weeklyActions[index];
                  final completedActions = weekActions.where((a) => a.isCompleted).length;
                  final totalActions = weekActions.length;
                  final completionRate = totalActions > 0 ? completedActions / totalActions : 0.0;
                  final isCurrent = index == goal.currentWeek;
                  final isCompleted = goal.weeklyProgress[index];
                  
                  Color barColor;
                  if (isCompleted) {
                    barColor = Colors.green;
                  } else if (isCurrent) {
                    barColor = Colors.indigo;
                  } else if (index < goal.currentWeek) {
                    barColor = completionRate >= 0.8 ? Colors.green : Colors.red;
                  } else {
                    barColor = Colors.grey[300]!;
                  }
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (completionRate * 160).clamp(4.0, 160.0),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent ? Colors.indigo : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Completed', Colors.green),
                _buildLegendItem('Current', Colors.indigo),
                _buildLegendItem('Behind', Colors.red),
                _buildLegendItem('Future', Colors.grey[300]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}