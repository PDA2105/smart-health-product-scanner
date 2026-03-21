import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_health_product_scanner/core/services/gemini_health_analysis_service.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';
import 'package:smart_health_product_scanner/features/profile/presentation/providers/profile_provider.dart';
import 'package:smart_health_product_scanner/features/product/presentation/providers/health_analysis_provider.dart';

/// Widget hiển thị kết quả phân tích sức khỏe sản phẩm
class ProductHealthAnalysisWidget extends StatefulWidget {
  const ProductHealthAnalysisWidget({
    Key? key,
    required this.product,
  }) : super(key: key);

  final ProductModel product;

  @override
  State<ProductHealthAnalysisWidget> createState() =>
      _ProductHealthAnalysisWidgetState();
}

class _ProductHealthAnalysisWidgetState
    extends State<ProductHealthAnalysisWidget> {
  @override
  void initState() {
    super.initState();
    // Phân tích sản phẩm khi widget được tạo
    Future.microtask(() {
      final profileProvider = context.read<ProfileProvider>();
      final analysisProvider = context.read<HealthAnalysisProvider>();

      analysisProvider.analyzeProduct(
        widget.product,
        profileProvider.profile,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthAnalysisProvider>(
      builder: (context, analysisProvider, _) {
        if (analysisProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (analysisProvider.error != null) {
          return Center(child: Text(analysisProvider.error!));
        }

        final result = analysisProvider.analysisResult;
        if (result == null) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Score Card
                _buildHealthScoreCard(result),
                const SizedBox(height: 16),

                // AI Analysis Section
                _buildAIAnalysisSection(result.aiAnalysis),
                const SizedBox(height: 16),

                // Allergy Warnings
                if (result.allergieWarnings.isNotEmpty)
                  _buildWarningSection(
                    '⚠️ Cảnh báo dị ứng',
                    result.allergieWarnings,
                    Colors.red,
                  ),
                if (result.allergieWarnings.isNotEmpty)
                  const SizedBox(height: 16),

                // Diet Warnings
                if (result.dietWarnings.isNotEmpty)
                  _buildWarningSection(
                    '🍽️ Khác với chế độ ăn',
                    result.dietWarnings,
                    Colors.orange,
                  ),
                if (result.dietWarnings.isNotEmpty)
                  const SizedBox(height: 16),

                // General Warnings
                if (result.warnings.isNotEmpty)
                  _buildWarningSection(
                    '⚠️ Cảnh báo chung',
                    result.warnings,
                    Colors.amber,
                  ),
                if (result.warnings.isNotEmpty)
                  const SizedBox(height: 16),

                // Benefits
                if (result.benefits.isNotEmpty)
                  _buildBenefitSection(result.benefits),
                if (result.benefits.isNotEmpty)
                  const SizedBox(height: 16),

                // Nutrition Details
                _buildNutritionDetailsSection(result.nutritionAnalysis),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Xây dựng Health Score Card
  Widget _buildHealthScoreCard(HealthScoreResult result) {
    final backgroundColor = _getScoreColor(result.score);

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundColor, backgroundColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Điểm sức khỏe',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: result.score / 10,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.score.toStringAsFixed(1)}/10',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      result.rating,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreDescription(result.score),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng Warning Section
  Widget _buildWarningSection(
    String title,
    List<String> warnings,
    Color color,
  ) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            ...warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  warning,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng Benefit Section
  Widget _buildBenefitSection(List<String> benefits) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: const BorderSide(color: Colors.green, width: 4),
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.green.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ Lợi ích',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ...benefits.map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  benefit,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xây dựng Nutrition Details Section
  Widget _buildNutritionDetailsSection(Map<String, dynamic> nutrition) {
    return Card(
      child: ExpansionTile(
        title: const Text(
          '📊 Chi tiết dinh dưỡng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildNutritionRow(
                  'Năng lượng',
                  '${nutrition['energy']} kcal',
                  Icons.local_fire_department,
                ),
                _buildNutritionRow(
                  'Protein',
                  '${nutrition['protein']}g',
                  Icons.fitness_center,
                ),
                _buildNutritionRow(
                  'Carbs',
                  '${nutrition['carbohydrates']}g',
                  Icons.cake,
                ),
                _buildNutritionRow(
                  'Chất béo',
                  '${nutrition['fat']}g',
                  Icons.opacity,
                ),
                _buildNutritionRow(
                  'Đường',
                  '${nutrition['sugars']}g',
                  Icons.water_drop,
                ),
                _buildNutritionRow(
                  'Muối',
                  '${nutrition['sodium']} mg',
                  Icons.blur_on,
                ),
                _buildNutritionRow(
                  'Chất xơ',
                  '${nutrition['fiber']}g',
                  Icons.grass,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đánh giá:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildScoreTag(
                            'Nutriscore',
                            '${nutrition['nutriscore']}',
                          ),
                          _buildScoreTag(
                            'Ecoscore',
                            '${nutrition['ecoscore']}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng Nutrition Row
  Widget _buildNutritionRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              Text(label),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Xây dựng Score Tag
  Widget _buildScoreTag(String label, String value) {
    final scoreColor = _getScoreTagColor(value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.2),
        border: Border.all(color: scoreColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Lấy màu dựa trên điểm số
  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.blue;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  /// Lấy mô tả điểm số
  String _getScoreDescription(double score) {
    if (score >= 8) {
      return 'Sản phẩm rất tốt cho sức khỏe';
    } else if (score >= 6) {
      return 'Sản phẩm còn được, nhưng có thể chọn tốt hơn';
    } else if (score >= 4) {
      return 'Sản phẩm trung bình, nên sử dụng vừa phải';
    } else {
      return 'Sản phẩm không tốt cho sức khỏe, hãy chọn lựa chọn thay thế';
    }
  }

  /// Lấy màu cho score tag
  Color _getScoreTagColor(String score) {
    final scoreLower = score.toLowerCase();
    if (scoreLower.contains('a')) return Colors.green;
    if (scoreLower.contains('b')) return Colors.lightGreen;
    if (scoreLower.contains('c')) return Colors.orange;
    if (scoreLower.contains('d')) return Colors.deepOrange;
    if (scoreLower.contains('e')) return Colors.red;
    return Colors.grey;
  }

  /// Xây dựng AI Analysis Section (Phân tích chi tiết từ Gemini)
  Widget _buildAIAnalysisSection(String aiAnalysis) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300, width: 2),
          color: Colors.blue.withOpacity(0.05),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '🤖 Phân tích AI (Gemini)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              aiAnalysis,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
