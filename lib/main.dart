import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_config/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'screens/common/splash_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Note: $e');
  }

  runApp(const HarvestHubApp());
}

class HarvestHubApp extends StatelessWidget {
  const HarvestHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      // SplashScreen handles auth-state routing internally.
      // It always runs first (SRS requirement), then navigates to
      // LoginScreen or the appropriate role dashboard.
      child: MaterialApp(
        title: 'HarvestHub - Marketplace for Local Farm Products',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
