import 'package:flutter/material.dart';
import '../models/goal_data.dart';

class GoalProgressRing extends StatelessWidget {
  final Goal goal;

  const GoalProgressRing({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.clamp(0.0, 1.0);
    final executionScore = goal.executionScore.clamp(0.0, 100.0);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress.isNaN || progress.isInfinite ? 0.0 : progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      goal.isOnTrack ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${((progress.isNaN || progress.isInfinite ? 0.0 : progress) * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(executionScore.isNaN || executionScore.isInfinite ? 0.0 : executionScore).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              goal.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Week ${(goal.currentWeek + 1).clamp(1, 12)}/12',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}