import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/pages/start.dart';
import '../features/scan/presentation/pages/scan_screen.dart';

class AppRoutes {
  static const String start = '/start';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String forgotPassword = '/forgotPassword';
  static const String scan = '/scan';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case start:
        return MaterialPageRoute(builder: (_) => const Start());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());
      // Default to start page if route is not found
      default:
        return MaterialPageRoute(builder: (_) => const Start());
    }
  }
}

extension Navigation on BuildContext {
  void navigateToStart() => Navigator.of(this).pushReplacementNamed(AppRoutes.start);
  void navigateToLogin() => Navigator.of(this).pushNamed(AppRoutes.login);
  void navigateToSignUp() => Navigator.of(this).pushNamed(AppRoutes.signUp);
  void navigateToForgotPassword() =>
      Navigator.of(this).pushNamed(AppRoutes.forgotPassword);
  // Updated to navigate to the Scan screen as the main screen
  void navigateToHome() => Navigator.of(this).pushReplacementNamed(AppRoutes.scan);
}
