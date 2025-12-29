import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';

class AppRoutes {
  AppRoutes._();

  // Route names
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpPage(),
          settings: settings,
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }
}

// Navigation helper extension
extension AppRoutesExtension on BuildContext {
  void navigateToLogin() {
    Navigator.of(this).pushReplacementNamed(AppRoutes.login);
  }

  void navigateToSignUp() {
    Navigator.of(this).pushReplacementNamed(AppRoutes.signUp);
  }

  void navigateToForgotPassword() {
    Navigator.of(this).pushNamed(AppRoutes.forgotPassword);
  }

  void navigateToHome() {
    Navigator.of(this).pushReplacementNamed(AppRoutes.home);
  }

  void navigateBack() {
    Navigator.of(this).pop();
  }
}

