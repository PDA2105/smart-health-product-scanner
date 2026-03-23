import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import '../../core/services/app_logger.dart';

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
    // Convert nutriments: Firestore may store as String, need to convert to number
    Map<String, dynamic>? nutriments = map['nutriments'] as Map<String, dynamic>?;
    if (nutriments != null) {
      nutriments = nutriments.map((key, value) {
        // If value is String, try to convert to double
        if (value is String) {
          try {
            return MapEntry(key, double.parse(value));
          } catch (e) {
            return MapEntry(key, value);
          }
        }
        return MapEntry(key, value);
      });
    }

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
      nutriments: nutriments,
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a [ProductModel] from an OpenFoodFacts [Product].
  factory ProductModel.fromApi(Product product) {
    // Debug: Log nutriments structure
    AppLogger.debug('[ProductModel.fromApi] Product nutriments:');
    if (product.nutriments != null) {
      // Nutriments is a class with toJson(), let's convert and see what we get
      final nutrimentMap = product.nutriments!.toJson();
      AppLogger.debug(
        '[ProductModel.fromApi] Nutriments toJson() keys: ${nutrimentMap.keys.toList()}',
      );
      // Log non-zero values
      nutrimentMap.forEach((key, value) {
        if (value != null && value != 0) {
          AppLogger.debug('  $key: $value');
        }
      });
    } else {
      AppLogger.warn('[ProductModel.fromApi] Nutriments is null');
    }

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
