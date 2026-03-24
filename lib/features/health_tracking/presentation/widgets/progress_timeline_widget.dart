import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/weight_entry_model.dart';

/// Timeline widget for displaying weight progress.
class ProgressTimelineWidget extends StatelessWidget {
  const ProgressTimelineWidget({
    super.key,
    required this.entries,
  });

  final List<WeightEntryModel> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: List.generate(
            entries.length > 5 ? 5 : entries.length,
            (index) {
              final entry = entries[index];
              final nextEntry =
                  index < entries.length - 1 ? entries[index + 1] : null;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < (entries.length > 5 ? 4 : entries.length - 1)
                      ? 12
                      : 0,
                ),
                child: Row(
                  children: [
                    // Timeline dot
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getWeightColor(entry.weight,
                            nextEntry?.weight ?? entry.weight),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${entry.weight.toStringAsFixed(1)} kg',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              if (nextEntry != null)
                                Text(
                                  _getWeightDifference(
                                      entry.weight, nextEntry.weight),
                                  style:
                                      Theme.of(context).textTheme.labelSmall,
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd MMM yyyy')
                                .format(entry.recordedDate),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              );
              },
            ),
          ),
        ),
      );
  }

  Color _getWeightColor(double current, double previous) {
    if (current < previous) return Colors.green; // Weight loss
    if (current > previous) return Colors.red; // Weight gain
    return Colors.blue; // No change
  }

  String _getWeightDifference(double current, double previous) {
    final diff = current - previous;
    if (diff == 0) return '→';
    if (diff > 0) {
      return '📈 +${diff.toStringAsFixed(1)}';
    } else {
      return '📉 ${diff.toStringAsFixed(1)}';
    }
  }
}
