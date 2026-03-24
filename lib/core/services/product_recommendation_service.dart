import 'package:smart_health_product_scanner/data/models/health_profile.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';

/// Service để tìm sản phẩm thay thế phù hợp hơn
/// So sánh điểm Health Score và đề xuất các sản phẩm tốt hơn
class ProductRecommendationService {
  /// Tính health score dựa trên Nutriscore và điều chỉnh theo hồ sơ sức khỏe
  static double calculateHealthScore(
    ProductModel product,
    HealthProfile? profile,
  ) {
    // Base score từ Nutriscore
    double baseScore = _getNutriScoreValue(product.nutriscore);

    // Điều chỉnh theo nutriments
    if (product.nutriments != null) {
      final sugar = product.nutriments?['sugars_100g'] as num? ?? 0;
      final salt = product.nutriments?['salt_100g'] as num? ?? 0;
      final saturatedFat = product.nutriments?['saturated-fat_100g'] as num? ?? 0;

      // Trừ điểm nếu quá nhiều đường, muối, chất béo
      if (sugar > 15) baseScore -= 1.5;
      if (salt > 1) baseScore -= 1.0;
      if (saturatedFat > 10) baseScore -= 1.0;
    }

    // Điều chỉnh theo profile
    if (profile != null) {
      // Nếu người dùng có dị ứng
      if (profile.allergies != null && profile.allergies!.isNotEmpty) {
        bool hasAllergen = false;
        for (var allergen in profile.allergies!) {
          // Check ingredients thay vì allergens
          final ingredients = product.ingredients ?? [];
          for (var ingredient in ingredients) {
            if (ingredient.toLowerCase().contains(allergen.toLowerCase())) {
              hasAllergen = true;
              break;
            }
          }
          if (hasAllergen) break;
        }
        if (hasAllergen) {
          baseScore -= 3.0; // Giảm mạnh nếu có dị ứng
        }
      }

      // Nếu người dùng ăn chay/vegan
      if (profile.dietType == 'vegetarian' || profile.dietType == 'vegan') {
        final ingredients = (product.ingredients ?? []).join(' ').toLowerCase();
        if (ingredients.contains('meat') || ingredients.contains('fish')) {
          baseScore -= 2.0;
        }
      }

      // Nếu người dùng bị tiểu đường
      if (profile.diseases != null && profile.diseases!.contains('Tiểu đường')) {
        final sugar = product.nutriments?['sugars_100g'] as num? ?? 0;
        if (sugar > 10) baseScore -= 2.0;
      }

      // Nếu người dùng cao huyết áp
      if (profile.diseases != null && profile.diseases!.contains('Cao huyết áp')) {
        final salt = product.nutriments?['salt_100g'] as num? ?? 0;
        if (salt > 1.5) baseScore -= 1.5;
      }

      // Nếu người dùng béo/thừa cân (dùng bmi getter)
      final userBmi = profile.bmi;
      if (userBmi != null && userBmi >= 25) {
        final calories = product.nutriments?['energy-kcal_100g'] as num? ?? 0;
        if (calories > 300) baseScore -= 0.5;
      }
    }

    // Giới hạn score từ 0-10
    return baseScore.clamp(0.0, 10.0);
  }

  /// Tìm sản phẩm thay thế từ danh sách các sản phẩm
  /// 
  /// Hàm này lọc các sản phẩm có score cao hơn sản phẩm hiện tại.
  /// Để sử dụng hiệu quả, cần cung cấp danh sách sản phẩm to tìm kiếm:
  /// - Có thể từ local cache
  /// - Hoặc từ API (search by category)
  /// - Hoặc từ database query
  static List<ProductModel> findAlternatives(
    ProductModel currentProduct,
    List<ProductModel> availableProducts,
    HealthProfile? profile,
  ) {
    if (availableProducts.isEmpty) {
      return []; // Không có sản phẩm để tìm
    }

    // Lọc sản phẩm có cùng category
    final alternatives = availableProducts
        .where((p) =>
            p.barcode != currentProduct.barcode && // Không lặp sản phẩm hiện tại
            p.name != currentProduct.name && // Khác tên
            _isSameCategory(p, currentProduct) // Cùng thương hiệu/category
        )
        .toList();

    if (alternatives.isEmpty) {
      return []; // Không tìm thấy sản phẩm tương tự
    }

    // Tính score cho mỗi sản phẩm
    final scored = alternatives.map((product) {
      final score = calculateHealthScore(product, profile);
      return _ProductScore(product, score);
    }).toList();

    // Sắp xếp theo score giảm dần
    scored.sort((a, b) => b.score.compareTo(a.score));

    final currentScore = calculateHealthScore(currentProduct, profile);

    // Trả về 5 sản phẩm tốt hơn (score cao hơn ít nhất 0.5)
    return scored
        .where((ps) => ps.score > currentScore + 0.5) // Phải tốt hơn đáng kể
        .take(5)
        .map((ps) => ps.product)
        .toList();
  }

  /// Check nếu 2 sản phẩm cùng category (hoặc có cùng brand)
  static bool _isSameCategory(ProductModel a, ProductModel b) {
    // Nếu có cùng brand, xem như cùng category
    if (a.brands != null && b.brands != null && a.brands == b.brands) {
      return true;
    }

    // Nếu tên sản phẩm có chung từ đầu (thương hiệu)
    final aNameParts = (a.name ?? '').split(' ');
    final bNameParts = (b.name ?? '').split(' ');
    
    if (aNameParts.isNotEmpty && bNameParts.isNotEmpty) {
      return aNameParts.first.toLowerCase() == bNameParts.first.toLowerCase();
    }

    // Ngoài ra, không coi như cùng category
    return false;
  }

  /// Chuyển Nutriscore (A-E) thành con số (0-10)
  static double _getNutriScoreValue(String? nutriscore) {
    if (nutriscore == null) return 5.0; // Mặc định nếu không có

    switch (nutriscore.toUpperCase()) {
      case 'A':
        return 9.0;
      case 'B':
        return 7.5;
      case 'C':
        return 5.0;
      case 'D':
        return 2.5;
      case 'E':
        return 1.0;
      default:
        return 5.0;
    }
  }

  /// Tạo lời khuyến nghị
  static String generateRecommendation(
    ProductModel currentProduct,
    ProductModel alternativeProduct,
    double scoreDifference,
  ) {
    final productName = alternativeProduct.name ?? 'Sản phẩm khác';
    
    if (scoreDifference > 3.0) {
      return '🌟 Sản phẩm này tốt hơn nhiều! $productName';
    } else if (scoreDifference > 1.5) {
      return '✅ Lựa chọn tốt hơn: $productName';
    } else {
      return '💡 Bạn có thể thử: $productName';
    }
  }
}

class _ProductScore {
  final ProductModel product;
  final double score;

  _ProductScore(this.product, this.score);
}
