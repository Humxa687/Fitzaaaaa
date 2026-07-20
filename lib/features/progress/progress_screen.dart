import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/fitness_provider.dart';
import '../../core/theme.dart';
import 'weight_ai_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress & Analytics", style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Steps"),
            Tab(text: "Calories"),
            Tab(text: "Weight"),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chart Container
              Container(
                height: 320,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStepsChart(provider, theme),
                    _buildCaloriesChart(provider, theme),
                    _buildWeightChart(provider, theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary Stats Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Monthly Goal Completions",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricRow("Step Goal Completed", "18 / 30 Days", Colors.green, 0.6),
                      const SizedBox(height: 12),
                      _buildMetricRow("Calorie Limit Kept", "24 / 30 Days", Colors.orange, 0.8),
                      const SizedBox(height: 12),
                      _buildMetricRow("Water Target Met", "21 / 30 Days", Colors.blue, 0.7),
                      const SizedBox(height: 24),
                      const Text(
                        "Daily Walking Progress",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricRow("Steps Taken", "${provider.todaySteps} / ${provider.stepGoal}", Colors.deepPurple, provider.todaySteps / provider.stepGoal),
                      const SizedBox(height: 12),
                      _buildMetricRow("Distance Covered", "${(provider.todaySteps * 0.000762).toStringAsFixed(2)} km", Colors.blue, (provider.todaySteps * 0.000762) / 5.0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _tabController.index == 2 ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WeightAiScreen()));
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text("Scan Weight"),
      ) : null,
    );
  }

  Widget _buildStepsChart(FitnessProvider provider, ThemeData theme) {
    final stepsData = [6200, 7100, 8000, 5400, 9200, 8400, provider.todaySteps];
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Steps This Week", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 20),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 12000,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(days[idx], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(stepsData.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: stepsData[index].toDouble(),
                      color: index == 6 ? FitzaTheme.primaryDark : Colors.grey.withValues(alpha: 0.3),
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesChart(FitnessProvider provider, ThemeData theme) {
    final calBurned = [350, 420, 500, 290, 610, 480, provider.caloriesBurned.toDouble()];
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Calorie Burn Progress (kcal)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < days.length) {
                        return Text(days[idx], style: const TextStyle(fontSize: 10, color: Colors.grey));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 800,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(calBurned.length, (idx) => FlSpot(idx.toDouble(), calBurned[idx].toDouble())),
                  isCurved: true,
                  color: FitzaTheme.energyOrange,
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: FitzaTheme.energyOrange.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart(FitnessProvider provider, ThemeData theme) {
    // Dynamic real weight logs, limited to last 10 entries for chart
    final history = provider.weightLogs.reversed.take(10).toList().reversed.toList();
    if (history.isEmpty) {
      return const Center(child: Text("No weight data logged yet."));
    }
    
    // Calculate min and max Y for the chart dynamically
    double minY = history.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2;
    double maxY = history.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Weight Log History (kg)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 20),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < history.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "${history[idx].date.day}/${history[idx].date.month}",
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: history.length > 1 ? (history.length - 1).toDouble() : 1.0,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(history.length, (idx) => FlSpot(idx.toDouble(), history[idx].weight)),
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.green.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, Color color, double pct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: pct,
          color: color,
          backgroundColor: color.withValues(alpha: 0.15),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
