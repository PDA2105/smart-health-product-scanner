import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/models/wishlist_item_model.dart';
import '../../../../routes/app_routes.dart';
import '../providers/wishlist_provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    // Load wishlist when page opens
    Future.microtask(() {
      context.read<WishlistProvider>().loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
        backgroundColor: const Color(0xFF2ECC71),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, provider, child) {
              if (provider.wishlist.isEmpty) return const SizedBox();
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
          Consumer<WishlistProvider>(
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
                      label: 'Tổng sản phẩm',
                      value: '${provider.wishlist.length}',
                    ),
                    _StatCard(
                      label: 'Tháng này',
                      value: '${_getThisMonthCount(provider.wishlist)}',
                    ),
                    _StatCard(
                      label: 'Hôm nay',
                      value: '${_getTodayCount(provider.wishlist)}',
                    ),
                  ],
                ),
              );
            },
          ),
          // List of wishlist items
          Expanded(
            child: Consumer<WishlistProvider>(
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

                if (provider.wishlist.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có sản phẩm yêu thích',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thêm sản phẩm vào wishlist để xem lại sau',
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
                  itemCount: provider.wishlist.length,
                  itemBuilder: (context, index) {
                    final item = provider.wishlist[index];
                    final addedDate = _formatDate(item.addedAt);

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
                            child: item.productImage != null
                                ? Image.network(
                                    item.productImage!,
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
                          item.productName,
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
                            if (item.brands != null)
                              Text(
                                item.brands!,
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
                                  Icons.calendar_today,
                                  size: 12,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  addedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                if (item.nutriscore != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getNutriscoreColor(item.nutriscore!),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Nutriscore ${item.nutriscore!}',
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
                            if (item.note != null && item.note!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blue[200]!,
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  item.note!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          // Navigate to product details
                          final product = ProductModel(
                            barcode: item.barcode,
                            name: item.productName,
                            imageUrl: item.productImage,
                            brands: item.brands,
                            nutriscore: item.nutriscore,
                          );
                          context.navigateToProductDetail(product);
                        },
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              provider.removeFromWishlist(item.id);
                            } else if (value == 'edit') {
                              _showNoteDialog(context, item.id, item.note);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 16),
                                  SizedBox(width: 8),
                                  Text('Chỉnh sửa ghi chú'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
              active: true,
              onTap: () {},
            ),
            _FooterTab(
              icon: Icons.history,
              label: 'History',
              onTap: () => context.navigateToScanHistory(),
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

  /// Shows confirm dialog to clear all wishlist
  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa wishlist?'),
        content: const Text('Bạn có chắc muốn xóa tất cả sản phẩm yêu thích?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              context.read<WishlistProvider>().clearWishlist();
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

  /// Shows dialog to edit note
  void _showNoteDialog(BuildContext context, String itemId, String? currentNote) {
    final noteController = TextEditingController(text: currentNote ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa ghi chú'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Nhập ghi chú...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                context
                    .read<WishlistProvider>()
                    .updateWishlistNote(itemId, noteController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// Formats date to readable string
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Gets count of items added this month
  int _getThisMonthCount(List<WishlistItemModel> items) {
    final now = DateTime.now();
    return items.where((item) {
      return item.addedAt.year == now.year && item.addedAt.month == now.month;
    }).length;
  }

  /// Gets count of items added today
  int _getTodayCount(List<WishlistItemModel> items) {
    final today = DateTime.now();
    return items.where((item) {
      final itemDate = item.addedAt;
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
