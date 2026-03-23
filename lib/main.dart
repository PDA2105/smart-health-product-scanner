import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import 'core/config/gemini_config.dart';
import 'core/services/gemini_health_analysis_service.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/scan_history_repository.dart';
import 'data/repositories/wishlist_repository.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/product/presentation/providers/health_analysis_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/scan/presentation/providers/scan_history_provider.dart';
import 'features/wishlist/presentation/providers/wishlist_provider.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set the user agent for the OpenFoodFacts API before running the app
  OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'Smart Health Product Scanner');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- Auth Providers ---
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(AuthRepository(AuthRemoteDataSource()))..init(),
        ),
        // --- Product Providers ---
        Provider<ProductRepository>(
          create: (_) => ProductRepository(
            FirebaseFirestore.instance,
            ProductRemoteDataSource(),
          ),
        ),
        // --- Profile Providers ---
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            ProfileRepository(FirebaseFirestore.instance),
          ),
        ),
        // --- Scan History Provider ---
        ChangeNotifierProxyProvider<AuthProvider, ScanHistoryProvider>(
          create: (_) => ScanHistoryProvider(),
          update: (_, authProvider, scanHistoryProvider) {
            final provider = scanHistoryProvider ?? ScanHistoryProvider();
            final userId = authProvider.user?.uid;

            if (userId == null || userId.isEmpty) {
              provider.updateRepository(null);
              return provider;
            }

            provider.updateRepository(
              ScanHistoryRepository(
                FirebaseFirestore.instance,
                userId,
              ),
            );
            return provider;
          },
        ),
        // --- Wishlist Provider ---
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (_, authProvider, wishlistProvider) {
            final provider = wishlistProvider ?? WishlistProvider();
            final userId = authProvider.user?.uid;

            if (userId == null || userId.isEmpty) {
              provider.updateRepository(null);
              return provider;
            }

            provider.updateRepository(
              WishlistRepository(
                FirebaseFirestore.instance,
                userId,
              ),
            );
            return provider;
          },
        ),
        // --- Gemini Health Analysis Provider ---
        Provider<GeminiHealthAnalysisService>(
          create: (_) => GeminiHealthAnalysisService(
            apiKey: GeminiConfig.apiKey,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => HealthAnalysisProvider(
            geminiService: context.read<GeminiHealthAnalysisService>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Health Product Scanner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        // Use initialRoute with onGenerateRoute, not home
        initialRoute: AppRoutes.start,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
