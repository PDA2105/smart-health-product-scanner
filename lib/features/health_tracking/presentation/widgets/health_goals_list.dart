import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/health_goal_model.dart';

/// Widget to display list of health goals.
class HealthGoalsList extends StatelessWidget {
  const HealthGoalsList({
    super.key,
    required this.goals,
    required this.onEdit,
    required this.onDelete,
  });

  final List<HealthGoalModel> goals;
  final Function(HealthGoalModel) onEdit;
  final Function(String) onDelete;

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _getGoalTypeColor(HealthGoalType type) {
    switch (type) {
      case HealthGoalType.losWeight:
        return Colors.red;
      case HealthGoalType.gainWeight:
        return Colors.green;
      case HealthGoalType.maintainWeight:
        return Colors.blue;
    }
  }

  String _getGoalTypeIcon(HealthGoalType type) {
    switch (type) {
      case HealthGoalType.losWeight:
        return '📉';
      case HealthGoalType.gainWeight:
        return '📈';
      case HealthGoalType.maintainWeight:
        return '⏸️';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Không có mục tiêu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final color = _getGoalTypeColor(goal.goalType);
        final daysRemaining = goal.daysRemaining;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              foregroundColor: color,
              child: Text(_getGoalTypeIcon(goal.goalType)),
            ),
            title: Text('${goal.targetWeight.toStringAsFixed(1)} kg'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Đến ngày ${_formatDate(goal.targetDate)}'),
                const SizedBox(height: 2),
                if (goal.isOverdue)
                  const Text(
                    '⚠️ Đã quá hạn',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )
                else
                  Text(
                    'Còn ${daysRemaining} ngày',
                    style: const TextStyle(fontSize: 12),
                  ),
                if (goal.notes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    goal.notes!,
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Chỉnh sửa'),
                  onTap: () => onEdit(goal),
                ),
                PopupMenuItem(
                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onTap: () => _showDeleteDialog(context, goal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, HealthGoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục tiêu?'),
        content: Text('Xóa mục tiêu ${goal.targetWeight}kg?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              onDelete(goal.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
