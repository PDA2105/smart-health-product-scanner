import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_tracking_provider.dart';

/// Page for viewing health statistics and analytics.
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<double?> _weightProgressFuture;
  late Future<double> _avgHealthScore7Days;
  late Future<double> _avgHealthScore30Days;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final provider = context.read<HealthTrackingProvider>();
    setState(() {
      _weightProgressFuture = provider.calculateWeightProgress();
      _avgHealthScore7Days = provider.getAverageHealthScore(lastDays: 7);
      _avgHealthScore30Days = provider.getAverageHealthScore(lastDays: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        elevation: 0,
      ),
      body: Consumer<HealthTrackingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weight Statistics
                _buildSection(
                  context,
                  title: 'Thống kê cân nặng',
                  content: _buildWeightStats(context, provider),
                ),
                const SizedBox(height: 24),

                // Health Score Statistics
                _buildSection(
                  context,
                  title: 'Thống kê điểm sức khỏe',
                  content: _buildHealthScoreStats(context),
                ),
                const SizedBox(height: 24),

                // Nutritional Statistics
                if (provider.healthScoreHistory.isNotEmpty)
                  _buildSection(
                    context,
                    title: 'Dinh dưỡng trung bình (7 ngày gần nhất)',
                    content: _buildNutritionalStats(context, provider),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildWeightStats(
      BuildContext context, HealthTrackingProvider provider) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng entries',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${provider.weightHistory.length}',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tiến trình',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<double?>(
                      future: _weightProgressFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        final progress = snapshot.data;
                        final color = progress == null
                            ? Colors.grey
                            : progress < 0
                                ? Colors.green
                                : Colors.red;
                        return Text(
                          progress == null
                              ? 'N/A'
                              : progress < 0
                                  ? '${progress.toStringAsFixed(1)} kg'
                                  : '+${progress.toStringAsFixed(1)} kg',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (provider.weightHistory.length >= 2)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cân nặng',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cao nhất',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.weightHistory.reduce((a, b) => a.weight > b.weight ? a : b).weight.toStringAsFixed(1)} kg',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thấp nhất',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.weightHistory.reduce((a, b) => a.weight < b.weight ? a : b).weight.toStringAsFixed(1)} kg',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trung bình',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(provider.weightHistory.fold<double>(0, (sum, e) => sum + e.weight) / provider.weightHistory.length).toStringAsFixed(1)} kg',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHealthScoreStats(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<double>(
          future: _avgHealthScore7Days,
          builder: (context, snapshot) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trung bình 7 ngày',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.data?.toStringAsFixed(1) ?? 'N/A',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getScoreColor(snapshot.data ?? 0)
                            .withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          snapshot.data != null
                              ? '${(snapshot.data! / 10 * 100).toStringAsFixed(0)}%'
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(snapshot.data ?? 0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        FutureBuilder<double>(
          future: _avgHealthScore30Days,
          builder: (context, snapshot) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trung bình 30 ngày',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.data?.toStringAsFixed(1) ?? 'N/A',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getScoreColor(snapshot.data ?? 0)
                            .withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          snapshot.data != null
                              ? '${(snapshot.data! / 10 * 100).toStringAsFixed(0)}%'
                              : 'N/A',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getScoreColor(snapshot.data ?? 0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNutritionalStats(
      BuildContext context, HealthTrackingProvider provider) {
    if (provider.healthScoreHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get last 7 days of data
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentEntries = provider.healthScoreHistory
        .where((e) => e.recordedDate.isAfter(sevenDaysAgo))
        .toList();

    if (recentEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Không có dữ liệu 7 ngày gần nhất',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final avgCalories =
        recentEntries.fold<double>(0, (sum, e) => sum + e.totalCalories) /
            recentEntries.length;
    final avgProtein =
        recentEntries.fold<double>(0, (sum, e) => sum + e.totalProtein) /
            recentEntries.length;
    final avgFat =
        recentEntries.fold<double>(0, (sum, e) => sum + e.totalFat) /
            recentEntries.length;
    final avgCarbs =
        recentEntries.fold<double>(0, (sum, e) => sum + e.totalCarbs) /
            recentEntries.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _NutritionRow(
              label: 'Calories',
              value: avgCalories.toStringAsFixed(1),
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _NutritionRow(
              label: 'Protein',
              value: avgProtein.toStringAsFixed(1),
              icon: Icons.egg,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            _NutritionRow(
              label: 'Fat',
              value: avgFat.toStringAsFixed(1),
              icon: Icons.opacity,
              color: Colors.yellow,
            ),
            const SizedBox(height: 12),
            _NutritionRow(
              label: 'Carbs',
              value: avgCarbs.toStringAsFixed(1),
              icon: Icons.grain,
              color: Colors.brown,
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }
}

/// Widget for displaying a single nutrition row.
class _NutritionRow extends StatelessWidget {
  const _NutritionRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
