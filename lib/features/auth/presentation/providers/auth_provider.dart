import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/models/app_user.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  StreamSubscription<AppUser?>? _userSub;
  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;

  void init() {
    _userSub?.cancel();
    _userSub = _authRepository.watchUser().listen((event) {
      _user = event;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String password) async {
    await _run(
      () => _authRepository.signUp(email: email, password: password),
    );
  }

  Future<void> signIn(String email, String password) async {
    await _run(
      () => _authRepository.signIn(email: email, password: password),
    );
  }

  Future<void> signInWithGoogle() async {
    await _run(_authRepository.signInWithGoogle);
  }

  Future<void> signOut() async {
    await _run(_authRepository.signOut);
  }

  Future<void> resetPassword(String email) async {
    await _run(() => _authRepository.resetPassword(email: email));
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      return await _authRepository.checkEmailExists(email: email);
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  Future<T?> _run<T>(Future<T> Function() action) async {
    try {
      _error = null;
      _loading = true;
      notifyListeners();
      return await action();
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi từ Firebase Auth
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email này chưa được đăng ký trong hệ thống.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        case 'user-disabled':
          message = 'Tài khoản này đã bị vô hiệu hóa.';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
          break;
        default:
          message = e.message ?? 'Có lỗi xảy ra. Vui lòng thử lại.';
      }
      _error = message;
      return null;
    } catch (e) {
      // Xử lý các lỗi khác
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      _error = errorMessage;
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

