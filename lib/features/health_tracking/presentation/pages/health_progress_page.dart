import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_tracking_provider.dart';
import '../widgets/progress_timeline_widget.dart';

/// Page for viewing health progress and trends.
class HealthProgressPage extends StatefulWidget {
  const HealthProgressPage({super.key});

  @override
  State<HealthProgressPage> createState() => _HealthProgressPageState();
}

class _HealthProgressPageState extends State<HealthProgressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthTrackingProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiến trình sức khỏe'),
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
                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Cân nặng',
                        value: provider.latestWeightEntry?.weight != null
                            ? '${provider.latestWeightEntry!.weight.toStringAsFixed(1)} kg'
                            : 'N/A',
                        icon: Icons.scale,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Mục tiêu',
                        value: provider.activeGoals.isNotEmpty
                            ? '${provider.activeGoals.length} đang hoạt động'
                            : 'Không có',
                        icon: Icons.flag,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Điểm sức khỏe',
                        value:
                            '${provider.averageHealthScoreFromLatestEntries.toStringAsFixed(1)}/10',
                        icon: Icons.favorite,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Log lịch sử',
                        value: '${provider.weightHistory.length} entries',
                        icon: Icons.history,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Weight Timeline
                if (provider.weightHistory.isNotEmpty) ...[
                  Text(
                    'Lịch sử cân nặng',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ProgressTimelineWidget(
                    entries: provider.weightHistory,
                  ),
                  const SizedBox(height: 24),
                ],

                // Health Score Timeline
                if (provider.healthScoreHistory.isNotEmpty) ...[
                  Text(
                    'Lịch sử điểm sức khỏe',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.healthScoreHistory.length,
                    itemBuilder: (context, index) {
                      final entry = provider.healthScoreHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: _getHealthScoreColor(
                                        entry.averageScore)
                                    .withOpacity(0.2),
                                foregroundColor:
                                    _getHealthScoreColor(entry.averageScore),
                                child: const Icon(Icons.favorite),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${entry.averageScore.toStringAsFixed(1)}/10',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      '${entry.scannedProductsCount} sản phẩm • ${entry.recordedDate.toString().split(' ')[0]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Chưa có dữ liệu tiến trình',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.orange;
    return Colors.red;
  }
}

/// Summary card widget for displaying key metrics.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
