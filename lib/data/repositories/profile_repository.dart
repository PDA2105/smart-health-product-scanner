import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/app_logger.dart';
import '../models/health_profile.dart';

/// Repository to handle health profile operations.
class ProfileRepository {
  ProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// A reference to the 'healthProfiles' collection in Firestore with a converter.
  CollectionReference<HealthProfile> get _profilesCollection =>
      _firestore.collection('healthProfiles').withConverter<HealthProfile>(
            fromFirestore: (snapshots, _) =>
                HealthProfile.fromMap(snapshots.data()!),
            toFirestore: (profile, _) => profile.toMap(),
          );

  /// Gets a health profile by user ID.
  Future<HealthProfile?> getProfileByUserId(String userId) async {
    try {
      final docSnapshot = await _profilesCollection.doc(userId).get();
      return docSnapshot.data();
    } catch (e) {
      AppLogger.error(
        '[ProfileRepository] Error getting health profile for user $userId',
        error: e,
      );
      rethrow;
    }
  }

  /// Saves or updates a health profile for a user.
  Future<void> saveProfile(HealthProfile profile) async {
    try {
      await _profilesCollection.doc(profile.userId).set(profile);
    } catch (e) {
      AppLogger.error(
        '[ProfileRepository] Error saving health profile',
        error: e,
      );
      rethrow;
    }
  }

  /// Deletes a health profile for a user.
  Future<void> deleteProfile(String userId) async {
    try {
      await _profilesCollection.doc(userId).delete();
    } catch (e) {
      AppLogger.error(
        '[ProfileRepository] Error deleting health profile',
        error: e,
      );
      rethrow;
    }
  }

  /// Stream of health profile updates for a user.
  Stream<HealthProfile?> watchProfile(String userId) {
    return _profilesCollection.doc(userId).snapshots().map((snapshot) {
      return snapshot.data();
    });
  }
}
