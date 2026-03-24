import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_tracking_provider.dart';

/// Form widget for logging weight entries.
class WeightLogForm extends StatefulWidget {
  const WeightLogForm({
    super.key,
    this.currentHeight,
    required this.onWeightLogged,
  });

  final double? currentHeight;
  final VoidCallback onWeightLogged;

  @override
  State<WeightLogForm> createState() => _WeightLogFormState();
}

class _WeightLogFormState extends State<WeightLogForm> {
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Vui lòng nhập cân nặng')),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Cân nặng không hợp lệ')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<HealthTrackingProvider>().logWeight(
        weight: weight,
        currentHeight: widget.currentHeight,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      _weightController.clear();
      _notesController.clear();
      widget.onWeightLogged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            Text(
              'Nhập cân nặng',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Cân nặng (kg)',
                hintText: 'Ví dụ: 70.5',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                hintText: 'Ví dụ: Sáng, sau ăn sáng',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu cân nặng'),
              ),
            ),
            if (widget.currentHeight == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '💡 Hãy cập nhật chiều cao để tính BMI chính xác',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
