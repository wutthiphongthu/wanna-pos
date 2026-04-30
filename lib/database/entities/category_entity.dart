import 'package:floor/floor.dart';

@Entity(tableName: 'CategoryEntity')
class CategoryEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'store_id')
  final int storeId;
  final String name;
  final String description;
  final String? iconName;
  final String? color;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  @ColumnInfo(name: 'remote_id')
  final String? remoteId;

  @ColumnInfo(name: 'sync_status')
  final int syncStatus;

  CategoryEntity({
    this.id,
    this.storeId = 1,
    required this.name,
    required this.description,
    this.iconName,
    this.color,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.syncStatus = 0,
  });

  // Convert from CategoryModel ([syncStatus] 1 = dirty สำหรับ offline-first)
  factory CategoryEntity.fromModel(dynamic model, {int syncStatus = 0}) {
    return CategoryEntity(
      id: model.id,
      storeId: model.storeId ?? 1,
      name: model.name,
      description: model.description,
      iconName: model.iconName,
      color: model.color,
      isActive: model.isActive,
      createdAt: model.createdAt.millisecondsSinceEpoch,
      updatedAt: model.updatedAt.millisecondsSinceEpoch,
      remoteId: null,
      syncStatus: syncStatus,
    );
  }

  CategoryEntity copyWith({
    int? id,
    int? storeId,
    String? name,
    String? description,
    String? iconName,
    String? color,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
    String? remoteId,
    int? syncStatus,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  // Convert to Map for CategoryModel
  Map<String, dynamic> toModelMap() {
    return {
      'id': id,
      'storeId': storeId,
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
