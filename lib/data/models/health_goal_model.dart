import 'package:cloud_firestore/cloud_firestore.dart';

/// Enum for health goal types.
enum HealthGoalType { losWeight, gainWeight, maintainWeight }

/// A model for storing health tracking goals.
class HealthGoalModel {
  const HealthGoalModel({
    required this.id,
    required this.userId,
    required this.goalType,
    required this.targetWeight,
    required this.startDate,
    required this.targetDate,
    this.startWeight,
    this.currentProgress = 0.0,
    this.isActive = true,
    this.notes,
  });

  final String id;
  final String userId;
  final HealthGoalType goalType;
  final double targetWeight;
  final DateTime startDate;
  final DateTime targetDate;
  final double? startWeight;
  final double currentProgress; // 0-100 percentage
  final bool isActive;
  final String? notes;

  /// Get goal description (e.g., "Lose 5kg in 2 months")
  String getDescription(double? currentWeight) {
    if (currentWeight == null) {
      return _goalTypeLabel(goalType) +
          ' - Target: ${targetWeight.toStringAsFixed(1)} kg';
    }

    final diff = (targetWeight - currentWeight).abs();
    return _goalTypeLabel(goalType) +
        ' - ${diff.toStringAsFixed(1)} kg to reach ${targetWeight.toStringAsFixed(1)} kg';
  }

  static String _goalTypeLabel(HealthGoalType type) {
    switch (type) {
      case HealthGoalType.losWeight:
        return '📉 Giảm cân';
      case HealthGoalType.gainWeight:
        return '📈 Tăng cân';
      case HealthGoalType.maintainWeight:
        return '⏸️ Giữ cân';
    }
  }

  /// Creates a [HealthGoalModel] from a Firestore document.
  factory HealthGoalModel.fromMap(Map<String, dynamic> map) {
    return HealthGoalModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String,
      goalType: HealthGoalType.values[map['goalType'] as int? ?? 2],
      targetWeight: (map['targetWeight'] as num).toDouble(),
      startDate: (map['startDate'] as Timestamp).toDate(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      startWeight: (map['startWeight'] as num?)?.toDouble(),
      currentProgress: (map['currentProgress'] as num? ?? 0).toDouble(),
      isActive: map['isActive'] as bool? ?? true,
      notes: map['notes'] as String?,
    );
  }

  /// Converts this [HealthGoalModel] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'goalType': goalType.index,
      'targetWeight': targetWeight,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'startWeight': startWeight,
      'currentProgress': currentProgress,
      'isActive': isActive,
      'notes': notes,
    };
  }

  /// Creates a copy of this health goal with field changes.
  HealthGoalModel copyWith({
    String? id,
    String? userId,
    HealthGoalType? goalType,
    double? targetWeight,
    DateTime? startDate,
    DateTime? targetDate,
    double? startWeight,
    double? currentProgress,
    bool? isActive,
    String? notes,
  }) {
    return HealthGoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      targetWeight: targetWeight ?? this.targetWeight,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      startWeight: startWeight ?? this.startWeight,
      currentProgress: currentProgress ?? this.currentProgress,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  /// Calculate days remaining
  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }

  /// Check if goal deadline has passed
  bool get isOverdue {
    return DateTime.now().isAfter(targetDate) && isActive;
  }
}
