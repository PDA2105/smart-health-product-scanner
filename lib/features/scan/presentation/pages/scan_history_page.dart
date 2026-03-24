import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_bottom_nav.dart';
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
  static const _pageBg = Color(0xFFF4F4F4);
  static const _primary = Color(0xFF2ECC71);
  static const _softPrimary = Color(0x5CD0E7CF);
  static const _textPrimary = Color(0xFF333333);
  static const _warning = Color(0xFFFF4D4F);
  static const _success = Color(0xFF27AE60);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ScanHistoryProvider>().loadScanHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textPrimary,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.navigateToHome();
            }
          },
        ),
        title: const Text(
          'Lịch sử quét',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 17,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 28,
                ),
                filled: true,
                fillColor: const Color(0xFFEDEDED),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ScanHistoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primary),
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: _warning,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Lỗi: ${provider.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: _warning),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filtered = _filterHistory(provider.scanHistory);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.history
                              : Icons.search_off,
                          size: 64,
                          color: const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Chưa có lịch sử quét'
                              : 'Không tìm thấy sản phẩm phù hợp',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final history = filtered[index];
                    return _HistoryCard(
                      history: history,
                      gradeColor: _getNutriscoreColor(history.nutriscore),
                      gradeLabel: _getNutriscoreLabel(history.nutriscore),
                      formattedDate: _formatDate(history.timestamp),
                      softPrimary: _softPrimary,
                      primary: _primary,
                      textPrimary: _textPrimary,
                      onTap: () => _openProductDetail(history),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(
        current: AppBottomNavItem.history,
      ),
    );
  }

  List<ScanHistoryModel> _filterHistory(List<ScanHistoryModel> allItems) {
    if (_searchQuery.isEmpty) {
      return allItems;
    }

    return allItems.where((item) {
      final name = item.productName.toLowerCase();
      final brands = item.brands?.toLowerCase() ?? '';
      return name.contains(_searchQuery) || brands.contains(_searchQuery);
    }).toList();
  }

  Future<void> _openProductDetail(ScanHistoryModel history) async {
    try {
      final product = await context
          .read<ProductRepository>()
          .getProductByBarcode(history.barcode, forceRefresh: false);

      if (!mounted) return;

      if (product != null) {
        context.navigateToProductDetail(product);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải thông tin sản phẩm'),
            backgroundColor: _warning,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: _warning,
        ),
      );
    }
  }

  String _formatDate(DateTime dateTime) {
    const months = <int, String>{
      1: 'Thg 1',
      2: 'Thg 2',
      3: 'Thg 3',
      4: 'Thg 4',
      5: 'Thg 5',
      6: 'Thg 6',
      7: 'Thg 7',
      8: 'Thg 8',
      9: 'Thg 9',
      10: 'Thg 10',
      11: 'Thg 11',
      12: 'Thg 12',
    };
    final month = months[dateTime.month] ?? '';
    return '${dateTime.day} $month, ${dateTime.year}';
  }

  String _getNutriscoreLabel(String? score) {
    final value = (score ?? 'N/A').toUpperCase();
    return 'GRADE $value';
  }

  Color _getNutriscoreColor(String? score) {
    switch ((score ?? '').toUpperCase()) {
      case 'A':
        return _primary;
      case 'B':
        return _success;
      case 'C':
        return const Color(0xFFF5A623);
      case 'D':
        return const Color(0xFFFF9800);
      case 'E':
        return _warning;
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.history,
    required this.gradeColor,
    required this.gradeLabel,
    required this.formattedDate,
    required this.softPrimary,
    required this.primary,
    required this.textPrimary,
    required this.onTap,
  });

  final ScanHistoryModel history;
  final Color gradeColor;
  final String gradeLabel;
  final String formattedDate;
  final Color softPrimary;
  final Color primary;
  final Color textPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 78,
                  height: 78,
                  color: softPrimary,
                  child:
                      history.productImage != null
                          ? Image.network(
                            history.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.image_not_supported_outlined,
                                  color: primary,
                                ),
                          )
                          : Icon(Icons.local_drink_rounded, color: primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: gradeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  gradeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
