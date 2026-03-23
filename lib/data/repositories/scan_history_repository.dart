import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/app_logger.dart';
import '../models/product_model.dart';
import '../models/scan_history_model.dart';

/// A repository to handle scan history operations.
class ScanHistoryRepository {
  ScanHistoryRepository(this._firestore, this._userId);

  final FirebaseFirestore _firestore;
  final String _userId;

  /// A reference to the scan history subcollection for the current user.
  CollectionReference<ScanHistoryModel> get _scanHistoryCollection =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('scanHistory')
          .withConverter<ScanHistoryModel>(
            fromFirestore: (snapshots, _) =>
                ScanHistoryModel.fromMap(snapshots.data()!),
            toFirestore: (item, _) => item.toMap(),
          );

  /// Adds a product to the scan history.
  Future<void> addToScanHistory(ProductModel product) async {
    try {
      final historyItem = ScanHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        barcode: product.barcode,
        productName: product.name ?? 'Sản phẩm không xác định',
        productImage: product.imageUrl,
        timestamp: DateTime.now(),
        brands: product.brands,
        nutriscore: product.nutriscore,
      );

      await _scanHistoryCollection.doc(historyItem.id).set(historyItem);
    } catch (e) {
      AppLogger.error(
        '[ScanHistoryRepository] Error adding to scan history',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets all scan history items for the current user, sorted by most recent.
  Future<List<ScanHistoryModel>> getScanHistory() async {
    try {
      final querySnapshot = await _scanHistoryCollection
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppLogger.error(
        '[ScanHistoryRepository] Error getting scan history',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets recent scan history items (limit to a certain number).
  Future<List<ScanHistoryModel>> getRecentScanHistory({int limit = 5}) async {
    try {
      final querySnapshot = await _scanHistoryCollection
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppLogger.error(
        '[ScanHistoryRepository] Error getting recent scan history',
        error: e,
      );
      rethrow;
    }
  }

  /// Deletes a scan history item.
  Future<void> deleteScanHistoryItem(String id) async {
    try {
      await _scanHistoryCollection.doc(id).delete();
    } catch (e) {
      AppLogger.error(
        '[ScanHistoryRepository] Error deleting scan history item',
        error: e,
      );
      rethrow;
    }
  }

  /// Clears all scan history.
  Future<void> clearScanHistory() async {
    try {
      final querySnapshot = await _scanHistoryCollection.get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      AppLogger.error(
        '[ScanHistoryRepository] Error clearing scan history',
        error: e,
      );
      rethrow;
    }
  }
}
