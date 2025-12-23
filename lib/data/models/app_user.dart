class AppUser {
  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  factory AppUser.fromFirebaseUser(dynamic user) {
    // Using dynamic to keep the model decoupled from firebase_auth in callers.
    return AppUser(
      uid: user.uid as String,
      email: user.email as String?,
      displayName: user.displayName as String?,
      photoUrl: user.photoURL as String?,
    );
  }
}

