import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 1)
class DocumentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String filePath;

  @HiveField(4)
  String fileSize;

  @HiveField(5)
  final DateTime dateAdded;

  @HiveField(6)
  bool isPinned;

  DocumentModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.filePath,
    required this.fileSize,
    required this.dateAdded,
    this.isPinned = false,
  });
}
