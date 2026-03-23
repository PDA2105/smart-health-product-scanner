import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/app_logger.dart';
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
      AppLogger.debug(
        '[ProductRepository] Fetching product: $barcode (forceRefresh: $forceRefresh)',
      );
      
      // 1. Try to get the product from Firestore cache (unless forceRefresh is true).
      if (!forceRefresh) {
        final productFromFirestore = await _getProductFromFirestore(barcode);
        if (productFromFirestore != null) {
          AppLogger.debug('[ProductRepository] Found in Firestore cache');
          // Debug: Log cached nutriments
          if (productFromFirestore.nutriments != null) {
            AppLogger.debug('[ProductRepository] Cached nutriments:');
            productFromFirestore.nutriments!.forEach((key, value) {
              AppLogger.debug('  $key: $value');
            });
          }
          
          // If cached data has no nutrients, skip cache and fetch fresh
          bool hasEmptyNutrients = productFromFirestore.nutriments == null ||
              (productFromFirestore.nutriments!.isEmpty) ||
              (productFromFirestore.nutriments!.values.every((v) => v == 0 || v == null || v == '0'));
          
          if (hasEmptyNutrients) {
            AppLogger.warn(
              '[ProductRepository] Cached nutriments are empty, fetching fresh from API...',
            );
          } else {
            return productFromFirestore;
          }
        }
      }

      AppLogger.debug('[ProductRepository] Fetching from API...');
      // 2. If not in Firestore or forceRefresh, fetch from the remote API.
      final productFromApi =
          await _remoteDataSource.fetchProductFromApi(barcode);

      // If not found in the API, throw an exception.
      if (productFromApi == null) {
        throw Exception('Product with barcode $barcode not found.');
      }

      AppLogger.debug('[ProductRepository] Fetched from API, caching in Firestore...');
      // 3. Cache the new product in Firestore for future requests.
      await _cacheProductInFirestore(productFromApi);

      return productFromApi;
    } catch (e) {
      // Log the error and rethrow to be handled by the upper layer (e.g., UI).
      AppLogger.error(
        '[ProductRepository] Error getting product by barcode $barcode',
        error: e,
      );
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
    AppLogger.debug('[ProductRepository] Clearing cache for barcode: $barcode');
    await _productsCollection.doc(barcode).delete();
  }

  /// Clear all cached products
  Future<void> clearAllCache() async {
    AppLogger.debug('[ProductRepository] Clearing all cached products');
    final snapshot = await _productsCollection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Returns healthier alternatives from cached products.
  ///
  /// It only uses cached Firestore products, so this call is fast and avoids
  /// hitting external APIs while the user is browsing alternatives.
  Future<List<ProductModel>> getHealthierAlternatives(
    ProductModel currentProduct, {
    int limit = 12,
  }) async {
    final currentRank = _nutriscoreRank(currentProduct.nutriscore);

    if (currentRank <= 1) {
      return const [];
    }

    try {
      final snapshot = await _productsCollection.limit(120).get();
      final alternatives = snapshot.docs
          .map((doc) => doc.data())
          .where((product) => product.barcode != currentProduct.barcode)
          .where((product) => (product.name ?? '').trim().isNotEmpty)
          .where((product) {
            final rank = _nutriscoreRank(product.nutriscore);
            return rank < currentRank;
          })
          .toList();

      alternatives.sort((a, b) {
        final rankCompare =
            _nutriscoreRank(a.nutriscore).compareTo(_nutriscoreRank(b.nutriscore));
        if (rankCompare != 0) return rankCompare;
        return (a.name ?? '').compareTo(b.name ?? '');
      });

      if (alternatives.length <= limit) {
        return alternatives;
      }
      return alternatives.take(limit).toList();
    } catch (e) {
      AppLogger.error(
        '[ProductRepository] Error getting healthier alternatives',
        error: e,
      );
      rethrow;
    }
  }

  int _nutriscoreRank(String? score) {
    switch ((score ?? '').toLowerCase()) {
      case 'a':
        return 1;
      case 'b':
        return 2;
      case 'c':
        return 3;
      case 'd':
        return 4;
      case 'e':
        return 5;
      default:
        return 99;
    }
  }
}
