import 'package:flutter/foundation.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/models/scan_history_model.dart';
import '../../../../data/repositories/scan_history_repository.dart';

/// Provider to manage scan history
class ScanHistoryProvider extends ChangeNotifier {
  ScanHistoryProvider({ScanHistoryRepository? scanHistoryRepository})
      : _scanHistoryRepository = scanHistoryRepository;

  ScanHistoryRepository? _scanHistoryRepository;

  List<ScanHistoryModel> _scanHistory = [];
  bool _isLoading = false;
  String? _error;

  List<ScanHistoryModel> get scanHistory => _scanHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateRepository(ScanHistoryRepository? repository) {
    _scanHistoryRepository = repository;
    if (repository == null) {
      _scanHistory = [];
      _isLoading = false;
      _error = null;
      notifyListeners();
    }
  }

  bool _ensureRepository() {
    if (_scanHistoryRepository != null) return true;
    _error = 'Vui lòng đăng nhập để sử dụng lịch sử quét.';
    notifyListeners();
    return false;
  }

  /// Adds a product to scan history
  Future<void> addToScanHistory(ProductModel product) async {
    if (!_ensureRepository()) return;

    try {
      _error = null;
      await _scanHistoryRepository!.addToScanHistory(product);
      // Refresh the list
      await loadScanHistory();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Loads scan history from the repository
  Future<void> loadScanHistory() async {
    if (!_ensureRepository()) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _scanHistory = await _scanHistoryRepository!.getScanHistory();
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
    if (!_ensureRepository()) return [];

    try {
      return await _scanHistoryRepository!.getRecentScanHistory(limit: limit);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Deletes a scan history item
  Future<void> deleteScanHistoryItem(String id) async {
    if (!_ensureRepository()) return;

    try {
      _error = null;
      await _scanHistoryRepository!.deleteScanHistoryItem(id);
      // Refresh the list
      await loadScanHistory();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Clears all scan history
  Future<void> clearScanHistory() async {
    if (!_ensureRepository()) return;

    try {
      _error = null;
      await _scanHistoryRepository!.clearScanHistory();
      _scanHistory = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
