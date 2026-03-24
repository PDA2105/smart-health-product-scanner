import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/health_tracking_provider.dart';
import '../widgets/weight_log_form.dart';
import '../widgets/weight_list_widget.dart';
import '../widgets/weight_stats_card.dart';

/// Page for tracking weight entries and viewing weight history.
class WeightTrackingPage extends StatefulWidget {
  const WeightTrackingPage({super.key});

  @override
  State<WeightTrackingPage> createState() => _WeightTrackingPageState();
}

class _WeightTrackingPageState extends State<WeightTrackingPage> {
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
        title: const Text('Theo dõi cân nặng'),
        elevation: 0,
      ),
      body: Consumer<HealthTrackingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text('Lỗi: ${provider.error}'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Weight Stats Card
                WeightStatsCard(
                  latestWeight: provider.latestWeightEntry?.weight,
                  weightHistory: provider.weightHistory,
                  onRefresh: () {
                    context.read<HealthTrackingProvider>().loadAllData();
                  },
                ),
                const SizedBox(height: 24),

                // Add Weight Entry Form
                WeightLogForm(
                  currentHeight:
                      context.read<ProfileProvider>().profile?.height,
                  onWeightLogged: () async {
                    await context.read<HealthTrackingProvider>().loadAllData();
                    final provider = context.read<HealthTrackingProvider>();
                    
                    // Show goal completion message if any
                    if (provider.error != null &&
                        provider.error!.contains('✅')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.error!),
                          duration: const Duration(seconds: 4),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Đã lưu cân nặng'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Weight History List
                if (provider.weightHistory.isNotEmpty) ...[
                  Text(
                    'Lịch sử cân nặng (${provider.weightHistory.length} entries)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  WeightListWidget(
                    weightEntries: provider.weightHistory,
                    onDelete: (entryId) {
                      context
                          .read<HealthTrackingProvider>()
                          .deleteWeightEntry(entryId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Đã xóa entry'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Chưa có dữ liệu cân nặng',
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
}
