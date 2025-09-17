import 'package:floor/floor.dart';

@entity
class CategoryEntity {
  @primaryKey
  final int? id;

  final String name;
  final String description;
  final String? iconName;
  final String? color;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  CategoryEntity({
    this.id,
    required this.name,
    required this.description,
    this.iconName,
    this.color,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert from CategoryModel
  factory CategoryEntity.fromModel(dynamic model) {
    return CategoryEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      iconName: model.iconName,
      color: model.color,
      isActive: model.isActive,
      createdAt: model.createdAt.millisecondsSinceEpoch,
      updatedAt: model.updatedAt.millisecondsSinceEpoch,
    );
  }

  // Convert to Map for CategoryModel
  Map<String, dynamic> toModelMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'color': color,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
