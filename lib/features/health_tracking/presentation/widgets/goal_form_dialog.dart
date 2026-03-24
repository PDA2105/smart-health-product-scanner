import 'package:flutter/material.dart';

import '../../../../data/models/health_goal_model.dart';

/// Dialog for creating or editing health goals.
class GoalFormDialog extends StatefulWidget {
  const GoalFormDialog({
    super.key,
    this.goal,
    required this.onSave,
  });

  final HealthGoalModel? goal;
  final Function(HealthGoalType, double, DateTime, String?) onSave;

  @override
  State<GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<GoalFormDialog> {
  late HealthGoalType _selectedGoalType;
  late TextEditingController _targetWeightController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _selectedGoalType = widget.goal!.goalType;
      _targetWeightController =
          TextEditingController(text: widget.goal!.targetWeight.toString());
      _notesController =
          TextEditingController(text: widget.goal!.notes ?? '');
      _selectedDate = widget.goal!.targetDate;
    } else {
      _selectedGoalType = HealthGoalType.maintainWeight;
      _targetWeightController = TextEditingController();
      _notesController = TextEditingController();
      _selectedDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (_targetWeightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng nhập trọng lượng mục tiêu')),
      );
      return;
    }

    final targetWeight = double.tryParse(_targetWeightController.text);
    if (targetWeight == null || targetWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Trọng lượng không hợp lệ')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onSave(
        _selectedGoalType,
        targetWeight,
        _selectedDate,
        _notesController.text.isNotEmpty ? _notesController.text : null,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? 'Tạo mục tiêu mới' : 'Cập nhật mục tiêu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Type Selector
            Text('Loại mục tiêu', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<HealthGoalType>(
              segments: const [
                ButtonSegment(
                  value: HealthGoalType.losWeight,
                  label: Text('Giảm cân'),
                  icon: Icon(Icons.trending_down),
                ),
                ButtonSegment(
                  value: HealthGoalType.maintainWeight,
                  label: Text('Giữ cân'),
                  icon: Icon(Icons.remove),
                ),
                ButtonSegment(
                  value: HealthGoalType.gainWeight,
                  label: Text('Tăng cân'),
                  icon: Icon(Icons.trending_up),
                ),
              ],
              selected: {_selectedGoalType},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedGoalType = newSelection.first);
              },
            ),
            const SizedBox(height: 16),

            // Target Weight
            TextField(
              controller: _targetWeightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Trọng lượng mục tiêu (kg)',
                hintText: 'Ví dụ: 65.0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 16),

            // Target Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Ngày hoàn thành'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                hintText: 'Ví dụ: Chuẩn bị cho kỳ thi thể dục',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }
}
