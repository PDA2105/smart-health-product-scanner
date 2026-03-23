import 'package:flutter/material.dart';

import '../../../../core/services/gemini_health_analysis_service.dart';

/// Reusable component to display health score with analysis
/// Shows: Circular progress, rating badge, and detailed analysis text
class HealthScoreDisplay extends StatelessWidget {
  final HealthScoreResult result;

  const HealthScoreDisplay({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(result.score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scoreColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          // Score circle
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: result.score / 10,
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  backgroundColor: Colors.grey[200],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${result.score.toInt()}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '/10',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Rating and analysis
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    result.rating,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (result.aiAnalysis.isNotEmpty)
                  Text(
                    result.aiAnalysis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
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
  }

  /// Get color based on health score
  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6) return Colors.teal;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }
}
