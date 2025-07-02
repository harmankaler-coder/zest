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
        return const Color(0xFFFF6B6B);
      case Priority.medium:
        return const Color(0xFFFFB74D);
      case Priority.low:
        return const Color(0xFF4ECDC4);
    }
  }

  Color _getCategoryColor() {
    switch (goal.category) {
      case GoalCategory.personal:
        return const Color(0xFF6C63FF);
      case GoalCategory.professional:
        return const Color(0xFF9C88FF);
      case GoalCategory.health:
        return const Color(0xFF4ECDC4);
      case GoalCategory.financial:
        return const Color(0xFFFFB74D);
      case GoalCategory.relationships:
        return const Color(0xFFFF6B9D);
      case GoalCategory.learning:
        return const Color(0xFF4ECDC4);
      case GoalCategory.spiritual:
        return const Color(0xFF9C88FF);
      case GoalCategory.other:
        return const Color(0xFF8E8E93);
    }
  }

  @override
  Widget build(BuildContext context) {
    final executionScore = goal.executionScore;
    final isOnTrack = goal.isOnTrack;
    final currentWeek = goal.currentWeek;
    final daysRemaining = goal.daysRemaining;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and priority
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: goal.isCompleted ? Colors.white54 : Colors.white,
                          decoration: goal.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getPriorityColor(),
                            _getPriorityColor().withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        goal.priority.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Category and week info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        goal.categoryDisplayName,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: _getCategoryColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Week ${currentWeek + 1}/12',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress: ${goal.completedWeeks}/12 weeks',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(goal.progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white12,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            goal.isCompleted 
                                ? const Color(0xFF4ECDC4)
                                : const Color(0xFF6C63FF),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Execution score and status
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Execution Score',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${executionScore.toInt()}%',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isOnTrack ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                isOnTrack ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                size: 18,
                                color: isOnTrack ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B),
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$daysRemaining',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: daysRemaining < 14 ? const Color(0xFFFF6B6B) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                
                if (goal.isCompleted)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Completed',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}