import 'package:flutter/foundation.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/models/wishlist_item_model.dart';
import '../../../../data/repositories/wishlist_repository.dart';

/// Provider to manage wishlist
class WishlistProvider extends ChangeNotifier {
  WishlistProvider({WishlistRepository? wishlistRepository})
      : _wishlistRepository = wishlistRepository;

  WishlistRepository? _wishlistRepository;

  List<WishlistItemModel> _wishlist = [];
  bool _isLoading = false;
  String? _error;

  List<WishlistItemModel> get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateRepository(WishlistRepository? repository) {
    _wishlistRepository = repository;
    if (repository == null) {
      _wishlist = [];
      _isLoading = false;
      _error = null;
      notifyListeners();
    }
  }

  bool _ensureRepository() {
    if (_wishlistRepository != null) return true;
    _error = 'Vui lòng đăng nhập để sử dụng danh sách yêu thích.';
    notifyListeners();
    return false;
  }

  /// Adds a product to wishlist
  Future<void> addToWishlist(ProductModel product, {String? note}) async {
    if (!_ensureRepository()) return;

    try {
      _error = null;
      await _wishlistRepository!.addToWishlist(product, note: note);
      // Refresh the list
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Loads wishlist from the repository
  Future<void> loadWishlist() async {
    if (!_ensureRepository()) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wishlist = await _wishlistRepository!.getWishlist();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if a product is in wishlist
  Future<bool> isInWishlist(String barcode) async {
    if (!_ensureRepository()) return false;

    try {
      return await _wishlistRepository!.isInWishlist(barcode);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Removes a product from wishlist by item ID
  Future<void> removeFromWishlist(String itemId) async {
    if (!_ensureRepository()) return;

    try {
      _error = null;
      await _wishlistRepository!.removeFromWishlist(itemId);
      // Refresh the list
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Removes a product from wishlist by barcode
  Future<void> removeFromWishlistByBarcode(String barcode) async {
    if (!_ensureRepository()) return;

    try {
      _error = null;
      await _wishlistRepository!.removeFromWishlistByBarcode(barcode);
      // Refresh the list
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clears all wishlist
  Future<void> clearWishlist() async {
    if (!_ensureRepository()) return;

    try {
      _error = null;
      await _wishlistRepository!.clearWishlist();
      _wishlist = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Updates the note on a wishlist item
  Future<void> updateWishlistNote(String itemId, String note) async {
    if (!_ensureRepository()) return;

    try {
      _error = null;
      await _wishlistRepository!.updateWishlistNote(itemId, note);
      // Refresh the list
      await loadWishlist();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
