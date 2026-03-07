library docpocket;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docpocket/src/database/database_service.dart';
import 'package:docpocket/src/services/app_provider.dart';
import 'package:docpocket/src/screens/home_screen.dart';

// Publicly exporting models and services for the host app
export 'package:docpocket/src/models/category_model.dart';
export 'package:docpocket/src/models/document_model.dart';
export 'package:docpocket/src/services/app_provider.dart';
export 'package:docpocket/src/screens/home_screen.dart';
export 'package:docpocket/src/screens/category_screen.dart';

/// The main controller for the DocPocket feature package.
class DocPocketFeature {
  /// Initializes Hive database and registers all necessary adapters.
  /// This MUST be called in your main app's main() function and awaited.
  static Future<void> init() async {
    await DatabaseService.init();
  }

  /// Returns the entry point widget for the DocPocket UI.
  /// It automatically injects the necessary [AppProvider] singleton.
  static Widget getEntryPoint() {
    return ChangeNotifierProvider.value(
      value: AppProvider.instance,
      child: const HomeScreen(),
    );
  }
}
