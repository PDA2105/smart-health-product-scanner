import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/scan_history_model.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../routes/app_routes.dart';
import '../providers/scan_history_provider.dart';

class ScanHistoryPage extends StatefulWidget {
  const ScanHistoryPage({super.key});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load scan history when page opens
    Future.microtask(() {
      context.read<ScanHistoryProvider>().loadScanHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      appBar: AppBar(
        title: const Text('Lịch sử quét'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ScanHistoryProvider>(
            builder: (context, provider, child) {
              if (provider.scanHistory.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _showClearConfirmDialog(context);
                },
                tooltip: 'Xóa tất cả',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics section
          Consumer<ScanHistoryProvider>(
            builder: (context, provider, _) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatCard(
                      label: 'Tổng quét',
                      value: '${provider.scanHistory.length}',
                    ),
                    _StatCard(
                      label: 'Tháng này',
                      value: '${_getThisMonthCount(provider.scanHistory)}',
                    ),
                    _StatCard(
                      label: 'Hôm nay',
                      value: '${_getTodayCount(provider.scanHistory)}',
                    ),
                  ],
                ),
              );
            },
          ),
          // List of scan history items
          Expanded(
            child: Consumer<ScanHistoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Lỗi: ${provider.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (provider.scanHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có lịch sử quét',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bắt đầu quét sản phẩm để xem lịch sử',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.scanHistory.length,
                  itemBuilder: (context, index) {
                    final history = provider.scanHistory[index];
                    final timeAgo = _getTimeAgo(history.timestamp);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFFE9F7EF),
                            child: history.productImage != null
                                ? Image.network(
                              history.productImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF27AE60),
                              ),
                            )
                                : const Icon(
                              Icons.local_drink,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                        ),
                        title: Text(
                          history.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (history.brands != null)
                              Text(
                                history.brands!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                if (history.nutriscore != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getNutriscoreColor(history.nutriscore!),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Nutriscore ${history.nutriscore!}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        onTap: () async {
                          // Navigate to product details
                          // Fetch full product with nutriments from Firestore
                          try {
                            final product = await context
                                .read<ProductRepository>()
                                .getProductByBarcode(
                              history.barcode,
                              forceRefresh: false, // Use cache if available
                            );
                            if (!mounted) return;
                            if (product != null) {
                              context.navigateToProductDetail(product);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Không thể tải thông tin sản phẩm'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: ${e.toString()}'),
                              ),
                            );
                          }
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            provider.deleteScanHistoryItem(history.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 66,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _FooterTab(
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () => context.navigateToHome(),
            ),
            _FooterTab(
              icon: Icons.favorite_border,
              label: 'Favorite',
              onTap: () => context.navigateToWishlist(),
            ),
            _FooterTab(
              icon: Icons.history,
              label: 'History',
              active: true,
              onTap: () {},
            ),
            _FooterTab(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () => context.navigateToProfile(),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows confirm dialog to clear all history
  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử?'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử quét?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<ScanHistoryProvider>().clearScanHistory();
              Navigator.pop(context);
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats timestamp to relative time string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return dateTime.toString().split(' ')[0];
    }
  }

  /// Gets count of items scanned this month
  int _getThisMonthCount(List<ScanHistoryModel> items) {
    final now = DateTime.now();
    return items.where((item) {
      return item.timestamp.year == now.year && item.timestamp.month == now.month;
    }).length;
  }

  /// Gets count of items scanned today
  int _getTodayCount(List<ScanHistoryModel> items) {
    final today = DateTime.now();
    return items.where((item) {
      final itemDate = item.timestamp;
      return itemDate.year == today.year &&
          itemDate.month == today.month &&
          itemDate.day == today.day;
    }).length;
  }

  /// Gets color for nutriscore badge
  Color _getNutriscoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.yellow;
      case 'D':
        return Colors.orange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Footer tab widget for bottom navigation
class _FooterTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _FooterTab({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF2ECC71) : Colors.grey[500],
            size: active ? 28 : 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? const Color(0xFF2ECC71) : Colors.grey[500],
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistics card widget
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
