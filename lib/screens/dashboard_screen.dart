import 'package:flutter/material.dart';
import '../models/goal_data.dart';
import '../widgets/execution_chart.dart';
import '../widgets/weekly_summary_card.dart';
import '../widgets/goal_progress_ring.dart';

class DashboardScreen extends StatelessWidget {
  final List<Goal> goals;

  const DashboardScreen({super.key, required this.goals});

  @override
  Widget build(BuildContext context) {
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    final averageExecution = activeGoals.isEmpty
        ? 0.0
        : activeGoals.map((g) => g.executionScore).reduce((a, b) => a + b) / activeGoals.length;

    final onTrackGoals = activeGoals.where((g) => g.isOnTrack).length;
    final urgentGoals = activeGoals.where((g) => g.daysRemaining < 14).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh logic would go here
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Stats
              _buildStatsOverview(activeGoals, completedGoals, averageExecution, onTrackGoals),

              const SizedBox(height: 24),

              // Execution Chart
              if (activeGoals.isNotEmpty) ...[
                const Text(
                  'Execution Trends',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ExecutionChart(goals: activeGoals),
                const SizedBox(height: 24),
              ],

              // Weekly Summary
              const Text(
                'This Week\'s Focus',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              WeeklySummaryCard(goals: activeGoals),

              const SizedBox(height: 24),

              // Urgent Goals
              if (urgentGoals.isNotEmpty) ...[
                const Text(
                  'Urgent Goals (< 14 days)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ...urgentGoals.map((goal) => _buildUrgentGoalCard(goal)),
                const SizedBox(height: 24),
              ],

              // Goal Progress Rings
              if (activeGoals.isNotEmpty) ...[
                const Text(
                  'Goal Progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: activeGoals.length,
                  itemBuilder: (context, index) {
                    return GoalProgressRing(goal: activeGoals[index]);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(List<Goal> activeGoals, List<Goal> completedGoals,
      double averageExecution, int onTrackGoals) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Goals',
            '${activeGoals.length}',
            Icons.flag,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '${completedGoals.length}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Avg Execution',
            '${averageExecution.toInt()}%',
            Icons.trending_up,
            averageExecution >= 85 ? Colors.green : Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'On Track',
            '$onTrackGoals/${activeGoals.length}',
            Icons.track_changes,
            onTrackGoals == activeGoals.length ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentGoalCard(Goal goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.withOpacity(0.1),
          child: Icon(Icons.warning, color: Colors.red),
        ),
        title: Text(goal.title),
        subtitle: Text('${goal.daysRemaining} days remaining'),
        trailing: Text(
          '${goal.executionScore.toInt()}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: goal.isOnTrack ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}