import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/app_logger.dart';
import '../models/health_goal_model.dart';
import '../models/health_score_entry_model.dart';
import '../models/weight_entry_model.dart';

/// A repository to handle health tracking operations.
class HealthTrackingRepository {
  HealthTrackingRepository(this._firestore, this._userId);

  final FirebaseFirestore _firestore;
  final String _userId;

  /// Reference to the weight entries subcollection for the current user.
  CollectionReference<WeightEntryModel> get _weightEntriesCollection =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('weightEntries')
          .withConverter<WeightEntryModel>(
            fromFirestore: (snapshots, _) =>
                WeightEntryModel.fromMap(snapshots.data()!),
            toFirestore: (item, _) => item.toMap(),
          );

  /// Reference to the health score entries subcollection for the current user.
  CollectionReference<HealthScoreEntryModel> get _healthScoreEntriesCollection =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('healthScoreEntries')
          .withConverter<HealthScoreEntryModel>(
            fromFirestore: (snapshots, _) =>
                HealthScoreEntryModel.fromMap(snapshots.data()!),
            toFirestore: (item, _) => item.toMap(),
          );

  /// Reference to the health goals subcollection for the current user.
  CollectionReference<HealthGoalModel> get _healthGoalsCollection =>
      _firestore
          .collection('users')
          .doc(_userId)
          .collection('healthGoals')
          .withConverter<HealthGoalModel>(
            fromFirestore: (snapshots, _) =>
                HealthGoalModel.fromMap(snapshots.data()!),
            toFirestore: (item, _) => item.toMap(),
          );

  // ==================== WEIGHT ENTRIES ====================

  /// Saves a weight entry to Firestore.
  Future<void> saveWeightEntry(WeightEntryModel entry) async {
    try {
      await _weightEntriesCollection.doc(entry.id).set(entry);
      AppLogger.debug('[HealthTrackingRepository] Weight entry saved: ${entry.weight}kg');
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error saving weight entry',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets all weight entries for the current user, sorted by date (descending).
  Future<List<WeightEntryModel>> getWeightHistory() async {
    try {
      final querySnapshot = await _weightEntriesCollection
          .orderBy('recordedDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error getting weight history',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets weight entries within a date range.
  Future<List<WeightEntryModel>> getWeightHistoryInRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _weightEntriesCollection
          .orderBy('recordedDate', descending: true)
          .get();

      final filtered = querySnapshot.docs
          .map((doc) => doc.data())
          .where((entry) =>
              entry.recordedDate.isAfter(startDate) &&
              entry.recordedDate.isBefore(endDate.add(Duration(days: 1))))
          .toList();

      return filtered;
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error getting weight history in range',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets the latest weight entry.
  Future<WeightEntryModel?> getLatestWeightEntry() async {
    try {
      final querySnapshot = await _weightEntriesCollection
          .orderBy('recordedDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return querySnapshot.docs.first.data();
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error getting latest weight entry',
        error: e,
      );
      rethrow;
    }
  }

  /// Deletes a weight entry.
  Future<void> deleteWeightEntry(String entryId) async {
    try {
      await _weightEntriesCollection.doc(entryId).delete();
      AppLogger.debug('[HealthTrackingRepository] Weight entry deleted: $entryId');
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error deleting weight entry',
        error: e,
      );
      rethrow;
    }
  }

  // ==================== HEALTH SCORE ENTRIES ====================

  /// Saves a health score entry to Firestore.
  Future<void> saveHealthScoreEntry(HealthScoreEntryModel entry) async {
    try {
      await _healthScoreEntriesCollection.doc(entry.id).set(entry);
      AppLogger.debug(
          '[HealthTrackingRepository] Health score entry saved: ${entry.averageScore}/10');
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error saving health score entry',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets all health score entries for the current user, sorted by date (descending).
  Future<List<HealthScoreEntryModel>> getHealthScoreHistory() async {
    try {
      final querySnapshot = await _healthScoreEntriesCollection
          .orderBy('recordedDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error getting health score history',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets health score entries within a date range.
  Future<List<HealthScoreEntryModel>> getHealthScoreHistoryInRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _healthScoreEntriesCollection
          .orderBy('recordedDate', descending: true)
          .get();

      final filtered = querySnapshot.docs
          .map((doc) => doc.data())
          .where((entry) =>
              entry.recordedDate.isAfter(startDate) &&
              entry.recordedDate.isBefore(endDate.add(Duration(days: 1))))
          .toList();

      return filtered;
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error getting health score history in range',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets the latest health score entry.
  Future<HealthScoreEntryModel?> getLatestHealthScoreEntry() async {
    try {
      final querySnapshot = await _healthScoreEntriesCollection
          .orderBy('recordedDate', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;
      return querySnapshot.docs.first.data();
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error getting latest health score entry',
        error: e,
      );
      rethrow;
    }
  }

  // ==================== HEALTH GOALS ====================

  /// Saves a health goal to Firestore.
  Future<void> saveHealthGoal(HealthGoalModel goal) async {
    try {
      await _healthGoalsCollection.doc(goal.id).set(goal);
      AppLogger.debug('[HealthTrackingRepository] Health goal saved: ${goal.targetWeight}kg');
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error saving health goal',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets all active health goals for the current user.
  Future<List<HealthGoalModel>> getActiveHealthGoals() async {
    try {
      final querySnapshot = await _healthGoalsCollection
          .orderBy('targetDate', descending: false)
          .get();

      final active = querySnapshot.docs
          .map((doc) => doc.data())
          .where((goal) => goal.isActive)
          .toList();

      return active;
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error getting active health goals',
        error: e,
      );
      rethrow;
    }
  }

  /// Gets all health goals (active and inactive).
  Future<List<HealthGoalModel>> getAllHealthGoals() async {
    try {
      final querySnapshot = await _healthGoalsCollection
          .orderBy('targetDate', descending: false)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error getting all health goals',
        error: e,
      );
      rethrow;
    }
  }

  /// Updates a health goal.
  Future<void> updateHealthGoal(HealthGoalModel goal) async {
    try {
      await _healthGoalsCollection.doc(goal.id).update(goal.toMap());
      AppLogger.debug('[HealthTrackingRepository] Health goal updated: ${goal.id}');
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error updating health goal',
        error: e,
      );
      rethrow;
    }
  }

  /// Deletes a health goal.
  Future<void> deleteHealthGoal(String goalId) async {
    try {
      await _healthGoalsCollection.doc(goalId).delete();
      AppLogger.debug('[HealthTrackingRepository] Health goal deleted: $goalId');
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error deleting health goal',
        error: e,
      );
      rethrow;
    }
  }

  // ==================== ANALYTICS ====================

  /// Gets weight progress (difference between start and now).
  Future<double?> getWeightProgress() async {
    try {
      final entries = await getWeightHistory();
      if (entries.length < 2) return null;

      final latest = entries.first.weight;
      final oldest = entries.last.weight;
      return latest - oldest; // Negative = weight loss, Positive = weight gain
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error calculating weight progress',
        error: e,
      );
      return null;
    }
  }

  /// Gets average health score for a time period
  Future<double> getAverageHealthScore({required int lastDays}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: lastDays));
      final endDate = DateTime.now();
      final entries = await getHealthScoreHistoryInRange(startDate, endDate);

      if (entries.isEmpty) return 0.0;

      final totalScore = entries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.averageScore,
      );

      return totalScore / entries.length;
    } catch (e) {
      AppLogger.error(
        '[HealthTrackingRepository] Error calculating average health score',
        error: e,
      );
      return 0.0;
    }
  }
}
