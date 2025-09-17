import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
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
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
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

  factory ProductModel.fromEntity(dynamic entity) {
    return ProductModel(
      id: entity.id,
      productCode: entity.productCode,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      cost: entity.cost,
      stockQuantity: entity.stockQuantity,
      minStockLevel: entity.minStockLevel,
      category: entity.category,
      barcode: entity.barcode,
      imageUrl: entity.imageUrl,
      isActive: entity.isActive,
      createdAt: entity.createdAtDateTime,
      updatedAt: entity.updatedAtDateTime,
    );
  }

  ProductModel copyWith({
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productCode': productCode,
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'category': category,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      productCode: json['productCode'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      cost: json['cost'].toDouble(),
      stockQuantity: json['stockQuantity'],
      minStockLevel: json['minStockLevel'],
      category: json['category'],
      barcode: json['barcode'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        productCode,
        name,
        description,
        price,
        cost,
        stockQuantity,
        minStockLevel,
        category,
        barcode,
        imageUrl,
        isActive,
        createdAt,
        updatedAt,
      ];

  // Helper methods
  bool get isLowStock => stockQuantity <= minStockLevel;
  double get profitMargin => price - cost;
  double get profitMarginPercentage => cost > 0 ? ((price - cost) / cost) * 100 : 0;
}
