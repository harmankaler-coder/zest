import 'package:flutter/material.dart';
import '../models/goal_data.dart';

class GoalCardEnhanced extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalCardEnhanced({
    super.key,
    required this.goal,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (goal.priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  Color _getCategoryColor() {
    switch (goal.category) {
      case GoalCategory.personal:
        return const Color(0xFF667eea);
      case GoalCategory.professional:
        return const Color(0xFF764ba2);
      case GoalCategory.health:
        return Colors.green;
      case GoalCategory.financial:
        return Colors.amber;
      case GoalCategory.relationships:
        return Colors.pink;
      case GoalCategory.learning:
        return Colors.teal;
      case GoalCategory.spiritual:
        return Colors.deepPurple;
      case GoalCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final executionScore = goal.executionScore;
    final isOnTrack = goal.isOnTrack;
    final currentWeek = goal.currentWeek;
    final daysRemaining = goal.daysRemaining;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: goal.isCompleted ? Colors.grey : Colors.black87,
                        decoration: goal.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getPriorityColor(), width: 1),
                    ),
                    child: Text(
                      goal.priority.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getPriorityColor(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Category and week info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      goal.categoryDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getCategoryColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Week ${currentWeek + 1}/12',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${goal.completedWeeks}/12 weeks',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(goal.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: goal.isCompleted 
                            ? [Colors.green, Colors.green]
                            : [const Color(0xFF667eea), const Color(0xFF764ba2)],
                      ),
                    ),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Execution score and status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Execution Score',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${executionScore.toInt()}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isOnTrack ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              isOnTrack ? Icons.trending_up : Icons.trending_down,
                              size: 16,
                              color: isOnTrack ? Colors.green : Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!goal.isCompleted)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Days Remaining',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '$daysRemaining',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: daysRemaining < 14 ? Colors.red : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              if (goal.isCompleted)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
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