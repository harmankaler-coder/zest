import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
              'Execution Trends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (goals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No active goals to display',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 20,
                      verticalInterval: 2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 2,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                'W${value.toInt() + 1}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 25,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    minX: 0,
                    maxX: 11,
                    minY: 0,
                    maxY: 100,
                    lineBarsData: goals.take(3).map((goal) => _createLineChartBarData(goal)).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Legend
            Wrap(
              spacing: 16,
              children: goals.take(3).map((goal) {
                final color = _getGoalColor(goals.indexOf(goal));
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
                      goal.title.length > 15
                          ? '${goal.title.substring(0, 15)}...'
                          : goal.title,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _createLineChartBarData(Goal goal) {
    final spots = <FlSpot>[];

    for (int week = 0; week <= goal.currentWeek && week < 12; week++) {
      final weekActions = goal.weeklyActions[week];
      final completedActions = weekActions.where((a) => a.isCompleted).length;
      final totalActions = weekActions.length;
      final weekScore = totalActions > 0 ? (completedActions / totalActions) * 100 : 0.0;

      spots.add(FlSpot(week.toDouble(), weekScore.clamp(0.0, 100.0)));
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }

    final color = _getGoalColor(goals.indexOf(goal));

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }

  Color _getGoalColor(int index) {
    final colors = [
      const Color(0xFF667eea),
      const Color(0xFF764ba2),
      Colors.green,
      Colors.orange,
      Colors.red,
    ];
    return colors[index % colors.length];
  }
}