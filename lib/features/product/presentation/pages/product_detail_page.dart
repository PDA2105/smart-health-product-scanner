import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_health_product_scanner/core/widgets/app_bottom_nav.dart';
import 'package:smart_health_product_scanner/core/services/app_logger.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';
import 'package:smart_health_product_scanner/features/product/presentation/providers/health_analysis_provider.dart';
import 'package:smart_health_product_scanner/features/profile/presentation/providers/profile_provider.dart';
import 'package:smart_health_product_scanner/features/wishlist/presentation/providers/wishlist_provider.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product});

  final ProductModel product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const _pageBg = Color(0xFFF4F4F4);
  static const _primary = Color(0xFF2ECC71);
  static const _softPrimary = Color(0x5CD0E7CF);
  static const _textPrimary = Color(0xFF333333);
  static const _warning = Color(0xFFFF4D4F);
  static const _success = Color(0xFF27AE60);

  @override
  void initState() {
    super.initState();
    _triggerAnalysis();
  }

  void _triggerAnalysis() {
    Future.microtask(() {
      if (!mounted) {
        AppLogger.warn(
          '[ProductDetailPage] Widget not mounted, skipping analysis',
        );
        return;
      }

      try {
        final profileProvider = context.read<ProfileProvider>();
        final analysisProvider = context.read<HealthAnalysisProvider>();

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
    return Consumer<HealthAnalysisProvider>(
      builder: (context, analysisProvider, child) {
        final result = analysisProvider.analysisResult;
        final score = _resolveScore(result?.score);
        final ratingLabel = _resolveRatingLabel(score);

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
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Chi tiết sản phẩm',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(),
                const SizedBox(height: 18),
                _buildHeaderMeta(),
                const SizedBox(height: 20),
                _buildHealthScoreCard(score, ratingLabel),
                const SizedBox(height: 22),
                _buildSectionTitle('Thông tin dinh dưỡng'),
                const SizedBox(height: 12),
                _buildNutritionPanel(),
                const SizedBox(height: 22),
                _buildSectionTitle('Thành phần'),
                const SizedBox(height: 12),
                _buildIngredientsPanel(),
                const SizedBox(height: 22),
                _buildSectionTitle('Phụ gia'),
                const SizedBox(height: 12),
                _buildAdditivesPanel(result),
                const SizedBox(height: 22),
                _buildSectionTitle('Chứng chỉ'),
                const SizedBox(height: 12),
                _buildCertificateRow(),
                const SizedBox(height: 28),
                _buildPrimaryButton(),
                const SizedBox(height: 12),
              ],
            ),
          ),
          bottomNavigationBar: const AppBottomNav(
            current: AppBottomNavItem.history,
          ),
        );
      },
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child:
          widget.product.imageUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.network(
                  widget.product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 70,
                        color: _primary,
                      ),
                    );
                  },
                ),
              )
              : const Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 82,
                  color: _primary,
                ),
              ),
    );
  }

  Widget _buildHeaderMeta() {
    final gradeText = (widget.product.nutriscore ?? 'A').toUpperCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name ?? 'Sản phẩm không xác định',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  height: 1.05,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.product.brands ?? 'Chưa rõ thương hiệu'} • ${widget.product.quantity ?? 'N/A'}',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 112,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: _getGradeColor(widget.product.nutriscore),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'GRADE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gradeText,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScoreCard(double score, String ratingLabel) {
    final score100 = (score * 10).clamp(0, 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Điểm sức khỏe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ratingLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score100',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 10),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '/ 100',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Sản phẩm này đáp ứng tiêu chuẩn dinh dưỡng cao',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionPanel() {
    final energy = _formatNumber(
      _nutrimentValue([
        'energy-kcal_100g',
        'energy-kcal_serving',
        'energy-kcal',
        'energy_kcal',
      ]),
    );
    final sugar = _formatNumber(_nutrimentValue(['sugars_100g', 'sugars']));
    final fat = _formatNumber(_nutrimentValue(['fat_100g', 'fat']));
    final protein = _formatNumber(
      _nutrimentValue(['proteins_100g', 'proteins']),
    );
    final carbs = _formatNumber(
      _nutrimentValue(['carbohydrates_100g', 'carbohydrates']),
    );
    final fiber = _formatNumber(_nutrimentValue(['fiber_100g', 'fiber']));
    final sodium = _formatNumber(
      _nutrimentValue(['sodium_100g', 'sodium']) * 1000,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _NutrientTile(
                  icon: Icons.local_fire_department,
                  iconColor: const Color(0xFFF97316),
                  title: 'Calo',
                  value: energy,
                  unit: 'kcal',
                  subtitle: 'Năng lượng',
                  bgColor: const Color(0xFFFDF3E6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutrientTile(
                  icon: Icons.bubble_chart_rounded,
                  iconColor: const Color(0xFFEC4899),
                  title: 'Đường',
                  value: sugar,
                  unit: 'g',
                  subtitle: 'Kiểm soát',
                  bgColor: const Color(0xFFFDECF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _NutrientTile(
                  icon: Icons.opacity_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Chất béo',
                  value: fat,
                  unit: 'g',
                  subtitle: 'Vừa phải',
                  bgColor: const Color(0xFFFFF6E8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutrientTile(
                  icon: Icons.fitness_center_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: 'Protein',
                  value: protein,
                  unit: 'g',
                  subtitle: 'Tốt',
                  bgColor: const Color(0xFFECF4FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MicroValue(label: 'Carbs', value: '$carbs g')),
              Expanded(child: _MicroValue(label: 'Chất xơ', value: '$fiber g')),
              Expanded(child: _MicroValue(label: 'Natri', value: '$sodium mg')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsPanel() {
    final ingredients =
        widget.product.ingredients
            ?.where((value) => value.trim().isNotEmpty)
            .toList() ??
        const <String>[];

    final showing =
        ingredients.isEmpty
            ? const <String>[
              'Thành phần chưa được cập nhật',
              'Vui lòng quét lại sản phẩm để đồng bộ dữ liệu',
            ]
            : ingredients.take(8).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final ingredient in showing)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: _softPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: _success),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _capitalizeFirst(ingredient),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdditivesPanel(dynamic result) {
    final warnings = result?.warnings as List<String>? ?? const <String>[];
    final hasHighRisk = warnings.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _AdditiveRow(
            icon:
                hasHighRisk
                    ? Icons.report_gmailerrorred_rounded
                    : Icons.verified_rounded,
            iconColor: hasHighRisk ? _warning : _success,
            bgColor: hasHighRisk ? const Color(0xFFFFEBEE) : _softPrimary,
            title:
                hasHighRisk
                    ? 'Có phụ gia cần lưu ý'
                    : 'Không chứa chất phụ gia độc hại',
            subtitle:
                hasHighRisk
                    ? warnings.take(2).join(' • ')
                    : 'Sản phẩm này sạch',
          ),
          const SizedBox(height: 10),
          const _AdditiveRow(
            icon: Icons.check_circle_rounded,
            iconColor: _success,
            bgColor: _softPrimary,
            title: 'Tất cả các thành phần tự nhiên',
            subtitle:
                'Sản phẩm này không chứa chất tạo màu, hương liệu hoặc chất bảo quản.',
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateRow() {
    final labels = <String>['Hữu cơ', 'Không chứa gluten', 'Non-GMO'];
    final icons = <IconData>[
      Icons.eco_rounded,
      Icons.no_food_rounded,
      Icons.spa_rounded,
    ];

    return Row(
      children: List.generate(labels.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == labels.length - 1 ? 0 : 10,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 12,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: _softPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icons[index], color: _success, size: 26),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: _onAddToWishlist,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Thêm vào mục yêu thích',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _onAddToWishlist() async {
    try {
      await context.read<WishlistProvider>().addToWishlist(widget.product);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm vào danh sách yêu thích'),
          duration: Duration(seconds: 2),
          backgroundColor: _success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          backgroundColor: _warning,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  double _resolveScore(double? analysisScore) {
    if (analysisScore != null && analysisScore > 0) {
      return analysisScore.clamp(0, 10);
    }

    switch ((widget.product.nutriscore ?? '').toUpperCase()) {
      case 'A':
        return 8.8;
      case 'B':
        return 7.5;
      case 'C':
        return 6.0;
      case 'D':
        return 4.6;
      case 'E':
        return 3.0;
      default:
        return 7.0;
    }
  }

  String _resolveRatingLabel(double score) {
    if (score >= 8) return 'Xuất sắc';
    if (score >= 6.5) return 'Tốt';
    if (score >= 5) return 'Trung bình';
    return 'Cân nhắc';
  }

  double _nutrimentValue(List<String> keys) {
    final nutriments = widget.product.nutriments;
    if (nutriments == null) {
      return 0;
    }

    for (final key in keys) {
      final raw = nutriments[key];
      if (raw is num) {
        return raw.toDouble();
      }
      if (raw is String) {
        final parsed = double.tryParse(raw);
        if (parsed != null) {
          return parsed;
        }
      }
    }
    return 0;
  }

  String _formatNumber(double value) {
    if (value <= 0) return '0';
    if (value >= 100) return value.toStringAsFixed(0);
    if (value >= 10) return value.toStringAsFixed(1);
    return value.toStringAsFixed(1);
  }

  Color _getGradeColor(String? score) {
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

  String _capitalizeFirst(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }
}

class _NutrientTile extends StatelessWidget {
  const _NutrientTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.bgColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final String subtitle;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF2D2F33),
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
              children: [
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MicroValue extends StatelessWidget {
  const _MicroValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AdditiveRow extends StatelessWidget {
  const _AdditiveRow({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
