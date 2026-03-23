import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_health_product_scanner/core/services/app_logger.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';
import 'package:smart_health_product_scanner/features/product/presentation/providers/health_analysis_provider.dart';
import 'package:smart_health_product_scanner/features/product/presentation/widgets/product_health_analysis_widget.dart';
import 'package:smart_health_product_scanner/features/profile/presentation/providers/profile_provider.dart';
import 'package:smart_health_product_scanner/features/wishlist/presentation/providers/wishlist_provider.dart';

/// Product Detail Page - Tích hợp Health Analysis & Figma Design
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    // Auto-trigger analysis khi page load
    _triggerAnalysis();
  }

  void _triggerAnalysis() {
    Future.microtask(() {
      if (!mounted) {
        AppLogger.warn('[ProductDetailPage] Widget not mounted, skipping analysis');
        return;
      }

      try {
        final profileProvider = context.read<ProfileProvider>();
        final analysisProvider = context.read<HealthAnalysisProvider>();

        AppLogger.debug(
          '[ProductDetailPage] Triggering analysis for: ${widget.product.name}',
        );
        analysisProvider.analyzeProduct(
          widget.product,
          profileProvider.profile,
        );
      } catch (e) {
        AppLogger.error(
          '[ProductDetailPage] Error triggering analysis',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(9999),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Text(
            'Chi tiết sản phẩm',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(9999),
              ),
              child: IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Product Header Section - Image + Name + Brand + Rating
            _buildProductHeader(),

            // 2. HEALTH ANALYSIS SECTION (Tính năng 6 + 7)
            ProductHealthAnalysisWidget(product: widget.product),

            // 3. Additional Info Sections
            _buildProductDetails(),

            // 4. Footer spacing
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Product Header: Hình ảnh + Tên + Thương hiệu + Rating
  Widget _buildProductHeader() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image - Rounded container
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: widget.product.imageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                widget.product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, size: 64),
                  );
                },
              ),
            )
                : Center(
              child: Icon(Icons.shopping_bag,
                  size: 80, color: Colors.grey[300]),
            ),
          ),
          const SizedBox(height: 16),

          // Product Name + Nutriscore Badge (inline)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name ?? 'Sản phẩm không xác định',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getNutricoreColor(widget.product.nutriscore)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  (widget.product.nutriscore ?? 'N/A').toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color:
                    _getNutricoreColor(widget.product.nutriscore),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Brand + Quantity
          Text(
            widget.product.brands != null
                ? '${widget.product.brands} • ${widget.product.quantity ?? 'N/A'}'
                : widget.product.quantity ?? 'N/A',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Ratings
          Row(
            children: [
              SizedBox(
                width: 95,
                child: Row(
                  children: [
                    for (int i = 0; i < 5; i++)
                      Icon(
                        Icons.star,
                        size: 16,
                        color: i < 4
                            ? const Color(0xFFFACC15)
                            : Colors.grey[300],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '4.2',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(1.247 đánh giá)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Additional Product Details Sections
  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barcode if available
          if (widget.product.barcode.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.barcode_reader,
                      size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã vạch',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          widget.product.barcode,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons - Wishlist & Share
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await context
                          .read<WishlistProvider>()
                          .addToWishlist(widget.product);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm vào danh sách yêu thích'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: ${e.toString()}'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Yêu thích'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã copy link sản phẩm'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(Icons.share, color: Colors.grey[700]),
                  label: Text(
                    'Chia sẻ',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getNutricoreColor(String? score) {
    final scoreLower = score?.toLowerCase() ?? '';
    if (scoreLower.contains('a')) return Colors.green;
    if (scoreLower.contains('b')) return Colors.lightGreen;
    if (scoreLower.contains('c')) return Colors.orange;
    if (scoreLower.contains('d')) return Colors.deepOrange;
    if (scoreLower.contains('e')) return Colors.red;
    return Colors.grey;
  }
}
