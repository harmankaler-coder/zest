import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Execution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${goal.executionScore.toInt()}% Overall',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: goal.isOnTrack ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final week = group.x.toInt() + 1;
                        final score = rod.toY.toInt();
                        return BarTooltipItem(
                          'Week $week\n$score%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
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
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt() + 1}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
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
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _createBarGroups(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Completed', Colors.green),
                _buildLegendItem('Current', const Color(0xFF667eea)),
                _buildLegendItem('Behind', Colors.red),
                _buildLegendItem('Future', Colors.grey[300]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    final groups = <BarChartGroupData>[];

    for (int week = 0; week < 12; week++) {
      final weekActions = goal.weeklyActions[week];
      final completedActions = weekActions.where((a) => a.isCompleted).length;
      final totalActions = weekActions.length;
      final weekScore = totalActions > 0 ? (completedActions / totalActions) * 100 : 0.0;

      Color barColor;
      if (goal.weeklyProgress[week]) {
        barColor = Colors.green;
      } else if (week == goal.currentWeek) {
        barColor = const Color(0xFF667eea);
      } else if (week < goal.currentWeek) {
        barColor = weekScore >= goal.targetScore ? Colors.green : Colors.red;
      } else {
        barColor = Colors.grey[300]!;
      }

      groups.add(
        BarChartGroupData(
          x: week,
          barRods: [
            BarChartRodData(
              toY: weekScore.clamp(0.0, 100.0),
              color: barColor,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return groups;
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