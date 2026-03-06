import 'package:hive_flutter/hive_flutter.dart';
import 'package:docpocket/src/models/category_model.dart';
import 'package:docpocket/src/models/document_model.dart';

class DatabaseService {
  static const String categoriesBoxName = 'categoriesBox';
  static const String documentsBoxName = 'documentsBox';
  static const String settingsBoxName = 'settingsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DocumentModelAdapter());
    }

    await Hive.openBox<CategoryModel>(categoriesBoxName);
    await Hive.openBox<DocumentModel>(documentsBoxName);
    final settingsBox = await Hive.openBox(settingsBoxName);
    
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
  }

  static Box<CategoryModel> getCategoriesBox() => Hive.box<CategoryModel>(categoriesBoxName);
  static Box<DocumentModel> getDocumentsBox() => Hive.box<DocumentModel>(documentsBoxName);
}
