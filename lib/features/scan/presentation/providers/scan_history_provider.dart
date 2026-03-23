import 'package:flutter/foundation.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/models/scan_history_model.dart';
import '../../../../data/repositories/scan_history_repository.dart';

/// Provider to manage scan history
class ScanHistoryProvider extends ChangeNotifier {
  ScanHistoryProvider({required ScanHistoryRepository scanHistoryRepository})
      : _scanHistoryRepository = scanHistoryRepository;

  final ScanHistoryRepository _scanHistoryRepository;

  List<ScanHistoryModel> _scanHistory = [];
  bool _isLoading = false;
  String? _error;

  List<ScanHistoryModel> get scanHistory => _scanHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Adds a product to scan history
  Future<void> addToScanHistory(ProductModel product) async {
    try {
      _error = null;
      await _scanHistoryRepository.addToScanHistory(product);
      // Refresh the list
      await loadScanHistory();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Loads scan history from the repository
  Future<void> loadScanHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _scanHistory = await _scanHistoryRepository.getScanHistory();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets recent scan history
  Future<List<ScanHistoryModel>> getRecentScanHistory({int limit = 5}) async {
    try {
      return await _scanHistoryRepository.getRecentScanHistory(limit: limit);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Deletes a scan history item
  Future<void> deleteScanHistoryItem(String id) async {
    try {
      _error = null;
      await _scanHistoryRepository.deleteScanHistoryItem(id);
      // Refresh the list
      await loadScanHistory();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clears all scan history
  Future<void> clearScanHistory() async {
    try {
      _error = null;
      await _scanHistoryRepository.clearScanHistory();
      _scanHistory = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
