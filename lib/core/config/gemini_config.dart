import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gem API Configuration
class GeminiConfig {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String modelName = 'gemini-flash-latest'; // Test newest model
  
  /// Enable/disable Gemini AI features
  static const bool enableGeminiAI = true; // Enabled with new API key
  
  /// Timeout for Gemini API calls (in seconds)
  static const int timeoutSeconds = 30;
}
