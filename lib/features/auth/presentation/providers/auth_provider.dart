import 'dart:async';

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
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

