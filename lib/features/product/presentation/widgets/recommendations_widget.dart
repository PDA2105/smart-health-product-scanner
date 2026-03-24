import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';
import 'package:smart_health_product_scanner/features/product/presentation/providers/recommendation_provider.dart';
import 'package:smart_health_product_scanner/routes/app_routes.dart';

/// Widget hiển thị danh sách sản phẩm thay thế
class RecommendationsWidget extends StatelessWidget {
  final ProductModel product;

  const RecommendationsWidget({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }

        final result = provider.result;
        if (result == null || result.alternatives.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '✅ Sản phẩm này đã rất tốt! Không có sản phẩm thay thế nào tốt hơn.',
              style: TextStyle(fontSize: 14),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Sản phẩm thay thế',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tìm thấy ${result.alternatives.length} sản phẩm tốt hơn',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.alternatives.length,
              itemBuilder: (context, index) {
                final alternative = result.alternatives[index];
                final altScore = result.alternativeScores[index];
                final scoreDiff = altScore - result.currentScore;

                return _buildAlternativeCard(
                  context,
                  alternative,
                  altScore,
                  scoreDiff,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlternativeCard(
    BuildContext context,
    ProductModel alternative,
    double score,
    double scoreDiff,
  ) {
    final backgroundColor =
        score > 7 ? Colors.green : score > 5 ? Colors.orange : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: alternative,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: alternative.imageUrl != null
                    ? Image.network(
                        alternative.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      )
                    : const Icon(Icons.image),
              ),
              const SizedBox(width: 12),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alternative.name ?? 'Unknown',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alternative.brands ?? 'Unknown Brand',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Score comparison
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: backgroundColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: backgroundColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${score.toStringAsFixed(1)}/10',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: backgroundColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          scoreDiff > 0
                              ? '+${scoreDiff.toStringAsFixed(1)} điểm'
                              : '${scoreDiff.toStringAsFixed(1)} điểm',
                          style: TextStyle(
                            fontSize: 11,
                            color: scoreDiff > 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
