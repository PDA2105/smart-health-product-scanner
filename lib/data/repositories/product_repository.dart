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
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      // 1. Try to get the product from Firestore cache.
      final productFromFirestore = await _getProductFromFirestore(barcode);
      if (productFromFirestore != null) {
        return productFromFirestore;
      }

      // 2. If not in Firestore, fetch from the remote API.
      final productFromApi =
          await _remoteDataSource.fetchProductFromApi(barcode);

      // If not found in the API, throw an exception.
      if (productFromApi == null) {
        throw Exception('Product with barcode $barcode not found.');
      }

      // 3. Cache the new product in Firestore for future requests.
      await _cacheProductInFirestore(productFromApi);

      return productFromApi;
    } catch (e) {
      // Log the error and rethrow to be handled by the upper layer (e.g., UI).
      print('Error getting product by barcode $barcode: $e');
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
}
