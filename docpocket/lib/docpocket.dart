library docpocket;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docpocket/src/database/database_service.dart';
import 'package:docpocket/src/services/app_provider.dart';
import 'package:docpocket/src/screens/home_screen.dart';


export 'src/models/category_model.dart';
export 'src/models/document_model.dart';
export 'src/services/app_provider.dart';
export 'src/screens/home_screen.dart';
export 'src/screens/category_screen.dart';

class DocPocketFeature {
  /// 1. Call this in main() before runApp()
  static Future<void> init() async {
    await DatabaseService.init();
  }

  /// 2. Call this to open the feature UI
  static Widget getEntryPoint() {
    return ChangeNotifierProvider.value(
      value: AppProvider.instance,
      child: const HomeScreen(),
    );
  }
}
