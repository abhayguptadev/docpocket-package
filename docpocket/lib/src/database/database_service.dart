import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:docpocket/src/models/category_model.dart';
import 'package:docpocket/src/models/document_model.dart';

class DatabaseService {
  static const String categoriesBoxName = 'docpocket_categories';
  static const String documentsBoxName = 'docpocket_documents';
  static const String settingsBoxName = 'docpocket_settings';

  static Future<void> init() async {
    try {
      // 1. Get Directory
      final appDocumentDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDocumentDir.path, 'docpocket_vault');
      
      // 2. Initialize Hive with Path
      await Hive.initFlutter(dbPath);
      if (kDebugMode) {
        print("📁 DocPocket Hive initialized at: $dbPath");
      }

      // 3. Register Adapters FIRST
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CategoryModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DocumentModelAdapter());
      }

      // 4. Open Boxes
      await Hive.openBox<CategoryModel>(categoriesBoxName);
      await Hive.openBox<DocumentModel>(documentsBoxName);
      final settingsBox = await Hive.openBox(settingsBoxName);
      
      // 5. Smart Seeding
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
          if (kDebugMode) print("🌱 DocPocket: Default Category Seeded");
        }
        await settingsBox.put('is_seeded', true);
      }
    } catch (e) {
      if (kDebugMode) print("❌ DocPocket Hive Init Error: $e");
    }
  }

  static Box<CategoryModel> getCategoriesBox() => Hive.box<CategoryModel>(categoriesBoxName);
  static Box<DocumentModel> getDocumentsBox() => Hive.box<DocumentModel>(documentsBoxName);
}
