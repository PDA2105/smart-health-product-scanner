import 'package:cloud_firestore/cloud_firestore.dart';

/// A model for storing wishlist items (favorite products).
class WishlistItemModel {
  const WishlistItemModel({
    required this.id,
    required this.barcode,
    required this.productName,
    required this.productImage,
    required this.addedAt,
    this.brands,
    this.nutriscore,
    this.note,
  });

  final String id;
  final String barcode;
  final String productName;
  final String? productImage;
  final DateTime addedAt;
  final String? brands;
  final String? nutriscore;
  final String? note;

  /// Creates a [WishlistItemModel] from a Firestore document.
  factory WishlistItemModel.fromMap(Map<String, dynamic> map) {
    return WishlistItemModel(
      id: map['id'] as String? ?? '',
      barcode: map['barcode'] as String,
      productName: map['productName'] as String,
      productImage: map['productImage'] as String?,
      addedAt: (map['addedAt'] as Timestamp).toDate(),
      brands: map['brands'] as String?,
      nutriscore: map['nutriscore'] as String?,
      note: map['note'] as String?,
    );
  }

  /// Converts this [WishlistItemModel] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'productName': productName,
      'productImage': productImage,
      'addedAt': FieldValue.serverTimestamp(),
      'brands': brands,
      'nutriscore': nutriscore,
      'note': note,
    };
  }
}
