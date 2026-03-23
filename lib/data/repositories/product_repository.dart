import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// A repository to handle product-related operations.
class ProductRepository {
  ProductRepository(this._firestore, this._remoteDataSource);

  final FirebaseFirestore _firestore;
  final ProductRemoteDataSource _remoteDataSource;

  /// A reference to the 'products' collection in Firestore with a converter.
  CollectionReference<ProductModel> get _productsCollection =>
      _firestore.collection('products').withConverter<ProductModel>(
            fromFirestore: (snapshots, _) =>
                ProductModel.fromMap(snapshots.data()!),
            toFirestore: (product, _) => product.toMap(),
          );

  /// Gets a product by its barcode.
  ///
  /// It first tries to fetch the product from Firestore. If it's not available,
  /// it fetches the product from the Open Food Facts API, caches it in Firestore,
  /// and then returns it.
  /// 
  /// If [forceRefresh] is true, skip Firestore cache and fetch fresh from API.
  Future<ProductModel?> getProductByBarcode(
    String barcode, {
    bool forceRefresh = false,
  }) async {
    try {
      print('🔍 [ProductRepository] Fetching product: $barcode (forceRefresh: $forceRefresh)');
      
      // 1. Try to get the product from Firestore cache (unless forceRefresh is true).
      if (!forceRefresh) {
        final productFromFirestore = await _getProductFromFirestore(barcode);
        if (productFromFirestore != null) {
          print('✅ [ProductRepository] Found in Firestore cache');
          // Debug: Log cached nutriments
          if (productFromFirestore.nutriments != null) {
            print('🔍 [ProductRepository] Cached nutriments:');
            productFromFirestore.nutriments!.forEach((key, value) {
              print('  $key: $value');
            });
          }
          
          // If cached data has no nutrients, skip cache and fetch fresh
          bool hasEmptyNutrients = productFromFirestore.nutriments == null ||
              (productFromFirestore.nutriments!.isEmpty) ||
              (productFromFirestore.nutriments!.values.every((v) => v == 0 || v == null || v == '0'));
          
          if (hasEmptyNutrients) {
            print('⚠️ [ProductRepository] Cached nutriments are empty, fetching fresh from API...');
          } else {
            return productFromFirestore;
          }
        }
      }

      print('⏳ [ProductRepository] Fetching from API...');
      // 2. If not in Firestore or forceRefresh, fetch from the remote API.
      final productFromApi =
          await _remoteDataSource.fetchProductFromApi(barcode);

      // If not found in the API, throw an exception.
      if (productFromApi == null) {
        throw Exception('Product with barcode $barcode not found.');
      }

      print('✅ [ProductRepository] Fetched from API, caching in Firestore...');
      // 3. Cache the new product in Firestore for future requests.
      await _cacheProductInFirestore(productFromApi);

      return productFromApi;
    } catch (e) {
      // Log the error and rethrow to be handled by the upper layer (e.g., UI).
      print('❌ Error getting product by barcode $barcode: $e');
      rethrow;
    }
  }

  /// Fetches a product directly from the Firestore cache.
  Future<ProductModel?> _getProductFromFirestore(String barcode) async {
    final docSnapshot = await _productsCollection.doc(barcode).get();
    return docSnapshot.data();
  }

  /// Saves a product to the Firestore cache.
  Future<void> _cacheProductInFirestore(ProductModel product) {
    return _productsCollection.doc(product.barcode).set(product);
  }

  /// Clear cache for a specific barcode (for debugging/refresh)
  Future<void> clearCacheForBarcode(String barcode) async {
    print('🧹 [ProductRepository] Clearing cache for barcode: $barcode');
    await _productsCollection.doc(barcode).delete();
  }

  /// Clear all cached products
  Future<void> clearAllCache() async {
    print('🧹 [ProductRepository] Clearing all cached products');
    final snapshot = await _productsCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
