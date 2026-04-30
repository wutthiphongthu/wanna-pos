import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int? id;
  final int storeId;
  final String productCode;
  final String name;
  final String? productSubname;
  final String description;
  final double price;
  final double cost;
  final int discountType; // 1=Amount, 2=%
  final double discount;
  final int stockQuantity;
  final int minStockLevel;
  final String category;
  final int? categoryId;
  final String? barcode;
  final int barcodeType; // 1=Product code, 2=Custom code
  final String? customBarcodeId;
  final bool hideInEcommerce;
  final bool nonVat;
  final bool unlimitedStock;
  final bool hideInEMenu;
  final String? productLocation;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    this.id,
    this.storeId = 1,
    required this.productCode,
    required this.name,
    this.productSubname,
    required this.description,
    required this.price,
    required this.cost,
    this.discountType = 1,
    this.discount = 0,
    required this.stockQuantity,
    required this.minStockLevel,
    required this.category,
    this.categoryId,
    this.barcode,
    this.barcodeType = 1,
    this.customBarcodeId,
    this.hideInEcommerce = false,
    this.nonVat = false,
    this.unlimitedStock = false,
    this.hideInEMenu = false,
    this.productLocation,
    this.imageUrls = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromEntity(dynamic entity) {
    return ProductModel(
      id: entity.id,
      storeId: entity.storeId ?? 1,
      productCode: entity.productCode,
      name: entity.name,
      productSubname: entity.productSubname,
      description: entity.description,
      price: entity.price,
      cost: entity.cost,
      discountType: entity.discountType,
      discount: entity.discount,
      stockQuantity: entity.stockQuantity,
      minStockLevel: entity.minStockLevel,
      category: entity.category,
      categoryId: entity.categoryId,
      barcode: entity.barcode,
      barcodeType: entity.barcodeType,
      customBarcodeId: entity.customBarcodeId,
      hideInEcommerce: entity.hideInEcommerce,
      nonVat: entity.nonVat,
      unlimitedStock: entity.unlimitedStock,
      hideInEMenu: entity.hideInEMenu,
      productLocation: entity.productLocation,
      imageUrls: entity.imageUrlsList,
      isActive: entity.isActive,
      createdAt: entity.createdAtDateTime,
      updatedAt: entity.updatedAtDateTime,
    );
  }

  ProductModel copyWith({
    int? id,
    int? storeId,
    String? productCode,
    String? name,
    String? productSubname,
    String? description,
    double? price,
    double? cost,
    int? discountType,
    double? discount,
    int? stockQuantity,
    int? minStockLevel,
    String? category,
    int? categoryId,
    String? barcode,
    int? barcodeType,
    String? customBarcodeId,
    bool? hideInEcommerce,
    bool? nonVat,
    bool? unlimitedStock,
    bool? hideInEMenu,
    String? productLocation,
    List<String>? imageUrls,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productCode: productCode ?? this.productCode,
      name: name ?? this.name,
      productSubname: productSubname ?? this.productSubname,
      description: description ?? this.description,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      discountType: discountType ?? this.discountType,
      discount: discount ?? this.discount,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      barcode: barcode ?? this.barcode,
      barcodeType: barcodeType ?? this.barcodeType,
      customBarcodeId: customBarcodeId ?? this.customBarcodeId,
      hideInEcommerce: hideInEcommerce ?? this.hideInEcommerce,
      nonVat: nonVat ?? this.nonVat,
      unlimitedStock: unlimitedStock ?? this.unlimitedStock,
      hideInEMenu: hideInEMenu ?? this.hideInEMenu,
      productLocation: productLocation ?? this.productLocation,
      imageUrls: imageUrls ?? this.imageUrls,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'productCode': productCode,
      'name': name,
      'productSubname': productSubname,
      'description': description,
      'price': price,
      'cost': cost,
      'discountType': discountType,
      'discount': discount,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'category': category,
      'categoryId': categoryId,
      'barcode': barcode,
      'barcodeType': barcodeType,
      'customBarcodeId': customBarcodeId,
      'hideInEcommerce': hideInEcommerce,
      'nonVat': nonVat,
      'unlimitedStock': unlimitedStock,
      'hideInEMenu': hideInEMenu,
      'productLocation': productLocation,
      'imageUrls': imageUrls,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      storeId: json['storeId'] ?? 1,
      productCode: json['productCode'],
      name: json['name'],
      productSubname: json['productSubname'],
      description: json['description'],
      price: json['price'].toDouble(),
      cost: json['cost'].toDouble(),
      discountType: (json['discountType'] ?? 1) is int
          ? (json['discountType'] ?? 1)
          : int.tryParse((json['discountType'] ?? '1').toString()) ?? 1,
      discount: (json['discount'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'],
      minStockLevel: json['minStockLevel'],
      category: json['category'],
      categoryId: json['categoryId'],
      barcode: json['barcode'],
      barcodeType: (json['barcodeType'] ?? 1) is int
          ? (json['barcodeType'] ?? 1)
          : int.tryParse((json['barcodeType'] ?? '1').toString()) ?? 1,
      customBarcodeId: json['customBarcodeId'],
      hideInEcommerce: json['hideInEcommerce'] ?? false,
      nonVat: json['nonVat'] ?? false,
      unlimitedStock: json['unlimitedStock'] ?? false,
      hideInEMenu: json['hideInEMenu'] ?? false,
      productLocation: json['productLocation'],
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'])
          : (json['imageUrl'] != null ? [json['imageUrl']] : []),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        storeId,
        productCode,
        name,
        productSubname,
        description,
        price,
        cost,
        discountType,
        discount,
        stockQuantity,
        minStockLevel,
        category,
        barcode,
        barcodeType,
        customBarcodeId,
        hideInEcommerce,
        nonVat,
        unlimitedStock,
        hideInEMenu,
        productLocation,
        imageUrls,
        isActive,
        createdAt,
        updatedAt,
      ];

  // Helper methods
  bool get isLowStock => stockQuantity <= minStockLevel;
  double get profitMargin => price - cost;
  double get profitMarginPercentage =>
      cost > 0 ? ((price - cost) / cost) * 100 : 0;
}
