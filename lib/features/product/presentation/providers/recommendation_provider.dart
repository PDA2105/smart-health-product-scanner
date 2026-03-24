import 'package:flutter/foundation.dart';
import 'package:smart_health_product_scanner/core/services/product_recommendation_service.dart';
import 'package:smart_health_product_scanner/data/models/health_profile.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';
import 'package:smart_health_product_scanner/data/repositories/product_repository.dart';

/// Model để lưu kết quả recommendation
class RecommendationResult {
  final ProductModel currentProduct;
  final List<ProductModel> alternatives;
  final double currentScore;
  final List<double> alternativeScores;

  RecommendationResult({
    required this.currentProduct,
    required this.alternatives,
    required this.currentScore,
    required this.alternativeScores,
  });
}

/// Provider để quản lý recommendations
class RecommendationProvider extends ChangeNotifier {
  RecommendationProvider({
    required ProductRepository productRepository,
  }) : _productRepository = productRepository;

  final ProductRepository _productRepository;

  RecommendationResult? _result;
  bool _isLoading = false;
  String? _error;

  RecommendationResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Lấy gợi ý sản phẩm thay thế
  Future<void> getRecommendations(
    ProductModel product,
    HealthProfile? profile,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 [RecommendationProvider] Tìm kiếm sản phẩm thay thế cho: ${product.name}');

      // Tính score hiện tại
      final currentScore = ProductRecommendationService.calculateHealthScore(product, profile);

      // Tìm các sản phẩm tương tự
      final similarProducts = await _findSimilarProducts(product, profile);

      // Nếu không tìm thấy sản phẩm tương tự, không có gợi ý
      if (similarProducts.isEmpty) {
        _result = RecommendationResult(
          currentProduct: product,
          alternatives: [],
          currentScore: currentScore,
          alternativeScores: [],
        );
        print('ℹ️ [RecommendationProvider] Không tìm thấy sản phẩm tương tự');
      } else {
        // Sử dụng ProductRecommendationService để tìm các sản phẩm tốt hơn
        final alternatives = ProductRecommendationService.findAlternatives(
          product,
          similarProducts,
          profile,
        );

        // Tính score cho mỗi sản phẩm thay thế
        final scores = alternatives
            .map((p) => ProductRecommendationService.calculateHealthScore(p, profile))
            .toList();

        _result = RecommendationResult(
          currentProduct: product,
          alternatives: alternatives,
          currentScore: currentScore,
          alternativeScores: scores,
        );

        print('✅ [RecommendationProvider] Tìm thấy ${alternatives.length} sản phẩm thay thế');
      }
    } catch (e) {
      _error = 'Lỗi khi tìm sản phẩm thay thế: $e';
      print('❌ [RecommendationProvider] Error: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tìm các sản phẩm tương tự
  /// 
  /// Sử dụng ProductRepository để:
  /// 1. Tìm sản phẩm cùng thương hiệu (brands)
  /// 2. Nếu không đủ, tìm cùng danh mục (categories)
  Future<List<ProductModel>> _findSimilarProducts(
    ProductModel product,
    HealthProfile? profile,
  ) async {
    try {
      print('🔍 [RecommendationProvider] Tìm sản phẩm tương tự từ repository');
      
      // Sử dụng method mới trong ProductRepository
      final similarProducts = await _productRepository.getSimilarProducts(
        product,
        limit: 15,
      );

      print('✅ [RecommendationProvider] Tìm thấy ${similarProducts.length} sản phẩm tương tự');
      return similarProducts;
    } catch (e) {
      print('❌ [RecommendationProvider] Error finding similar products: $e');
      return [];
    }
  }

  /// Clear recommendations
  void clear() {
    _result = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
