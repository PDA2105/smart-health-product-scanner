import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// A data model for a product.
class ProductModel {
  const ProductModel({
    required this.barcode,
    this.name,
    this.imageUrl,
    this.brands,
    this.quantity,
    this.nutriscore,
    this.ecoscore,
    this.ingredients,
    this.nutriments,
    this.lastUpdated,
  });

  final String barcode;
  final String? name;
  final String? imageUrl;
  final String? brands;
  final String? quantity;
  final String? nutriscore;
  final String? ecoscore;
  final List<String>? ingredients;
  final Map<String, dynamic>? nutriments;
  final DateTime? lastUpdated;

  /// Creates a [ProductModel] from a Firestore document.
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      barcode: map['barcode'] as String,
      name: map['name'] as String?,
      imageUrl: map['imageUrl'] as String?,
      brands: map['brands'] as String?,
      quantity: map['quantity'] as String?,
      nutriscore: map['nutriscore'] as String?,
      ecoscore: map['ecoscore'] as String?,
      ingredients: (map['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      nutriments: map['nutriments'] as Map<String, dynamic>?,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a [ProductModel] from an OpenFoodFacts [Product].
  factory ProductModel.fromApi(Product product) {
    return ProductModel(
      barcode: product.barcode ?? '',
      name: product.productName,
      imageUrl: product.imageFrontUrl,
      brands: product.brands,
      quantity: product.quantity,
      nutriscore: product.nutriscore,
      ecoscore: product.ecoscoreData?.grade,
      ingredients: product.ingredients?.map((i) => i.text ?? '').toList(),
      nutriments: product.nutriments?.toJson(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Converts this [ProductModel] to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'imageUrl': imageUrl,
      'brands': brands,
      'quantity': quantity,
      'nutriscore': nutriscore,
      'ecoscore': ecoscore,
      'ingredients': ingredients,
      'nutriments': nutriments,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}
