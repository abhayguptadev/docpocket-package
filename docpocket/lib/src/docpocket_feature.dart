import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_service.dart';
import '../services/app_provider.dart';
import '../screens/splash_screen.dart';

class DocPocketFeature {
  /// Initialize Hive and dependencies for the package.
  /// Call this in your main app's main() before runApp().
  static Future<void> init() async {
    await DatabaseService.init();
  }

  /// Use this widget as the starting point of the DocPocket feature.
  /// It provides the necessary [AppProvider] internally.
  static Widget getEntryPoint() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const SplashScreen(),
    );
  }
}
