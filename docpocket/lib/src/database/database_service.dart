import 'dart:io' show Directory;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:docpocket/src/models/category_model.dart';
import 'package:docpocket/src/models/document_model.dart';

class DatabaseService {
  static const String categoriesBoxName = 'docpocket_categories';
  static const String documentsBoxName = 'docpocket_documents';
  static const String settingsBoxName = 'docpocket_settings';

  static Future<void> init() async {
    try {
      // Senior Fix: Hive.initFlutter handles path_provider internally.
      // Just pass the sub-directory name, NOT the full path.
      await Hive.initFlutter('docpocket_vault');

      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CategoryModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DocumentModelAdapter());
      }

      // Open boxes and wait for them to be ready
      await Hive.openBox<CategoryModel>(categoriesBoxName);
      await Hive.openBox<DocumentModel>(documentsBoxName);
      await Hive.openBox(settingsBoxName);
      
      final settingsBox = Hive.box(settingsBoxName);
      final bool isSeeded = settingsBox.get('is_seeded', defaultValue: false);
      
      if (!isSeeded) {
        final categoryBox = Hive.box<CategoryModel>(categoriesBoxName);
        if (categoryBox.isEmpty) {
          final educationCategory = CategoryModel(
            id: 'default_education',
            name: 'Education',
            createdAt: DateTime.now(),
            iconCode: 0xe092,
          );
          await categoryBox.put(educationCategory.id, educationCategory);
        }
        await settingsBox.put('is_seeded', true);
      }
      
      if (kDebugMode) print("✅ DocPocket: Hive fully ready and persistent");
    } catch (e) {
      if (kDebugMode) print("❌ DocPocket Hive Init Error: $e");
      rethrow;
    }
  }

  static Box<CategoryModel> getCategoriesBox() {
    if (!Hive.isBoxOpen(categoriesBoxName)) {
      throw Exception("DocPocket Error: Categories box is not open.");
    }
    return Hive.box<CategoryModel>(categoriesBoxName);
  }

  static Box<DocumentModel> getDocumentsBox() {
    if (!Hive.isBoxOpen(documentsBoxName)) {
      throw Exception("DocPocket Error: Documents box is not open.");
    }
    return Hive.box<DocumentModel>(documentsBoxName);
  }
}
