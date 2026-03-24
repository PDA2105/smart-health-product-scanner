import 'package:flutter/material.dart';

import '../../../../data/models/weight_entry_model.dart';
import '../providers/health_tracking_provider.dart';

/// Card widget displaying weight statistics and trends.
class WeightStatsCard extends StatelessWidget {
  const WeightStatsCard({
    super.key,
    this.latestWeight,
    required this.weightHistory,
    required this.onRefresh,
  });

  final double? latestWeight;
  final List<WeightEntryModel> weightHistory;
  final VoidCallback onRefresh;

  String _getWeightTrend() {
    if (weightHistory.length < 2) return 'N/A';

    final latest = weightHistory.first.weight;
    final previous = weightHistory.length > 1 ? weightHistory[1].weight : 0;

    final diff = latest - previous;
    if (diff == 0) return '→ Không thay đổi';
    if (diff > 0) {
      return '📈 +${diff.toStringAsFixed(1)} kg';
    } else {
      return '📉 ${diff.toStringAsFixed(1)} kg';
    }
  }

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
                Text(
                  'Cân nặng hiện tại',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                )
              ],
            ),
            const SizedBox(height: 12),
            if (latestWeight != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    latestWeight!.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'kg',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Thay đổi gần đây: ${_getWeightTrend()}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tổng: ${weightHistory.length} entries',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Chưa có dữ liệu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
