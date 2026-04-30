import 'package:floor/floor.dart';

@Entity(tableName: 'stores')
class StoreEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String name;
  final String? address;
  final String? phone;
  @ColumnInfo(name: 'is_active')
  final bool isActive;
  @ColumnInfo(name: 'created_at')
  final int createdAt;
  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  StoreEntity({
    this.id,
    required this.name,
    this.address,
    this.phone,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });
}
