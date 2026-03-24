import 'package:cloud_firestore/cloud_firestore.dart';

/// A model for storing weight tracking entries.
class WeightEntryModel {
  const WeightEntryModel({
    required this.id,
    required this.userId,
    required this.weight,
    required this.recordedDate,
    this.notes,
    this.calculatedBMI,
  });

  final String id;
  final String userId;
  final double weight;
  final DateTime recordedDate;
  final String? notes;
  final double? calculatedBMI;

  /// Creates a [WeightEntryModel] from a Firestore document.
  factory WeightEntryModel.fromMap(Map<String, dynamic> map) {
    return WeightEntryModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String,
      weight: (map['weight'] as num).toDouble(),
      recordedDate: (map['recordedDate'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
      calculatedBMI: (map['calculatedBMI'] as num?)?.toDouble(),
    );
  }

  /// Converts this [WeightEntryModel] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'recordedDate': Timestamp.fromDate(recordedDate),
      'notes': notes,
      'calculatedBMI': calculatedBMI,
    };
  }

  /// Creates a copy of this weight entry with field changes.
  WeightEntryModel copyWith({
    String? id,
    String? userId,
    double? weight,
    DateTime? recordedDate,
    String? notes,
    double? calculatedBMI,
  }) {
    return WeightEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      recordedDate: recordedDate ?? this.recordedDate,
      notes: notes ?? this.notes,
      calculatedBMI: calculatedBMI ?? this.calculatedBMI,
    );
  }
}
