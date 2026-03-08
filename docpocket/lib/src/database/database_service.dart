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
      await Hive.initFlutter('docpocket_vault');

      // 2. Register Adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CategoryModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DocumentModelAdapter());
      }

      // 3. Open Boxes Safely (Check if already open to avoid "Already Open" error)
      if (!Hive.isBoxOpen(categoriesBoxName)) {
        await Hive.openBox<CategoryModel>(categoriesBoxName);
      }
      if (!Hive.isBoxOpen(documentsBoxName)) {
        await Hive.openBox<DocumentModel>(documentsBoxName);
      }
      if (!Hive.isBoxOpen(settingsBoxName)) {
        await Hive.openBox(settingsBoxName);
      }
      
      // 4. Handle default seeding logic
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
      
      if (kDebugMode) print("✅ DocPocket: Database initialized correctly");
    } catch (e) {
      if (kDebugMode) print("❌ DocPocket Hive Init Error: $e");
      // Don't rethrow unless critical, allow app to attempt recovery
    }
  }

  static Box<CategoryModel> getCategoriesBox() {
    return Hive.box<CategoryModel>(categoriesBoxName);
  }

  static Box<DocumentModel> getDocumentsBox() {
    return Hive.box<DocumentModel>(documentsBoxName);
  }
}
