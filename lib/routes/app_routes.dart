import 'package:flutter/material.dart';

import '../data/models/product_model.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/auth_gate.dart';
import '../features/auth/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/pages/start.dart';
import '../features/product/presentation/pages/product_alternatives_page.dart';
import '../features/product/presentation/pages/product_detail_page.dart';
import '../features/profile/presentation/pages/profile_edit_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/scan/presentation/pages/scan_history_page.dart';
import '../features/scan/presentation/pages/scan_screen.dart';
import '../features/wishlist/presentation/pages/wishlist_page.dart';

class AppRoutes {
  static const String authGate = '/';
  static const String start = '/start';
  static const String home = '/home';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String forgotPassword = '/forgotPassword';
  static const String scan = '/scan';
  static const String productDetail = '/product-detail';
  static const String productAlternatives = '/product-alternatives';
  static const String profile = '/profile';
  static const String profileEdit = '/profile-edit';
  static const String scanHistory = '/scan-history';
  static const String wishlist = '/wishlist';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case start:
        return MaterialPageRoute(builder: (_) => const Start());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case scan:
        return MaterialPageRoute(builder: (_) => const ScanScreen());
      case productDetail:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product),
        );
      case productAlternatives:
        final product = settings.arguments as ProductModel;
        return MaterialPageRoute(
          builder: (_) => ProductAlternativesPage(currentProduct: product),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case profileEdit:
        return MaterialPageRoute(builder: (_) => const ProfileEditPage());
      case scanHistory:
        return MaterialPageRoute(builder: (_) => const ScanHistoryPage());
      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistPage());
    // Default to auth gate if route is not found
      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}

extension Navigation on BuildContext {
  void navigateToStart() => Navigator.of(this).pushReplacementNamed(AppRoutes.start);
  void navigateToLogin() => Navigator.of(this).pushNamed(AppRoutes.login);
  void navigateToSignUp() => Navigator.of(this).pushNamed(AppRoutes.signUp);
  void navigateToForgotPassword() =>
      Navigator.of(this).pushNamed(AppRoutes.forgotPassword);
  void navigateToProductDetail(ProductModel product) =>
      Navigator.of(this).pushNamed(AppRoutes.productDetail, arguments: product);
    void navigateToProductAlternatives(ProductModel product) => Navigator.of(this)
      .pushNamed(AppRoutes.productAlternatives, arguments: product);
  void navigateToHome() => Navigator.of(this).pushNamed(AppRoutes.home);
  void navigateToProfile() => Navigator.of(this).pushNamed(AppRoutes.profile);
  void navigateToProfileEdit() => Navigator.of(this).pushNamed(AppRoutes.profileEdit);
  void navigateToScanHistory() => Navigator.of(this).pushNamed(AppRoutes.scanHistory);
  void navigateToWishlist() => Navigator.of(this).pushNamed(AppRoutes.wishlist);
}
