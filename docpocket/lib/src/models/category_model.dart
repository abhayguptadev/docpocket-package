import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 0)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  int iconCode;

  CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.iconCode = 0xe14f,
  });
}
