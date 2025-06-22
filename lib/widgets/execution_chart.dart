import 'package:flutter/material.dart';
import '../models/goal_data.dart';

class ExecutionChart extends StatelessWidget {
  final List<Goal> goals;

  const ExecutionChart({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Execution Scores',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (goals.isEmpty)
              const Center(
                child: Text(
                  'No active goals to display',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: goals.map((goal) {
                  final score = goal.executionScore;
                  final isOnTrack = goal.isOnTrack;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                goal.title,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${score.toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isOnTrack ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: score / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isOnTrack ? Colors.green : Colors.red,
                          ),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}