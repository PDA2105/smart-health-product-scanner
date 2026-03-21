import 'package:smart_health_product_scanner/data/models/health_profile.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';

/// Health score result with detailed analysis
class HealthScoreResult {
  HealthScoreResult({
    required this.score, // 0-10
    required this.rating, // 'Excellent', 'Good', 'Fair', 'Poor'
    required this.warnings,
    required this.benefits,
    required this.allergieWarnings,
    required this.dietWarnings,
    required this.nutritionAnalysis,
  });

  final double score;
  final String rating;
  final List<String> warnings;
  final List<String> benefits;
  final List<String> allergieWarnings; // Từ dị ứng hồ sơ
  final List<String> dietWarnings; // Từ chế độ ăn
  final Map<String, dynamic> nutritionAnalysis;

  bool get isHighScore => score >= 7;
  bool get isMediumScore => score >= 5 && score < 7;
  bool get isLowScore => score < 5;
  bool get hasAllergyWarning => allergieWarnings.isNotEmpty;
  bool get hasDietWarning => dietWarnings.isNotEmpty;
}

/// Health Analysis Service - Phân tích sức khỏe dựa trên AI logic
class HealthAnalysisService {
  /// Phân tích sản phẩm dựa trên hồ sơ sức khỏe
  HealthScoreResult analyzeProduct(
    ProductModel product,
    HealthProfile? healthProfile,
  ) {
    final warnings = <String>[];
    final benefits = <String>[];
    final allergieWarnings = <String>[];
    final dietWarnings = <String>[];

    // 1. Kiểm tra dị ứng
    if (healthProfile?.allergies != null && product.ingredients != null) {
      allergieWarnings.addAll(
        _checkAllergies(product.ingredients!, healthProfile!.allergies!),
      );
    }

    // 2. Kiểm tra chế độ ăn
    if (healthProfile?.dietType != null && product.ingredients != null) {
      dietWarnings.addAll(
        _checkDietRestrictions(
          product.ingredients!,
          healthProfile!.dietType!,
        ),
      );
    }

    // 3. Phân tích dinh dưỡng
    final nutritionAnalysis =
        _analyzeNutrition(product, healthProfile);
    
    // 4. Tính điểm sức khỏe
    double score = _calculateHealthScore(
      product,
      healthProfile,
      allergieWarnings.isEmpty,
      dietWarnings.isEmpty,
    );

    // 5. Thêm cảnh báo và lợi ích
    warnings.addAll(_generateWarnings(product, healthProfile));
    benefits.addAll(_generateBenefits(product, healthProfile));

    // 6. Xác định rating
    String rating = _getRating(score);

    return HealthScoreResult(
      score: score,
      rating: rating,
      warnings: warnings,
      benefits: benefits,
      allergieWarnings: allergieWarnings,
      dietWarnings: dietWarnings,
      nutritionAnalysis: nutritionAnalysis,
    );
  }

  /// Kiểm tra dị ứng từ danh sách thành phần
  List<String> _checkAllergies(
    List<String> ingredients,
    List<String> allergies,
  ) {
    final commonAllergens = {
      'peanuts': ['lạc', 'đậu phộng', 'peanut'],
      'tree nuts': ['hạt', 'óc chó', 'crushed nuts'],
      'milk': ['sữa', 'lactose', 'whey', 'casein', 'butter'],
      'eggs': ['trứng', 'egg', 'lòng trắng'],
      'fish': ['cá', 'fish', 'anchovy'],
      'shellfish': ['tôm', 'cua', 'sò', 'shellfish'],
      'soy': ['đậu nành', 'soy', 'edamame'],
      'wheat': ['lúa mì', 'wheat', 'gluten'],
      'sesame': ['vừng', 'sesame'],
      'sulphites': ['sunfite', 'preservative'],
    };

    final warnings = <String>[];
    final ingredientText = ingredients.join(' ').toLowerCase();

    for (final allergyItem in allergies) {
      final allergyLower = allergyItem.toLowerCase();

      // Kiểm tra trực tiếp
      if (ingredientText.contains(allergyLower)) {
        warnings.add('⚠️ Chứa $allergyItem (dị ứng của bạn)');
      }

      // Kiểm tra qua danh sách gợi ý
      if (commonAllergens.containsKey(allergyLower)) {
        for (final variant in commonAllergens[allergyLower]!) {
          if (ingredientText.contains(variant)) {
            warnings.add('⚠️ Có thể chứa $allergyItem');
            break;
          }
        }
      }
    }

    return warnings;
  }

  /// Kiểm tra hạn chế chế độ ăn
  List<String> _checkDietRestrictions(
    List<String> ingredients,
    String dietType,
  ) {
    final warnings = <String>[];
    final ingredientText = ingredients.join(' ').toLowerCase();

    switch (dietType.toLowerCase()) {
      case 'vegetarian':
        if (_containsAny(ingredientText, [
          'meat',
          'chicken',
          'beef',
          'pork',
          'fish',
          'thịt',
          'gà',
          'bò',
          'lợn',
          'cá'
        ])) {
          warnings.add('❌ Chứa thịt - không phù hợp với chế độ ăn chay');
        }
        break;

      case 'vegan':
        if (_containsAny(ingredientText, [
          'meat',
          'chicken',
          'beef',
          'pork',
          'fish',
          'milk',
          'eggs',
          'honey',
          'thịt',
          'gà',
          'bò',
          'lợn',
          'cá',
          'sữa',
          'trứng',
          'mật ong'
        ])) {
          warnings.add('❌ Không phù hợp với chế độ ăn thuần chay');
        }
        break;

      case 'keto':
        if (_containsAny(ingredientText, [
          'sugar',
          'glucose',
          'fructose',
          'starch',
          'đường',
          'tinh bột'
        ])) {
          warnings.add('⚠️ Chứa carbohydrate cao - không phù hợp keto');
        }
        break;

      case 'gluten-free':
        if (_containsAny(ingredientText, [
          'wheat',
          'barley',
          'rye',
          'gluten',
          'lúa mì',
          'lúa mạch',
          'lúa đen'
        ])) {
          warnings.add('❌ Chứa gluten - không phù hợp chế độ không gluten');
        }
        break;
    }

    return warnings;
  }

  /// Phân tích chi tiết dinh dưỡng
  Map<String, dynamic> _analyzeNutrition(
    ProductModel product,
    HealthProfile? healthProfile,
  ) {
    final nutriments = product.nutriments ?? {};

    final energy = nutriments['energy-kcal'] ?? nutriments['energy'] ?? 0;
    final protein = nutriments['proteins'] ?? 0;
    final fat = nutriments['fat'] ?? 0;
    final carbs = nutriments['carbohydrates'] ?? 0;
    final sugar = nutriments['sugars'] ?? 0;
    final sodium = nutriments['sodium'] ?? 0;
    final fiber = nutriments['fiber'] ?? 0;

    return {
      'energy': energy,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbs,
      'sugars': sugar,
      'sodium': sodium,
      'fiber': fiber,
      'nutriscore': product.nutriscore ?? 'unknown',
      'ecoscore': product.ecoscore ?? 'unknown',
    };
  }

  /// Tính toán hệ số score sức khỏe (0-10)
  double _calculateHealthScore(
    ProductModel product,
    HealthProfile? healthProfile,
    bool noAllergies,
    bool noDietRestriction,
  ) {
    double score = 5.0; // Điểm mặc định

    // 1. Dựa trên Nutriscore (A=10, B=8, C=6, D=4, E=2)
    if (product.nutriscore != null) {
      final nutriscoreMap = {'a': 10.0, 'b': 8.0, 'c': 6.0, 'd': 4.0, 'e': 2.0};
      score = nutriscoreMap[product.nutriscore!.toLowerCase()] ?? 5.0;
    }

    // 2. Điều chỉnh dựa trên BMI của người dùng
    if (healthProfile?.bmi != null) {
      final bmi = healthProfile!.bmi!;
      if (bmi > 30 || bmi < 18.5) {
        // Người dùng béo phì hoặc gầy
        // Ưu tiên sản phẩm ít năng lượng và đầy dinh dưỡng
        final nutrients = product.nutriments ?? {};
        final kcal = (nutrients['energy-kcal'] as num?)?.toDouble() ?? 0;

        if (kcal < 100) score += 1.5;
        if (kcal > 500) score -= 1.5;
      }
    }

    // 3. Động1 dị ứng và chế độ ăn
    if (!noAllergies || !noDietRestriction) {
      score -= 2.0;
    }

    // 4. Động từ bệnh lý nếu có
    if (healthProfile?.diseases != null && healthProfile!.diseases!.isNotEmpty) {
      score = _adjustScoreForDiseases(score, product, healthProfile.diseases!);
    }

    // Đảm bảo score nằm trong khoảng 0-10
    return score.clamp(0.0, 10.0);
  }

  /// Điều chỉnh score dựa trên bệnh lý
  double _adjustScoreForDiseases(
    double score,
    ProductModel product,
    List<String> diseases,
  ) {
    double adjusted = score;
    final nutrients = product.nutriments ?? {};
    final sodium = (nutrients['sodium'] as num?)?.toDouble() ?? 0;
    final sugar = (nutrients['sugars'] as num?)?.toDouble() ?? 0;

    for (final disease in diseases) {
      switch (disease.toLowerCase()) {
        case 'hypertension':
        case 'huyết áp cao':
          if (sodium > 400) adjusted -= 2.0;
          break;
        case 'diabetes':
        case 'tiểu đường':
          if (sugar > 15) adjusted -= 2.5;
          break;
        case 'high cholesterol':
        case 'cholesterol cao':
          final fat = (nutrients['fat'] as num?)?.toDouble() ?? 0;
          if (fat > 10) adjusted -= 2.0;
          break;
      }
    }

    return adjusted;
  }

  /// Tính toán xếp hạng từ điểm
  String _getRating(double score) {
    if (score >= 8) return 'Xuất sắc';
    if (score >= 6) return 'Tốt';
    if (score >= 4) return 'Trung bình';
    return 'Kém';
  }

  /// Tạo danh sách cảnh báo
  List<String> _generateWarnings(
    ProductModel product,
    HealthProfile? healthProfile,
  ) {
    final warnings = <String>[];
    final nutrients = product.nutriments ?? {};

    // Cảnh báo chung
    if (product.nutriscore == 'd' || product.nutriscore == 'e') {
      warnings.add('⚠️ Sản phẩm có chất lượng dinh dưỡng dưới trung bình');
    }

    final sugar = (nutrients['sugars'] as num?)?.toDouble() ?? 0;
    if (sugar > 25) {
      warnings.add('🍬 Chứa đường cao (${sugar.toStringAsFixed(1)}g)');
    }

    final sodium = (nutrients['sodium'] as num?)?.toDouble() ?? 0;
    if (sodium > 600) {
      warnings.add('🧂 Chứa muối cao (${sodium.toStringAsFixed(1)}mg)');
    }

    final fat = (nutrients['fat'] as num?)?.toDouble() ?? 0;
    if (fat > 15) {
      warnings.add('🍖 Chứa chất béo cao (${fat.toStringAsFixed(1)}g)');
    }

    return warnings;
  }

  /// Tạo danh sách lợi ích
  List<String> _generateBenefits(
    ProductModel product,
    HealthProfile? healthProfile,
  ) {
    final benefits = <String>[];
    final nutrients = product.nutriments ?? {};

    if (product.nutriscore == 'a') {
      benefits.add('✅ Sản phẩm dinh dưỡng tốt nhất (Nutriscore A)');
    }

    final protein = (nutrients['proteins'] as num?)?.toDouble() ?? 0;
    if (protein > 10) {
      benefits.add('💪 Giàu protein (${protein.toStringAsFixed(1)}g)');
    }

    final fiber = (nutrients['fiber'] as num?)?.toDouble() ?? 0;
    if (fiber > 5) {
      benefits.add('🥬 Giàu chất xơ (${fiber.toStringAsFixed(1)}g)');
    }

    if (product.ecoscore == 'a' || product.ecoscore == 'b') {
      benefits.add('🌍 Thân thiện với môi trường');
    }

    return benefits;
  }

  /// Helper: Kiểm tra xem chuỗi chứa một trong những từ
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }
}
