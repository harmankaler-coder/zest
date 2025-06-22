import 'package:flutter/material.dart';
import '../models/goal_data.dart';

class WeeklySummaryCard extends StatelessWidget {
  final List<Goal> goals;

  const WeeklySummaryCard({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    final currentWeekActions = <WeeklyAction>[];
    
    for (final goal in goals) {
      if (goal.currentWeek < 12) {
        currentWeekActions.addAll(goal.weeklyActions[goal.currentWeek]);
      }
    }
    
    final completedActions = currentWeekActions.where((a) => a.isCompleted).length;
    final totalActions = currentWeekActions.length;
    final completionRate = totalActions > 0 ? completedActions / totalActions : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'This Week\'s Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$completedActions/$totalActions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: completionRate >= 0.8 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (totalActions == 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No actions planned for this week',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else ...[
              LinearProgressIndicator(
                value: completionRate,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  completionRate >= 0.8 ? Colors.green : Colors.orange,
                ),
                minHeight: 8,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                '${(completionRate * 100).toInt()}% Complete',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: completionRate >= 0.8 ? Colors.green : Colors.orange,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Show some upcoming actions
              ...currentWeekActions
                  .where((a) => !a.isCompleted)
                  .take(3)
                  .map((action) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle_outlined,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                action.description,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
              
              if (currentWeekActions.where((a) => !a.isCompleted).length > 3)
                Text(
                  '... and ${currentWeekActions.where((a) => !a.isCompleted).length - 3} more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}