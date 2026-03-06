import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:docpocket/src/models/category_model.dart';
import 'package:docpocket/src/models/document_model.dart';
import 'package:docpocket/src/database/database_service.dart';
import 'package:uuid/uuid.dart';

class AppProvider extends ChangeNotifier {
  static final AppProvider instance = AppProvider._internal();
  AppProvider._internal();
  factory AppProvider() => instance;

  Box<CategoryModel> get _categoryBox => DatabaseService.getCategoriesBox();
  Box<DocumentModel> get _documentBox => DatabaseService.getDocumentsBox();

  List<CategoryModel> get categories => _categoryBox.values.toList();
  List<DocumentModel> get documents => _documentBox.values.toList();

  List<DocumentModel> get pinnedDocuments => 
      _documentBox.values.where((doc) => doc.isPinned).toList();

  List<DocumentModel> getDocumentsByCategory(String categoryId) {
    return _documentBox.values.where((doc) => doc.categoryId == categoryId).toList();
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<CategoryModel> get filteredCategories {
    if (_searchQuery.isEmpty) return categories;
    return categories.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  List<DocumentModel> filteredDocuments(String categoryId) {
    final docs = getDocumentsByCategory(categoryId);
    if (_searchQuery.isEmpty) return docs;
    return docs.where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  List<DocumentModel> get filteredGlobalDocuments {
    if (_searchQuery.isEmpty) return [];
    return documents.where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  CategoryModel? getCategoryById(String id) => _categoryBox.get(id);

  Future<void> addCategory(String name) async {
    final category = CategoryModel(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await _categoryBox.put(category.id, category);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    // Delete actual files first to save space
    final docsToDelete = getDocumentsByCategory(id);
    for (var doc in docsToDelete) {
      await deleteDocument(doc.id);
    }
    await _categoryBox.delete(id);
    notifyListeners();
  }

  /// Copies a file from temporary/external storage to the app's permanent storage
  Future<void> addDocument({
    required String categoryId,
    required String name,
    required String sourceFilePath,
    required String fileSize,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final String extension = p.extension(sourceFilePath);
      final String fileName = "${const Uuid().v4()}$extension";
      final String permanentPath = p.join(appDir.path, 'documents', fileName);

      // Create documents directory if not exists
      final docDir = Directory(p.dirname(permanentPath));
      if (!await docDir.exists()) {
        await docDir.create(recursive: true);
      }

      // Copy file to permanent storage
      final File sourceFile = File(sourceFilePath);
      await sourceFile.copy(permanentPath);

      final document = DocumentModel(
        id: const Uuid().v4(),
        categoryId: categoryId,
        name: name,
        filePath: permanentPath, // Save the permanent path
        fileSize: fileSize,
        dateAdded: DateTime.now(),
      );
      await _documentBox.put(document.id, document);
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving document: $e");
    }
  }

  Future<void> togglePin(DocumentModel document) async {
    document.isPinned = !document.isPinned;
    await document.save();
    notifyListeners();
  }

  Future<void> deleteDocument(String id) async {
    final doc = _documentBox.get(id);
    if (doc != null) {
      final file = File(doc.filePath);
      if (await file.exists()) {
        await file.delete(); // Remove the physical file
      }
      await _documentBox.delete(id);
    }
    notifyListeners();
  }

  Future<void> renameDocument(DocumentModel document, String newName) async {
    document.name = newName;
    await document.save();
    notifyListeners();
  }

  Future<void> moveDocument(DocumentModel document, String newCategoryId) async {
    document.categoryId = newCategoryId;
    await document.save();
    notifyListeners();
  }
}
