import 'package:cloud_firestore/cloud_firestore.dart';

/// Health profile model containing user's health information
class HealthProfile {
  const HealthProfile({
    required this.userId,
    this.nickname,
    this.age,
    this.gender,
    this.phone,
    this.location,
    this.weight,
    this.height,
    this.bmiValue,
    this.bmiCategory,
    this.diseases,
    this.allergies,
    this.dietType,
    this.updatedAt,
  });

  final String userId;
  final String? nickname;
  final int? age;
  final String? gender; // 'male', 'female', 'other'
  final String? phone;
  final String? location;
  final double? weight; // in kg
  final double? height; // in cm
  final double? bmiValue;
  final String? bmiCategory;
  final List<String>? diseases; // e.g., ['diabetes', 'hypertension']
  final List<String>? allergies; // e.g., ['peanuts', 'lactose']
  final String? dietType; // 'vegetarian', 'vegan', 'keto', 'regular', etc.
  final DateTime? updatedAt;

  /// Calculate BMI (Body Mass Index)
  double? get bmi {
    if (bmiValue != null) return bmiValue;
    return _calculateBmi(weight, height);
  }

  /// Get BMI category
  String? get computedBmiCategory {
    if (bmiCategory != null && bmiCategory!.isNotEmpty) return bmiCategory;
    return _calculateBmiCategory(bmi);
  }

  /// Creates a [HealthProfile] from a Firestore document.
  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    return HealthProfile(
      userId: map['userId'] as String,
      nickname: map['nickname'] as String?,
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      phone: map['phone'] as String?,
      location: map['location'] as String?,
      weight: (map['weight'] as num?)?.toDouble(),
      height: (map['height'] as num?)?.toDouble(),
        bmiValue: (map['bmiValue'] as num?)?.toDouble(),
        bmiCategory: map['bmiCategory'] as String?,
      diseases: (map['diseases'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      allergies: (map['allergies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      dietType: map['dietType'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts this [HealthProfile] to a map for Firestore.
  Map<String, dynamic> toMap() {
    final computedBmi = _calculateBmi(weight, height);
    final computedCategory = _calculateBmiCategory(computedBmi);

    return {
      'userId': userId,
      'nickname': nickname,
      'age': age,
      'gender': gender,
      'phone': phone,
      'location': location,
      'weight': weight,
      'height': height,
      'bmiValue': computedBmi,
      'bmiCategory': computedCategory,
      'diseases': diseases,
      'allergies': allergies,
      'dietType': dietType,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a copy of this profile with updated fields.
  HealthProfile copyWith({
    String? userId,
    String? nickname,
    int? age,
    String? gender,
    String? phone,
    String? location,
    double? weight,
    double? height,
    double? bmiValue,
    String? bmiCategory,
    List<String>? diseases,
    List<String>? allergies,
    String? dietType,
    DateTime? updatedAt,
  }) {
    return HealthProfile(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bmiValue: bmiValue ?? this.bmiValue,
      bmiCategory: bmiCategory ?? this.bmiCategory,
      diseases: diseases ?? this.diseases,
      allergies: allergies ?? this.allergies,
      dietType: dietType ?? this.dietType,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double? _calculateBmi(double? weight, double? height) {
    if (weight == null || height == null || height == 0) return null;
    final value = weight / ((height / 100) * (height / 100));
    return double.parse(value.toStringAsFixed(2));
  }

  static String? _calculateBmiCategory(double? value) {
    if (value == null) return null;

    if (value < 18.5) return 'Thiếu cân';
    if (value < 25) return 'Bình thường';
    if (value < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  /// Check if profile is complete
  bool get isComplete {
    return age != null &&
        gender != null &&
        weight != null &&
        height != null;
  }
}
