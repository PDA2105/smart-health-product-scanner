import 'package:flutter/foundation.dart';
import 'package:smart_health_product_scanner/core/config/gemini_config.dart';
import 'package:smart_health_product_scanner/core/services/gemini_health_analysis_service.dart';
import 'package:smart_health_product_scanner/data/models/health_profile.dart';
import 'package:smart_health_product_scanner/data/models/product_model.dart';

/// Provider to manage product health analysis with Gemini AI
class HealthAnalysisProvider extends ChangeNotifier {
  HealthAnalysisProvider({
    GeminiHealthAnalysisService? geminiService,
  }) {
    _geminiService = geminiService ?? 
        GeminiHealthAnalysisService(apiKey: GeminiConfig.apiKey);
  }

  late final GeminiHealthAnalysisService _geminiService;

  HealthScoreResult? _analysisResult;
  bool _isLoading = false;
  String? _error;

  HealthScoreResult? get analysisResult => _analysisResult;
  bool get isLoading => _isLoading;
  String? get error => _error;

  get scoreResult => null;

  /// Analyze product based on health profile using Gemini AI
  Future<void> analyzeProduct(
    ProductModel product,
    HealthProfile? healthProfile,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!GeminiConfig.enableGeminiAI) {
        _error = 'Gemini AI not enabled';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _analysisResult = await _geminiService.analyzeProduct(
        product,
        healthProfile,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '❌ Lỗi phân tích với AI: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print(_error);
    }
  }

  /// Clear analysis result
  void clearAnalysis() {
    _analysisResult = null;
    _error = null;
    notifyListeners();
  }
}
