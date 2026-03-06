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

  /// Entry point that guarantees the Provider is available to all internal screens.
  static Widget getEntryPoint() {
    return ChangeNotifierProvider.value(
      value: AppProvider.instance,
      child: const DocPocketRouter(),
    );
  }
}

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
    // We use a nested Navigator or a simple switch to keep the Provider in scope
    return WillPopScope(
      onWillPop: () async {
        if (!_showSplash) {
          // If we are on Home and user presses back, we might want to exit the feature
          return true; 
        }
        return false;
      },
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) {
              if (_showSplash) return const SplashScreen();
              return const HomeScreen();
            },
          );
        },
      ),
    );
  }
}
