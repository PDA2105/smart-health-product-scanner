import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/app_logger.dart';
import '../models/product_model.dart';
import '../models/wishlist_item_model.dart';

/// A repository to handle wishlist operations.
class WishlistRepository {
  WishlistRepository(this._firestore, this._userId);

  final FirebaseFirestore _firestore;
  final String _userId;

  /// A reference to the wishlist subcollection for the current user.
  CollectionReference<WishlistItemModel> get _wishlistCollection =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('wishlist')
          .withConverter<WishlistItemModel>(
            fromFirestore: (snapshots, _) =>
                WishlistItemModel.fromMap(snapshots.data()!),
            toFirestore: (item, _) => item.toMap(),
          );

  /// Adds a product to the wishlist.
  Future<void> addToWishlist(ProductModel product, {String? note}) async {
    try {
      // Check if already in wishlist
      final existing = await _wishlistCollection
          .where('barcode', isEqualTo: product.barcode)
          .get();

      if (existing.docs.isNotEmpty) {
        throw Exception('Sản phẩm đã có trong danh sách yêu thích');
      }

      final wishlistItem = WishlistItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        barcode: product.barcode,
        productName: product.name ?? 'Sản phẩm không xác định',
        productImage: product.imageUrl,
        addedAt: DateTime.now(),
        brands: product.brands,
        nutriscore: product.nutriscore,
        note: note,
      );

      await _wishlistCollection.doc(wishlistItem.id).set(wishlistItem);
    } catch (e) {
      AppLogger.error(
        '[WishlistRepository] Error adding to wishlist',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets all wishlist items for the current user.
  Future<List<WishlistItemModel>> getWishlist() async {
    try {
      final querySnapshot =
          await _wishlistCollection.orderBy('addedAt', descending: true).get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppLogger.error(
        '[WishlistRepository] Error getting wishlist',
        error: e,
      );
      rethrow;
    }
  }

  /// Checks if a product is in the wishlist.
  Future<bool> isInWishlist(String barcode) async {
    try {
      final querySnapshot = await _wishlistCollection
          .where('barcode', isEqualTo: barcode)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      AppLogger.error(
        '[WishlistRepository] Error checking wishlist',
        error: e,
      );
      return false;
    }
  }

  /// Removes a product from the wishlist.
  Future<void> removeFromWishlist(String itemId) async {
    try {
      await _wishlistCollection.doc(itemId).delete();
    } catch (e) {
      AppLogger.error(
        '[WishlistRepository] Error removing from wishlist',
        error: e,
      );
      rethrow;
    }
  }

  /// Removes a product from wishlist by barcode.
  Future<void> removeFromWishlistByBarcode(String barcode) async {
    try {
      final querySnapshot = await _wishlistCollection
          .where('barcode', isEqualTo: barcode)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      AppLogger.error(
        '[WishlistRepository] Error removing from wishlist by barcode',
        error: e,
      );
      rethrow;
    }
  }

  /// Clears all wishlist items.
  Future<void> clearWishlist() async {
    try {
      final querySnapshot = await _wishlistCollection.get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      AppLogger.error(
        '[WishlistRepository] Error clearing wishlist',
        error: e,
      );
      rethrow;
    }
  }

  /// Updates the note on a wishlist item.
  Future<void> updateWishlistNote(String itemId, String note) async {
    try {
      await _wishlistCollection.doc(itemId).update({'note': note});
    } catch (e) {
      AppLogger.error(
        '[WishlistRepository] Error updating wishlist note',
        error: e,
      );
      rethrow;
    }
  }
}
