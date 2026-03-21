import 'package:flutter/foundation.dart';

import '/data/models/health_profile.dart';
import '/data/repositories/profile_repository.dart';

/// Provider to manage health profile state
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;

  HealthProfile? _profile;
  bool _isLoading = false;
  String? _error;

  HealthProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads the health profile for a user
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfileByUserId(userId);
    } catch (e) {
      _error = 'Không thể tải hồ sơ sức khỏe: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves or updates the health profile
  Future<bool> saveProfile(HealthProfile profile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.saveProfile(profile);
      _profile = profile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Không thể lưu hồ sơ sức khỏe: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print(_error);
      return false;
    }
  }

  /// Deletes the health profile
  Future<bool> deleteProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteProfile(userId);
      _profile = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Không thể xóa hồ sơ sức khỏe: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      print(_error);
      return false;
    }
  }

  /// Clears the current profile (e.g., on logout)
  void clearProfile() {
    _profile = null;
    _error = null;
    notifyListeners();
  }

  /// Updates specific fields without full reload
  void updateProfile(HealthProfile profile) {
    _profile = profile;
    notifyListeners();
  }
}
