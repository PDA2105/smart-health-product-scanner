import 'package:flutter/material.dart';

import '../../../../core/services/app_logger.dart';
import '../../../../data/models/health_goal_model.dart';
import '../../../../data/models/health_score_entry_model.dart';
import '../../../../data/models/weight_entry_model.dart';
import '../../../../data/repositories/health_tracking_repository.dart';

/// A provider to manage health tracking state and operations.
class HealthTrackingProvider extends ChangeNotifier {
  HealthTrackingProvider({HealthTrackingRepository? repository})
      : _repository = repository;

  HealthTrackingRepository? _repository;

  // States
  List<WeightEntryModel> _weightHistory = [];
  List<HealthScoreEntryModel> _healthScoreHistory = [];
  List<HealthGoalModel> _activeGoals = [];
  List<HealthGoalModel> _allGoals = [];
  WeightEntryModel? _latestWeightEntry;
  HealthScoreEntryModel? _latestHealthScoreEntry;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<WeightEntryModel> get weightHistory => _weightHistory;
  List<HealthScoreEntryModel> get healthScoreHistory => _healthScoreHistory;
  List<HealthGoalModel> get activeGoals => _activeGoals;
  List<HealthGoalModel> get allGoals => _allGoals;
  WeightEntryModel? get latestWeightEntry => _latestWeightEntry;
  HealthScoreEntryModel? get latestHealthScoreEntry => _latestHealthScoreEntry;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Update the repository reference.
  void updateRepository(HealthTrackingRepository? repository) {
    _repository = repository;
  }

  /// Load all health tracking data.
  Future<void> loadAllData() async {
    if (_repository == null) {
      _error = 'Repository not initialized';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadWeightHistory(),
        _loadHealthScoreHistory(),
        _loadActiveGoals(),
        _loadLatestEntries(),
      ]);
      AppLogger.debug('[HealthTrackingProvider] All data loaded successfully');
    } catch (e) {
      _error = 'Lỗi tải dữ liệu: $e';
      AppLogger.error('[HealthTrackingProvider] Error loading data', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadWeightHistory() async {
    try {
      _weightHistory = await _repository!.getWeightHistory();
    } catch (e) {
      AppLogger.error('[HealthTrackingProvider] Error loading weight history',
          error: e);
      rethrow;
    }
  }

  Future<void> _loadHealthScoreHistory() async {
    try {
      _healthScoreHistory = await _repository!.getHealthScoreHistory();
    } catch (e) {
      AppLogger.error(
          '[HealthTrackingProvider] Error loading health score history',
          error: e);
      rethrow;
    }
  }

  Future<void> _loadActiveGoals() async {
    try {
      _activeGoals = await _repository!.getActiveHealthGoals();
      _allGoals = await _repository!.getAllHealthGoals();
    } catch (e) {
      AppLogger.error('[HealthTrackingProvider] Error loading health goals',
          error: e);
      rethrow;
    }
  }

  Future<void> _loadLatestEntries() async {
    try {
      _latestWeightEntry = await _repository!.getLatestWeightEntry();
      _latestHealthScoreEntry =
          await _repository!.getLatestHealthScoreEntry();
    } catch (e) {
      AppLogger.error(
          '[HealthTrackingProvider] Error loading latest entries',
          error: e);
      rethrow;
    }
  }

  // ==================== WEIGHT TRACKING ====================

  /// Log a new weight entry.
  Future<void> logWeight({
    required double weight,
    required double? currentHeight,
    String? notes,
  }) async {
    if (_repository == null) {
      _error = 'Repository not initialized';
      notifyListeners();
      return;
    }

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      double? bmi;

      if (currentHeight != null && currentHeight > 0) {
        final heightInMeters = currentHeight / 100;
        bmi = weight / (heightInMeters * heightInMeters);
      }

      final entry = WeightEntryModel(
        id: id,
        userId: '', // Will be set by repository
        weight: weight,
        recordedDate: DateTime.now(),
        notes: notes,
        calculatedBMI: bmi,
      );

      await _repository!.saveWeightEntry(entry);
      _weightHistory.insert(0, entry);
      _latestWeightEntry = entry;
      _error = null;

      AppLogger.debug('[HealthTrackingProvider] Weight logged: ${weight}kg');
      
      // Check if any goals are completed
      await _checkGoalCompletion(weight);
      
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi lưu cân nặng: $e';
      AppLogger.error('[HealthTrackingProvider] Error logging weight', error: e);
      notifyListeners();
      rethrow;
    }
  }

  /// Get weight entries for a specific date range.
  Future<List<WeightEntryModel>> getWeightHistoryInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_repository == null) return [];

    try {
      return await _repository!.getWeightHistoryInRange(startDate, endDate);
    } catch (e) {
      AppLogger.error(
          '[HealthTrackingProvider] Error getting weight history in range',
          error: e);
      return [];
    }
  }

  /// Delete a weight entry.
  Future<void> deleteWeightEntry(String entryId) async {
    if (_repository == null) return;

    try {
      await _repository!.deleteWeightEntry(entryId);
      _weightHistory.removeWhere((e) => e.id == entryId);
      AppLogger.debug('[HealthTrackingProvider] Weight entry deleted: $entryId');
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi xóa cân nặng: $e';
      AppLogger.error('[HealthTrackingProvider] Error deleting weight entry',
          error: e);
      notifyListeners();
      rethrow;
    }
  }

  /// Calculate weight progress.
  Future<double?> calculateWeightProgress() async {
    if (_repository == null) return null;

    try {
      return await _repository!.getWeightProgress();
    } catch (e) {
      AppLogger.error(
          '[HealthTrackingProvider] Error calculating weight progress',
          error: e);
      return null;
    }
  }

  // ==================== HEALTH GOALS ====================

  /// Create a new health goal.
  Future<void> createHealthGoal({
    required HealthGoalType goalType,
    required double targetWeight,
    required DateTime targetDate,
    double? startWeight,
    String? notes,
  }) async {
    if (_repository == null) {
      _error = 'Repository not initialized';
      notifyListeners();
      return;
    }

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final goal = HealthGoalModel(
        id: id,
        userId: '', // Will be set by repository
        goalType: goalType,
        targetWeight: targetWeight,
        startDate: DateTime.now(),
        targetDate: targetDate,
        startWeight: startWeight,
        notes: notes,
      );

      await _repository!.saveHealthGoal(goal);
      _activeGoals.add(goal);
      _allGoals.add(goal);
      _error = null;

      AppLogger.debug('[HealthTrackingProvider] Health goal created');
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi tạo mục tiêu: $e';
      AppLogger.error('[HealthTrackingProvider] Error creating health goal',
          error: e);
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing health goal.
  Future<void> updateHealthGoal(HealthGoalModel goal) async {
    if (_repository == null) return;

    try {
      await _repository!.updateHealthGoal(goal);

      final index = _activeGoals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _activeGoals[index] = goal;
      }

      final allIndex = _allGoals.indexWhere((g) => g.id == goal.id);
      if (allIndex != -1) {
        _allGoals[allIndex] = goal;
      }

      AppLogger.debug('[HealthTrackingProvider] Health goal updated: ${goal.id}');
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi cập nhật mục tiêu: $e';
      AppLogger.error('[HealthTrackingProvider] Error updating health goal',
          error: e);
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a health goal.
  Future<void> deleteHealthGoal(String goalId) async {
    if (_repository == null) return;

    try {
      await _repository!.deleteHealthGoal(goalId);
      _activeGoals.removeWhere((g) => g.id == goalId);
      _allGoals.removeWhere((g) => g.id == goalId);

      AppLogger.debug('[HealthTrackingProvider] Health goal deleted: $goalId');
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi xóa mục tiêu: $e';
      AppLogger.error('[HealthTrackingProvider] Error deleting health goal',
          error: e);
      notifyListeners();
      rethrow;
    }
  }

  // ==================== HEALTH SCORE ENTRIES ====================

  /// Save a health score entry.
  Future<void> saveHealthScoreEntry({
    required double averageScore,
    required int scannedProductsCount,
    double totalCalories = 0.0,
    double totalProtein = 0.0,
    double totalFat = 0.0,
    double totalCarbs = 0.0,
  }) async {
    if (_repository == null) return;

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final entry = HealthScoreEntryModel(
        id: id,
        userId: '',
        averageScore: averageScore,
        recordedDate: DateTime.now(),
        scannedProductsCount: scannedProductsCount,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalFat: totalFat,
        totalCarbs: totalCarbs,
      );

      await _repository!.saveHealthScoreEntry(entry);
      _healthScoreHistory.insert(0, entry);
      _latestHealthScoreEntry = entry;

      AppLogger.debug(
          '[HealthTrackingProvider] Health score entry saved: ${averageScore}/10');
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi lưu điểm sức khỏe: $e';
      AppLogger.error(
          '[HealthTrackingProvider] Error saving health score entry',
          error: e);
      notifyListeners();
      rethrow;
    }
  }

  /// Get average health score for a time period.
  Future<double> getAverageHealthScore({required int lastDays}) async {
    if (_repository == null) return 0.0;

    try {
      return await _repository!.getAverageHealthScore(lastDays: lastDays);
    } catch (e) {
      AppLogger.error(
          '[HealthTrackingProvider] Error getting average health score',
          error: e);
      return 0.0;
    }
  }

  // ==================== ANALYTICS ====================

  /// Calculate BMI from weight and height.
  static double calculateBMI(double weightKg, double heightCm) {
    final heightInMeters = heightCm / 100;
    return weightKg / (heightInMeters * heightInMeters);
  }

  /// Get BMI category.
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Gầy';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  /// Get weight trend (ascending or descending).
  bool get isWeightTrendDecreasing {
    if (_weightHistory.length < 2) return false;
    return _weightHistory.first.weight < _weightHistory.last.weight;
  }

  /// Get average health score from latest entries.
  double get averageHealthScoreFromLatestEntries {
    if (_healthScoreHistory.isEmpty) return 0.0;
    final latestWeek = _healthScoreHistory
        .where((e) =>
            e.recordedDate
                .isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();

    if (latestWeek.isEmpty) return 0.0;

    final sum = latestWeek.fold<double>(
      0.0,
      (total, entry) => total + entry.averageScore,
    );

    return sum / latestWeek.length;
  }

  // ==================== GOAL COMPLETION CHECK ====================

  /// Check if any active goals are completed with the current weight.
  Future<void> _checkGoalCompletion(double currentWeight) async {
    if (_repository == null) return;

    for (final goal in _activeGoals) {
      bool isCompleted = false;

      if (goal.goalType == HealthGoalType.losWeight) {
        // Goal completed if current weight <= target weight
        if (currentWeight <= goal.targetWeight) {
          isCompleted = true;
        }
      } else if (goal.goalType == HealthGoalType.gainWeight) {
        // Goal completed if current weight >= target weight
        if (currentWeight >= goal.targetWeight) {
          isCompleted = true;
        }
      } else if (goal.goalType == HealthGoalType.maintainWeight) {
        // Goal completed if weight is within ±2kg of target
        if ((currentWeight - goal.targetWeight).abs() <= 2.0) {
          isCompleted = true;
        }
      }

      if (isCompleted) {
        // Mark goal as inactive
        final updatedGoal = goal.copyWith(
          isActive: false,
          currentProgress: 100,
        );
        await updateHealthGoal(updatedGoal);

        final goalTypeLabel = goal.goalType == HealthGoalType.losWeight
            ? 'Giảm cân'
            : goal.goalType == HealthGoalType.gainWeight
                ? 'Tăng cân'
                : 'Giữ cân';
        _error =
            '✅ Mục tiêu "$goalTypeLabel" đã hoàn tất! Chúc mừng bạn! 🎉';
        AppLogger.debug('[HealthTrackingProvider] Goal completed: ${goal.id}');
        notifyListeners();
      }
    }
  }
}

