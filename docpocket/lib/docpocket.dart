library docpocket;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:docpocket/src/database/database_service.dart';
import 'package:docpocket/src/services/app_provider.dart';
import 'package:docpocket/src/screens/splash_screen.dart';
import 'package:docpocket/src/screens/home_screen.dart';

export 'src/docpocket_feature.dart';
export 'src/models/category_model.dart';
export 'src/models/document_model.dart';
export 'src/services/app_provider.dart';
export 'src/screens/home_screen.dart';
export 'src/screens/category_screen.dart';
export 'src/screens/splash_screen.dart';

class DocPocketFeature {
  static Future<void> init() async {
    await DatabaseService.init();
  }

  static Widget getEntryPoint() {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const DocPocketRouter(),
    );
  }
}

/// Internal Router to handle transitions without losing the Provider
class DocPocketRouter extends StatefulWidget {
  const DocPocketRouter({super.key});

  @override
  State<DocPocketRouter> createState() => _DocPocketRouterState();
}

class _DocPocketRouterState extends State<DocPocketRouter> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _hideSplash();
  }

  void _hideSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }
    return const HomeScreen();
  }
}
