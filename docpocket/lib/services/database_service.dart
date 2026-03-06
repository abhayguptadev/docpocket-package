import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/document_model.dart';

class DatabaseService {
  static const String categoriesBoxName = 'categoriesBox';
  static const String documentsBoxName = 'documentsBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DocumentModelAdapter());
    }

    await Hive.openBox<CategoryModel>(categoriesBoxName);
    await Hive.openBox<DocumentModel>(documentsBoxName);
    
    // Seed default categories if empty
    final categoryBox = Hive.box<CategoryModel>(categoriesBoxName);
    if (categoryBox.isEmpty) {
      final defaultCategories = [
        CategoryModel(id: '1', name: 'ID & Personal', createdAt: DateTime.now(), iconCode: 0xe092),
        CategoryModel(id: '2', name: 'Finance', createdAt: DateTime.now(), iconCode: 0xef63),
        CategoryModel(id: '3', name: 'Health', createdAt: DateTime.now(), iconCode: 0xe306),
        CategoryModel(id: '4', name: 'Taxes', createdAt: DateTime.now(), iconCode: 0xf05ec),
        CategoryModel(id: '5', name: 'Work', createdAt: DateTime.now(), iconCode: 0xe11c),
        CategoryModel(id: '6', name: 'Other', createdAt: DateTime.now(), iconCode: 0xe2a3),
      ];
      for (var cat in defaultCategories) {
        await categoryBox.put(cat.id, cat);
      }
    }
  }

  static Box<CategoryModel> getCategoriesBox() => Hive.box<CategoryModel>(categoriesBoxName);
  static Box<DocumentModel> getDocumentsBox() => Hive.box<DocumentModel>(documentsBoxName);
}
