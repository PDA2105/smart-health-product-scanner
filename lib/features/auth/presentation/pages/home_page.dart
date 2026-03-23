import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/product_repository.dart';
import '../../../../features/scan/presentation/providers/scan_history_provider.dart';
import '../../../../routes/app_routes.dart';
import '../providers/auth_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final displayName = user?.displayName?.trim();
    final effectiveName =
        (displayName != null && displayName.isNotEmpty) ? displayName : 'Bạn';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF2ECC71),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: const BoxDecoration(
                  color: Color(0xCC2ECC71),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFD9D9D9),
                      child: Icon(Icons.person, size: 32, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chào buổi sáng, $effectiveName!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          if (user?.email != null)
                            Text(
                              user!.email!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bạn chưa có thông báo mới')),
                        );
                      },
                      icon: const Icon(Icons.notifications_none),
                      tooltip: 'Thông báo',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Thống kê hôm nay',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Consumer<ScanHistoryProvider>(
                builder: (context, scanHistoryProvider, child) {
                  final todayScans = _getTodayScans(scanHistoryProvider.scanHistory);
                  final warningCount = _getWarningCount(scanHistoryProvider.scanHistory);
                  final avgScore = _getAverageScore(scanHistoryProvider.scanHistory);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        _StatCard(label: 'Sản phẩm quét', value: '$todayScans'),
                        _StatCard(label: 'Cảnh báo', value: '$warningCount'),
                        _StatCard(label: 'Điểm sức khỏe', value: avgScore),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text(
                      'Quét',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Lối tắt',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ShortcutTile(
                        icon: Icons.person_outline,
                        title: 'Hồ sơ',
                        subtitle: 'Thông tin sức khỏe',
                        onTap: () => context.navigateToProfile(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShortcutTile(
                        icon: Icons.favorite_border,
                        title: 'Yêu thích',
                        subtitle: 'Sản phẩm yêu thích',
                        onTap: () => context.navigateToWishlist(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Lịch sử gần đây',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    GestureDetector(
                      onTap: () => context.navigateToScanHistory(),
                      child: const Text(
                        'Xem tất cả',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2ECC71),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Consumer<ScanHistoryProvider>(
                builder: (context, scanHistoryProvider, child) {
                  final recentScans = scanHistoryProvider.scanHistory;
                  
                  // Hiển thị tối đa 2 sản phẩm gần nhất
                  final displayItems = recentScans.take(2).toList();

                  if (displayItems.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              'Chưa có lịch sử quét',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: List.generate(
                      displayItems.length,
                      (index) {
                        final item = displayItems[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: index < displayItems.length - 1 ? 12 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              // Fetch full product with nutriments from Firestore
                              try {
                                final product = await context
                                    .read<ProductRepository>()
                                    .getProductByBarcode(
                                      item.barcode,
                                      forceRefresh: false, // Use cache if available
                                    );
                                if (product != null) {
                                  context.navigateToProductDetail(product);
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Không thể tải thông tin sản phẩm'),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Lỗi: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9F7EF),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: item.productImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.network(
                                              item.productImage!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(
                                                Icons.local_drink,
                                                color: Color(0xFF27AE60),
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.local_drink,
                                            color: Color(0xFF27AE60),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (item.brands != null)
                                          Text(
                                            item.brands!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
              label: 'Trang chủ',
              active: true,
              onTap: () {},
            ),
            _FooterTab(
              icon: Icons.favorite_border,
              label: 'Yêu thích',
              onTap: () => context.navigateToWishlist(),
            ),
            _FooterTab(
              icon: Icons.history,
              label: 'Lịch sử',
              onTap: () => context.navigateToScanHistory(),
            ),
            _FooterTab(
              icon: Icons.person_outline,
              label: 'Hồ sơ',
              onTap: () => context.navigateToProfile(),
            ),
          ],
        ),
      ),
    );
  }

  /// Lấy số lần quét hôm nay
  int _getTodayScans(List scans) {
    final today = DateTime.now();
    return scans.where((scan) {
      final scanDate = scan.timestamp;
      return scanDate.year == today.year &&
          scanDate.month == today.month &&
          scanDate.day == today.day;
    }).length;
  }

  /// Đếm cảnh báo (sản phẩm có Nutriscore D hoặc E)
  int _getWarningCount(List scans) {
    return scans.where((scan) {
      final score = scan.nutriscore?.toUpperCase() ?? '';
      return score == 'D' || score == 'E';
    }).length;
  }

  /// Tính điểm sức khỏe trung bình
  /// A=9, B=7, C=5, D=3, E=1
  String _getAverageScore(List scans) {
    if (scans.isEmpty) return '0.0';

    double totalScore = 0;
    for (var scan in scans) {
      final score = scan.nutriscore?.toUpperCase() ?? '';
      switch (score) {
        case 'A':
          totalScore += 9;
          break;
        case 'B':
          totalScore += 7;
          break;
        case 'C':
          totalScore += 5;
          break;
        case 'D':
          totalScore += 3;
          break;
        case 'E':
          totalScore += 1;
          break;
        default:
          totalScore += 0;
      }
    }

    final average = totalScore / scans.length;
    return average.toStringAsFixed(1);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2ECC71), size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterTab extends StatelessWidget {
  const _FooterTab({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF2ECC71) : const Color(0xFF9CA3AF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

