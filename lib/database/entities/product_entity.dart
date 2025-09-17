import 'package:floor/floor.dart';

@Entity(tableName: 'products')
class ProductEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String productCode;
  final String name;
  final String description;
  final double price;
  final double cost;
  final int stockQuantity;
  final int minStockLevel;
  final String category;
  final String? barcode;
  final String? imageUrl;
  final bool isActive;
  @ColumnInfo(name: 'created_at')
  final int createdAt;
  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  ProductEntity({
    this.id,
    required this.productCode,
    required this.name,
    required this.description,
    required this.price,
    required this.cost,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.category,
    this.barcode,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert DateTime to int (timestamp) for storage
  factory ProductEntity.fromDateTime({
    int? id,
    required String productCode,
    required String name,
    required String description,
    required double price,
    required double cost,
    required int stockQuantity,
    required int minStockLevel,
    required String category,
    String? barcode,
    String? imageUrl,
    bool isActive = true,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return ProductEntity(
      id: id,
      productCode: productCode,
      name: name,
      description: description,
      price: price,
      cost: cost,
      stockQuantity: stockQuantity,
      minStockLevel: minStockLevel,
      category: category,
      barcode: barcode,
      imageUrl: imageUrl,
      isActive: isActive,
      createdAt: createdAt.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  // Convert int (timestamp) back to DateTime
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);
  DateTime get updatedAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(updatedAt);

  // Copy with method for updates
  ProductEntity copyWith({
    int? id,
    String? productCode,
    String? name,
    String? description,
    double? price,
    double? cost,
    int? stockQuantity,
    int? minStockLevel,
    String? category,
    String? barcode,
    String? imageUrl,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
