import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_model.dart';
import '../models/document_model.dart';

class DatabaseService {
  static const String categoriesBoxName = 'categoriesBox';
  static const String documentsBoxName = 'documentsBox';

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

    // Default categories seeding removed as per request.
  }

  static Box<CategoryModel> getCategoriesBox() => Hive.box<CategoryModel>(categoriesBoxName);
  static Box<DocumentModel> getDocumentsBox() => Hive.box<DocumentModel>(documentsBoxName);
}
