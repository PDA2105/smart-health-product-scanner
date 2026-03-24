import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/weight_entry_model.dart';
import '../providers/health_tracking_provider.dart';

/// Widget to display list of weight entries.
class WeightListWidget extends StatelessWidget {
  const WeightListWidget({
    super.key,
    required this.weightEntries,
    required this.onDelete,
  });

  final List<WeightEntryModel> weightEntries;
  final Function(String) onDelete;

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getBMICategory(double bmi) {
    return HealthTrackingProvider.getBMICategory(bmi);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: weightEntries.length,
      itemBuilder: (context, index) {
        final entry = weightEntries[index];
        final color = _getWeightEntryColor(entry);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              foregroundColor: color,
              child: const Icon(Icons.scale),
            ),
            title: Text('${entry.weight.toStringAsFixed(1)} kg'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(_formatDate(entry.recordedDate)),
                if (entry.calculatedBMI != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'BMI: ${entry.calculatedBMI!.toStringAsFixed(1)} (${_getBMICategory(entry.calculatedBMI!)})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
                if (entry.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.notes!,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, entry),
            ),
          ),
        );
      },
    );
  }

  Color _getWeightEntryColor(WeightEntryModel entry) {
    if (entry.calculatedBMI == null) return Colors.blue;

    final bmi = entry.calculatedBMI!;
    if (bmi < 18.5) return Colors.lightBlue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _showDeleteDialog(BuildContext context, WeightEntryModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa entry?'),
        content: Text(
            'Xóa entry ${entry.weight}kg ngày ${DateFormat('dd/MM/yyyy').format(entry.recordedDate)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              onDelete(entry.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
