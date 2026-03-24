import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/health_goal_model.dart';
import '../providers/health_tracking_provider.dart';
import '../widgets/goal_form_dialog.dart';
import '../widgets/health_goals_list.dart';

/// Page for creating and managing health goals.
class GoalSettingsPage extends StatefulWidget {
  const GoalSettingsPage({super.key});

  @override
  State<GoalSettingsPage> createState() => _GoalSettingsPageState();
}

class _GoalSettingsPageState extends State<GoalSettingsPage> {
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
        title: const Text('Mục tiêu sức khỏe'),
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
                // Info Card
                Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Đặt mục tiêu sức khỏe để theo dõi tiến trình của bạn',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Active Goals
                if (provider.activeGoals.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mục tiêu đang hoạt động',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${provider.activeGoals.length}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  HealthGoalsList(
                    goals: provider.activeGoals,
                    onEdit: (goal) {
                      _showGoalFormDialog(context, provider, goal: goal);
                    },
                    onDelete: (goalId) {
                      context
                          .read<HealthTrackingProvider>()
                          .deleteHealthGoal(goalId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Đã xóa mục tiêu'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ] else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'Chưa có mục tiêu đang hoạt động',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),

                // Completed Goals
                if (provider.allGoals.any((g) => !g.isActive)) ...[
                  Text(
                    'Mục tiêu đã hoàn thành',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  HealthGoalsList(
                    goals: provider.allGoals.where((g) => !g.isActive).toList(),
                    onEdit: (goal) {
                      _showGoalFormDialog(context, provider, goal: goal);
                    },
                    onDelete: (goalId) {
                      context
                          .read<HealthTrackingProvider>()
                          .deleteHealthGoal(goalId);
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showGoalFormDialog(context, context.read<HealthTrackingProvider>());
        },
      ),
    );
  }

  void _showGoalFormDialog(
    BuildContext context,
    HealthTrackingProvider provider, {
    HealthGoalModel? goal,
  }) {
    showDialog(
      context: context,
      builder: (context) => GoalFormDialog(
        goal: goal,
        onSave: (goalType, targetWeight, targetDate, notes) async {
          try {
            if (goal == null) {
              // Create new goal
              await provider.createHealthGoal(
                goalType: goalType,
                targetWeight: targetWeight,
                targetDate: targetDate,
                notes: notes,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Mục tiêu đã được tạo'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } else {
              // Update existing goal
              await provider.updateHealthGoal(
                goal.copyWith(
                  targetWeight: targetWeight,
                  targetDate: targetDate,
                  notes: notes,
                ),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Mục tiêu đã được cập nhật'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
            if (mounted) {
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ Lỗi: $e')),
              );
            }
          }
        },
      ),
    );
  }
}
