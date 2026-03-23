import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/product_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/health_analysis_provider.dart';

/// Scan Result Dialog - shows product info after barcode scanning
/// Displays: Name, Health Score, Ingredients
/// Actions: View Details, Find Healthier Alternatives
class ProductScanResultDialog extends StatefulWidget {
  final ProductModel product;

  const ProductScanResultDialog({
    super.key,
    required this.product,
  });

  @override
  State<ProductScanResultDialog> createState() => _ProductScanResultDialogState();
}

class _ProductScanResultDialogState extends State<ProductScanResultDialog> {
  @override
  void initState() {
    super.initState();
    // Trigger health analysis when dialog opens (only once)
    Future.microtask(() {
      if (!mounted) {
        debugPrint('⚠️ [ProductScanResultDialog] Widget not mounted, skipping analysis');
        return;
      }

      try {
        debugPrint('🔄 [ProductScanResultDialog] Triggering analysis for: ${widget.product.name}');
        // Lấy profile người dùng để phân tích chính xác hơn
        final profile = context.read<ProfileProvider>().profile;

        // Gọi đúng tên hàm analyzeProduct từ HealthAnalysisProvider
        context.read<HealthAnalysisProvider>().analyzeProduct(
          widget.product,
          profile,
        );
      } catch (e) {
        debugPrint('❌ [ProductScanResultDialog] Error triggering health analysis: $e');
        debugPrintStack(label: 'Stack trace:', maxFrames: 10);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Product image header
            if (widget.product.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  widget.product.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 140,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 140,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),

            // Content area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    widget.product.name ?? 'Sản phẩm không có tên',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  if (widget.product.brands != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.product.brands!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Health score section
                  _buildHealthScoreSection(),

                  const SizedBox(height: 12),

                  // Nutriscore & Ecoscore badges
                  if (widget.product.nutriscore != null || widget.product.ecoscore != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.product.nutriscore != null)
                          _buildScoreBadge(
                            'Nutriscore',
                            widget.product.nutriscore!,
                            Colors.orange,
                          ),
                        if (widget.product.nutriscore != null && widget.product.ecoscore != null)
                          const SizedBox(width: 12),
                        if (widget.product.ecoscore != null)
                          _buildScoreBadge(
                            'Ecoscore',
                            widget.product.ecoscore!,
                            Colors.green,
                          ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Ingredients/Components
                  _buildIngredientsSection(),

                  const SizedBox(height: 16),

                  // Action buttons
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build health score section with AI analysis
  Widget _buildHealthScoreSection() {
    return Consumer<HealthAnalysisProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: SizedBox(
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(strokeWidth: 2),
                  const SizedBox(height: 8),
                  Text(
                    'Phân tích sức khỏe...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        final result = provider.analysisResult;
        if (result == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.error ?? 'Không thể tải phân tích',
                    style: TextStyle(color: Colors.orange[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }

        final scoreColor = _getScoreColor(result.score.toInt());

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scoreColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scoreColor.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            children: [
              // Score circle
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill( // 👈 cách tốt nhất trong Stack
                      child: CircularProgressIndicator(
                        value: result.score / 10,
                        strokeWidth: 7,
                        valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${result.score}',
                          style: TextStyle(
                            fontSize: 30, // 👈 nên tăng lại cho cân
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                        Text(
                          '/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Rating and analysis
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scoreColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        result.rating,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.aiAnalysis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build ingredients/components section
  Widget _buildIngredientsSection() {
    final ingredientsString = widget.product.ingredients != null && widget.product.ingredients!.isNotEmpty
        ? widget.product.ingredients!.join(', ')
        : 'Không có thông tin thành phần';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.kitchen, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'Thành phần',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            ingredientsString,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // View details button
        ElevatedButton.icon(
          onPressed: () {
            try {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(
                AppRoutes.productDetail,
                arguments: widget.product,
              );
            } catch (e) {
              debugPrint('❌ [ProductScanResultDialog] Navigation error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi: $e')),
              );
            }
          },
          icon: const Icon(Icons.info_outline, size: 18),
          label: const Text('Xem chi tiết'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Find healthier alternatives button
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            _showHealthierAlternatives(context);
          },
          icon: const Icon(Icons.health_and_safety, size: 18),
          label: const Text('Tìm giải pháp thay thế'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.teal,
            side: const BorderSide(color: Colors.teal),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  /// Build score badge
  static Widget _buildScoreBadge(String label, String score, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            score.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Get color based on health score
  Color _getScoreColor(int score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.teal;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  /// Show healthier alternatives (placeholder)
  void _showHealthierAlternatives(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Giải pháp thay thế lành mạnh',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline, size: 48, color: Colors.amber),
                  const SizedBox(height: 12),
                  Text(
                    'Tính năng đang phát triển',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
