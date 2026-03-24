import 'package:cloud_firestore/cloud_firestore.dart';

/// A model for storing aggregated health score entries.
class HealthScoreEntryModel {
  const HealthScoreEntryModel({
    required this.id,
    required this.userId,
    required this.averageScore,
    required this.recordedDate,
    this.scannedProductsCount = 0,
    this.totalCalories = 0.0,
    this.totalProtein = 0.0,
    this.totalFat = 0.0,
    this.totalCarbs = 0.0,
  });

  final String id;
  final String userId;
  final double averageScore; // 0-10
  final DateTime recordedDate; // Can be daily, weekly, or monthly
  final int scannedProductsCount;
  final double totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbs;

  /// Creates a [HealthScoreEntryModel] from a Firestore document.
  factory HealthScoreEntryModel.fromMap(Map<String, dynamic> map) {
    return HealthScoreEntryModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String,
      averageScore: (map['averageScore'] as num).toDouble(),
      recordedDate: (map['recordedDate'] as Timestamp).toDate(),
      scannedProductsCount: map['scannedProductsCount'] as int? ?? 0,
      totalCalories: (map['totalCalories'] as num? ?? 0).toDouble(),
      totalProtein: (map['totalProtein'] as num? ?? 0).toDouble(),
      totalFat: (map['totalFat'] as num? ?? 0).toDouble(),
      totalCarbs: (map['totalCarbs'] as num? ?? 0).toDouble(),
    );
  }

  /// Converts this [HealthScoreEntryModel] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'averageScore': averageScore,
      'recordedDate': Timestamp.fromDate(recordedDate),
      'scannedProductsCount': scannedProductsCount,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalFat': totalFat,
      'totalCarbs': totalCarbs,
    };
  }

  /// Creates a copy of this health score entry with field changes.
  HealthScoreEntryModel copyWith({
    String? id,
    String? userId,
    double? averageScore,
    DateTime? recordedDate,
    int? scannedProductsCount,
    double? totalCalories,
    double? totalProtein,
    double? totalFat,
    double? totalCarbs,
  }) {
    return HealthScoreEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      averageScore: averageScore ?? this.averageScore,
      recordedDate: recordedDate ?? this.recordedDate,
      scannedProductsCount: scannedProductsCount ?? this.scannedProductsCount,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalFat: totalFat ?? this.totalFat,
      totalCarbs: totalCarbs ?? this.totalCarbs,
    );
  }

  /// Calculate average daily calories, protein, fat, carbs
  double get avgDailyCalories => scannedProductsCount > 0 ? totalCalories / scannedProductsCount : 0;
  double get avgDailyProtein => scannedProductsCount > 0 ? totalProtein / scannedProductsCount : 0;
  double get avgDailyFat => scannedProductsCount > 0 ? totalFat / scannedProductsCount : 0;
  double get avgDailyCarbs => scannedProductsCount > 0 ? totalCarbs / scannedProductsCount : 0;
}
