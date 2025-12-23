import '../datasources/auth_remote_datasource.dart';
import '../models/app_user.dart';

class AuthRepository {
  AuthRepository(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  Stream<AppUser?> watchUser() {
    return _remoteDataSource.authStateChanges().map(
          (user) => user == null ? null : AppUser.fromFirebaseUser(user),
        );
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Không thể tạo tài khoản. Vui lòng thử lại.');
    }
    return AppUser.fromFirebaseUser(user);
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw Exception('Không thể đăng nhập. Vui lòng thử lại.');
    }
    return AppUser.fromFirebaseUser(user);
  }

  Future<AppUser> signInWithGoogle() async {
    final credential = await _remoteDataSource.signInWithGoogle();
    final user = credential.user;
    if (user == null) {
      throw Exception('Không thể đăng nhập Google. Vui lòng thử lại.');
    }
    return AppUser.fromFirebaseUser(user);
  }

  Future<void> signOut() => _remoteDataSource.signOut();
}

