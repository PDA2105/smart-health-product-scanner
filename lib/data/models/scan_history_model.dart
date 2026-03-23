import 'package:cloud_firestore/cloud_firestore.dart';

/// A model for storing scan history of products.
class ScanHistoryModel {
  const ScanHistoryModel({
    required this.id,
    required this.barcode,
    required this.productName,
    required this.productImage,
    required this.timestamp,
    this.brands,
    this.nutriscore,
  });

  final String id;
  final String barcode;
  final String productName;
  final String? productImage;
  final DateTime timestamp;
  final String? brands;
  final String? nutriscore;

  /// Creates a [ScanHistoryModel] from a Firestore document.
  factory ScanHistoryModel.fromMap(Map<String, dynamic> map) {
    return ScanHistoryModel(
      id: map['id'] as String? ?? '',
      barcode: map['barcode'] as String,
      productName: map['productName'] as String,
      productImage: map['productImage'] as String?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      brands: map['brands'] as String?,
      nutriscore: map['nutriscore'] as String?,
    );
  }

  /// Converts this [ScanHistoryModel] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'productName': productName,
      'productImage': productImage,
      'timestamp': FieldValue.serverTimestamp(),
      'brands': brands,
      'nutriscore': nutriscore,
    };
  }
}
