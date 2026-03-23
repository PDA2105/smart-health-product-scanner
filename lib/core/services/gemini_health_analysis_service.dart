import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:smart_health_product_scanner/core/config/gemini_config.dart';
import 'package:smart_health_product_scanner/core/services/app_logger.dart';
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
    required this.aiAnalysis, // Phân tích chi tiết từ Gemini
  });

  final double score;
  final String rating;
  final List<String> warnings;
  final List<String> benefits;
  final List<String> allergieWarnings;
  final List<String> dietWarnings;
  final Map<String, dynamic> nutritionAnalysis;
  final String aiAnalysis; // AI detailed analysis

  bool get isHighScore => score >= 7;
  bool get isMediumScore => score >= 5 && score < 7;
  bool get isLowScore => score < 5;
  bool get hasAllergyWarning => allergieWarnings.isNotEmpty;
  bool get hasDietWarning => dietWarnings.isNotEmpty;
}

/// Gemini AI Health Analysis Service
class GeminiHealthAnalysisService {
  GeminiHealthAnalysisService({required String apiKey}) {
    _model = GenerativeModel(
      model: GeminiConfig.modelName,
      apiKey: apiKey,
    );
  }

  late final GenerativeModel _model;

  /// Analyze product with Gemini AI
  Future<HealthScoreResult> analyzeProduct(
    ProductModel product,
    HealthProfile? healthProfile,
  ) async {
    try {
      AppLogger.debug('[GeminiService] Starting analysis for: ${product.name}');
      AppLogger.debug('[GeminiService] Using model: ${GeminiConfig.modelName}');
      
      // 1. Prepare prompt for Gemini
      final prompt = _buildAnalysisPrompt(product, healthProfile);
      AppLogger.debug(
        '[GeminiService] Prompt prepared (length: ${prompt.length} chars)',
      );
      AppLogger.debug(
        '[GeminiService] First 200 chars: ${prompt.substring(0, (prompt.length > 200 ? 200 : prompt.length))}...',
      );

      // 2. Call Gemini API
      AppLogger.debug('[GeminiService] Calling Gemini API...');
      final stopwatch = Stopwatch()..start();
      final response = await _model.generateContent(
        [Content.text(prompt)],
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          AppLogger.warn('[GeminiService] Gemini API timeout after 30 seconds');
          throw TimeoutException('Gemini API call timeout', const Duration(seconds: 30));
        },
      );
      stopwatch.stop();
      AppLogger.debug(
        '[GeminiService] Gemini API response received in ${stopwatch.elapsedMilliseconds}ms',
      );

      // 3. Parse AI response
      final aiContent = response.text ?? '';
      AppLogger.debug('[GeminiService] Response length: ${aiContent.length} chars');
      if (aiContent.isNotEmpty) {
        AppLogger.debug(
          '[GeminiService] Response (first 300 chars): ${aiContent.substring(0, (aiContent.length > 300 ? 300 : aiContent.length))}...',
        );
      } else {
        AppLogger.warn('[GeminiService] Response is empty');
      }

      // 4. Extract structured data from AI response
      AppLogger.debug('[GeminiService] Parsing AI response...');
      final analysisData = _parseAIResponse(aiContent, product, healthProfile);
      AppLogger.debug(
        '[GeminiService] Analysis complete. Score: ${analysisData.score}, Rating: ${analysisData.rating}',
      );

      return analysisData;
    } on TimeoutException catch (e) {
      AppLogger.error('[GeminiService] Timeout error', error: e);
      AppLogger.warn('[GeminiService] Using fallback analysis due to timeout');
      return _getFallbackAnalysis(product, healthProfile);
    } catch (e) {
      AppLogger.error(
        '[GeminiService] Gemini API error. Type: ${e.runtimeType}',
        error: e,
        stackTrace: StackTrace.current,
      );
      AppLogger.warn('[GeminiService] Using fallback analysis');
      // Fallback to basic analysis if API fails
      return _getFallbackAnalysis(product, healthProfile);
    }
  }

  /// Build detailed prompt for Gemini
  String _buildAnalysisPrompt(
    ProductModel product,
    HealthProfile? healthProfile,
  ) {
    String prompt = '''
Bạn là một chuyên gia dinh dưỡng và sức khỏe AI. Hãy phân tích sản phẩm sau:

**THÔNG TIN SẢN PHẨM:**
- Tên: ${product.name ?? 'Unknown'}
- Thương hiệu: ${product.brands ?? 'Unknown'}
- Mã vạch: ${product.barcode}
- Nutriscore: ${product.nutriscore ?? 'N/A'}
- Ecoscore: ${product.ecoscore ?? 'N/A'}
- Thành phần: ${product.ingredients?.join(', ') ?? 'N/A'}
- Dinh dưỡng (100g):
  - Năng lượng: ${product.nutriments?['energy'] ?? 'N/A'} kcal
  - Protein: ${product.nutriments?['proteins'] ?? 'N/A'}g
  - Chất béo: ${product.nutriments?['fat'] ?? 'N/A'}g
  - Carbs: ${product.nutriments?['carbohydrates'] ?? 'N/A'}g
  - Đường: ${product.nutriments?['sugars'] ?? 'N/A'}g
  - Muối (Na): ${product.nutriments?['sodium'] ?? 'N/A'}mg
  - Chất xơ: ${product.nutriments?['fiber'] ?? 'N/A'}g
''';

    if (healthProfile != null) {
      prompt += '''

**THÔNG TIN SỨC KHỎE NGƯỜI DÙNG:**
- Tuổi: ${healthProfile.age ?? 'N/A'}
- Giới tính: ${healthProfile.gender ?? 'N/A'}
- Cân nặng: ${healthProfile.weight ?? 'N/A'} kg
- Chiều cao: ${healthProfile.height ?? 'N/A'} cm
- BMI: ${healthProfile.bmi?.toStringAsFixed(1) ?? 'N/A'} (${healthProfile.computedBmiCategory ?? 'N/A'})
- Dị ứng: ${healthProfile.allergies?.join(', ') ?? 'Không'}
- Bệnh lý: ${healthProfile.diseases?.join(', ') ?? 'Không'}
- Chế độ ăn: ${healthProfile.dietType ?? 'Bình thường'}
''';
    }

    prompt += '''

**YÊU CẦU PHÂN TÍCH:**
Vui lòng cung cấp phân tích chi tiết dưới dạng JSON với các trường sau:
{
  "score": <số từ 0-10>,
  "rating": "<Xuất sắc/Tốt/Trung bình/Kém>",
  "healthRisks": ["<rủi ro 1>", "<rủi ro 2>"],
  "nutritionalBenefits": ["<lợi ích 1>", "<lợi ích 2>"],
  "allergies": ["<cảnh báo dị ứng nếu có>"],
  "dietaryMismatch": ["<không phù hợp chế độ ăn nếu có>"],
  "recommendations": ["<gợi ý 1>", "<gợi ý 2>"],
  "detailedAnalysis": "<phân tích chi tiết dạng text 2-3 câu về sản phẩm này>"
}

Chú ý:
- Score phải dựa trên Nutriscore + tác động tới sức khỏe người dùng nếu có thông tin
- Nếu người dùng có dị ứng, hãy kiểm tra kỹ thành phần
- Nếu người dùng ăn chay/vegan, hãy kiểm tra xem sản phẩm phù hợp không
- Nếu người dùng có bệnh (tiểu đường, huyết áp cao), điều chỉnh score theo đó
- Trả về JSON hợp lệ, không có text thêm
''';

    return prompt;
  }

  /// Parse AI response from Gemini
  HealthScoreResult _parseAIResponse(
    String aiText,
    ProductModel product,
    HealthProfile? healthProfile,
  ) {
    try {
      AppLogger.debug('[GeminiService._parseAIResponse] Attempting to parse response...');
      
      // Clean JSON from markdown code blocks if present
      String jsonText = aiText;
      if (jsonText.contains('```json')) {
        AppLogger.debug('[GeminiService] Found json markdown block, cleaning...');
        jsonText = jsonText.replaceAll('```json', '').replaceAll('```', '');
      } else if (jsonText.contains('```')) {
        AppLogger.debug('[GeminiService] Found markdown block, cleaning...');
        jsonText = jsonText.replaceAll('```', '');
      }

      AppLogger.debug('[GeminiService] Cleaned response length: ${jsonText.length}');
      
      // Parse JSON
      final Map<String, dynamic> data = _parseJsonString(jsonText);
      AppLogger.debug('[GeminiService] JSON parsed. Keys: ${data.keys.toList()}');

      final score = (data['score'] as num?)?.toDouble() ?? 5.0;
      final rating = data['rating'] as String? ?? 'Trung bình';
      final warnings = List<String>.from(data['healthRisks'] as List? ?? []);
      final benefits = List<String>.from(
          data['nutritionalBenefits'] as List? ?? []);
      final allergieWarnings =
          List<String>.from(data['allergies'] as List? ?? []);
      final dietWarnings =
          List<String>.from(data['dietaryMismatch'] as List? ?? []);
      final aiAnalysis = data['detailedAnalysis'] as String? ??
          'Không thể phân tích sản phẩm này';

      AppLogger.debug('[GeminiService] Parsed fields. Score: $score, Rating: $rating');

      // Extract nutrition values with correct key names from API
      final nutriments = product.nutriments ?? {};
      AppLogger.debug(
        '[GeminiService] Available nutriment keys: ${nutriments.keys.toList()}',
      );
      
      final nutritionAnalysis = {
        'energy': nutriments['energy-kcal_100g'] ?? 
                  nutriments['energy-kcal'] ?? 
                  nutriments['energy-kJ'] ?? 
                  nutriments['energy'] ?? 0,
        'protein': nutriments['proteins_100g'] ?? 
                   nutriments['proteins'] ?? 
                   nutriments['protein'] ?? 0,
        'fat': nutriments['fat_100g'] ?? 
               nutriments['fat'] ?? 0,
        'carbohydrates': nutriments['carbohydrates_100g'] ?? 
                         nutriments['carbs_100g'] ?? 
                         nutriments['carbohydrates'] ?? 0,
        'sugars': nutriments['sugars_100g'] ?? 
                  nutriments['sugars'] ?? 
                  nutriments['sugar'] ?? 0,
        'sodium': nutriments['sodium_100g'] ?? 
                  nutriments['salt_100g'] ?? 
                  nutriments['sodium'] ?? 0,
        'fiber': nutriments['fiber_100g'] ?? 
                 nutriments['fiber'] ?? 0,
        'nutriscore': product.nutriscore ?? 'unknown',
        'ecoscore': product.ecoscore ?? 'unknown',
      };
      
      AppLogger.debug('[GeminiService] Extracted nutrition values:');
      nutritionAnalysis.forEach((key, value) {
        AppLogger.debug('  $key: $value');
      });

      return HealthScoreResult(
        score: score.clamp(0.0, 10.0),
        rating: rating,
        warnings: warnings,
        benefits: benefits,
        allergieWarnings: allergieWarnings,
        dietWarnings: dietWarnings,
        nutritionAnalysis: nutritionAnalysis,
        aiAnalysis: aiAnalysis,
      );
    } catch (e) {
      AppLogger.error(
        '[GeminiService._parseAIResponse] Parse error. Type: ${e.runtimeType}',
        error: e,
      );
      return _getFallbackAnalysis(product, healthProfile);
    }
  }

  /// Parse JSON string safely
  Map<String, dynamic> _parseJsonString(String jsonString) {
    try {
      // Try direct parse first
      return _jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // If direct parse fails, try to extract JSON from text
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(jsonString);
      if (jsonMatch != null) {
        try {
          return _jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        } catch (e2) {
          AppLogger.error('[GeminiService] JSON extraction error', error: e2);
          return {};
        }
      }
      return {};
    }
  }

  /// Simple JSON decoder (without dart:convert to avoid issues)
  dynamic _jsonDecode(String jsonString) {
    // Check if it's a valid JSON structure and parse manually
    jsonString = jsonString.trim();

    if (jsonString.startsWith('{') && jsonString.endsWith('}')) {
      final result = <String, dynamic>{};
      final content = jsonString.substring(1, jsonString.length - 1);

      // Simple parser - split by commas and process key-value pairs
      final pairs = _splitJsonPairs(content);

      for (final pair in pairs) {
        final colonIndex = pair.indexOf(':');
        if (colonIndex > 0) {
          final key = pair.substring(0, colonIndex).trim().replaceAll('"', '');
          final value = pair.substring(colonIndex + 1).trim();

          result[key] = _parseJsonValue(value);
        }
      }

      return result;
    }

    return {};
  }

  /// Split JSON pairs manually
  List<String> _splitJsonPairs(String content) {
    final pairs = <String>[];
    var current = '';
    var braceDepth = 0;
    var bracketDepth = 0;
    var inString = false;
    var escapeNext = false;

    for (final char in content.split('')) {
      if (escapeNext) {
        current += char;
        escapeNext = false;
        continue;
      }

      if (char == '\\') {
        current += char;
        escapeNext = true;
        continue;
      }

      if (char == '"' && braceDepth == 0 && bracketDepth == 0) {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{') braceDepth++;
        if (char == '}') braceDepth--;
        if (char == '[') bracketDepth++;
        if (char == ']') bracketDepth--;

        if (char == ',' && braceDepth == 0 && bracketDepth == 0) {
          if (current.isNotEmpty) {
            pairs.add(current);
          }
          current = '';
          continue;
        }
      }

      current += char;
    }

    if (current.isNotEmpty) {
      pairs.add(current);
    }

    return pairs;
  }

  /// Parse individual JSON value
  dynamic _parseJsonValue(String value) {
    value = value.trim();

    // Number
    if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(value)) {
      if (value.contains('.')) {
        return double.tryParse(value) ?? 5.0;
      }
      return int.tryParse(value) ?? 5;
    }

    // Boolean
    if (value == 'true') return true;
    if (value == 'false') return false;

    // String
    if (value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }

    // Array
    if (value.startsWith('[') && value.endsWith(']')) {
      final content = value.substring(1, value.length - 1);
      return _parseArray(content);
    }

    return value;
  }

  /// Parse JSON array
  List<dynamic> _parseArray(String content) {
    final items = <dynamic>[];
    var current = '';
    var braceDepth = 0;
    var inString = false;
    var escapeNext = false;

    for (final char in content.split('')) {
      if (escapeNext) {
        current += char;
        escapeNext = false;
        continue;
      }

      if (char == '\\') {
        current += char;
        escapeNext = true;
        continue;
      }

      if (char == '"') {
        inString = !inString;
      }

      if (!inString) {
        if (char == '{') braceDepth++;
        if (char == '}') braceDepth--;

        if (char == ',' && braceDepth == 0) {
          if (current.isNotEmpty) {
            items.add(_parseJsonValue(current.trim()));
          }
          current = '';
          continue;
        }
      }

      current += char;
    }

    if (current.isNotEmpty) {
      items.add(_parseJsonValue(current.trim()));
    }

    return items;
  }

  /// Fallback analysis if AI call fails
  HealthScoreResult _getFallbackAnalysis(
    ProductModel product,
    HealthProfile? healthProfile,
  ) {
    double score = 5.0;

    if (product.nutriscore != null) {
      final nutriscoreMap = {'a': 10.0, 'b': 8.0, 'c': 6.0, 'd': 4.0, 'e': 2.0};
      score = nutriscoreMap[product.nutriscore!.toLowerCase()] ?? 5.0;
    }

    final warnings = <String>[];
    if (product.nutriscore == 'd' || product.nutriscore == 'e') {
      warnings.add('⚠️ Chất lượng dinh dưỡng dưới trung bình');
    }

    // Extract nutrition with correct key names from API
    final nutriments = product.nutriments ?? {};
    final nutritionAnalysis = {
      'energy': nutriments['energy-kcal_100g'] ?? 
                nutriments['energy-kcal'] ?? 
                nutriments['energy-kJ'] ?? 
                nutriments['energy'] ?? 0,
      'protein': nutriments['proteins_100g'] ?? 
                 nutriments['proteins'] ?? 
                 nutriments['protein'] ?? 0,
      'fat': nutriments['fat_100g'] ?? 
             nutriments['fat'] ?? 0,
      'carbohydrates': nutriments['carbohydrates_100g'] ?? 
                       nutriments['carbs_100g'] ?? 
                       nutriments['carbohydrates'] ?? 0,
      'sugars': nutriments['sugars_100g'] ?? 
                nutriments['sugars'] ?? 
                nutriments['sugar'] ?? 0,
      'sodium': nutriments['sodium_100g'] ?? 
                nutriments['salt_100g'] ?? 
                nutriments['sodium'] ?? 0,
      'fiber': nutriments['fiber_100g'] ?? 
               nutriments['fiber'] ?? 0,
      'nutriscore': product.nutriscore ?? 'unknown',
      'ecoscore': product.ecoscore ?? 'unknown',
    };

    return HealthScoreResult(
      score: score,
      rating: score >= 8 ? 'Xuất sắc' : score >= 6 ? 'Tốt' : 'Trung bình',
      warnings: warnings,
      benefits: [],
      allergieWarnings: [],
      dietWarnings: [],
      nutritionAnalysis: nutritionAnalysis,
      aiAnalysis:
          'Không thể kết nối AI. Dựa vào Nutriscore để đánh giá sản phẩm.',
    );
  }
}
