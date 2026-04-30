import 'dart:convert';
import 'package:floor/floor.dart';

@Entity(tableName: 'products')
class ProductEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'store_id')
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
  final String? imageUrls; // JSON string of List<String>
  final bool isActive;
  @ColumnInfo(name: 'created_at')
  final int createdAt;
  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  /// Firestore document id (ถ้าซิงก์แล้ว)
  @ColumnInfo(name: 'remote_id')
  final String? remoteId;

  /// 0=clean, 1=dirty (รอ push), 2=pending_delete
  @ColumnInfo(name: 'sync_status')
  final int syncStatus;

  ProductEntity({
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
    this.imageUrls,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.syncStatus = 0,
  });

  // Convert DateTime to int (timestamp) for storage
  factory ProductEntity.fromDateTime({
    int? id,
    int storeId = 1,
    required String productCode,
    required String name,
    String? productSubname,
    required String description,
    required double price,
    required double cost,
    int discountType = 1,
    double discount = 0,
    required int stockQuantity,
    required int minStockLevel,
    required String category,
    int? categoryId,
    String? barcode,
    int barcodeType = 1,
    String? customBarcodeId,
    bool hideInEcommerce = false,
    bool nonVat = false,
    bool unlimitedStock = false,
    bool hideInEMenu = false,
    String? productLocation,
    List<String>? imageUrls,
    bool isActive = true,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? remoteId,
    int syncStatus = 1,
  }) {
    return ProductEntity(
      id: id,
      storeId: storeId,
      productCode: productCode,
      name: name,
      productSubname: productSubname,
      description: description,
      price: price,
      cost: cost,
      discountType: discountType,
      discount: discount,
      stockQuantity: stockQuantity,
      minStockLevel: minStockLevel,
      category: category,
      categoryId: categoryId,
      barcode: barcode,
      barcodeType: barcodeType,
      customBarcodeId: customBarcodeId,
      hideInEcommerce: hideInEcommerce,
      nonVat: nonVat,
      unlimitedStock: unlimitedStock,
      hideInEMenu: hideInEMenu,
      productLocation: productLocation,
      imageUrls: imageUrls != null && imageUrls.isNotEmpty
          ? jsonEncode(imageUrls)
          : null,
      isActive: isActive,
      createdAt: createdAt.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
      remoteId: remoteId,
      syncStatus: syncStatus,
    );
  }

  // Convert from ProductModel
  factory ProductEntity.fromModel(dynamic model) {
    return ProductEntity(
      id: model.id,
      storeId: model.storeId ?? 1,
      productCode: model.productCode,
      name: model.name,
      productSubname: model.productSubname,
      description: model.description,
      price: model.price,
      cost: model.cost,
      discountType: model.discountType,
      discount: model.discount,
      stockQuantity: model.stockQuantity,
      minStockLevel: model.minStockLevel,
      category: model.category,
      barcode: model.barcode,
      barcodeType: model.barcodeType,
      customBarcodeId: model.customBarcodeId,
      hideInEcommerce: model.hideInEcommerce,
      nonVat: model.nonVat,
      unlimitedStock: model.unlimitedStock,
      hideInEMenu: model.hideInEMenu,
      productLocation: model.productLocation,
      imageUrls:
          model.imageUrls.isNotEmpty ? jsonEncode(model.imageUrls) : null,
      isActive: model.isActive,
      createdAt: model.createdAt.millisecondsSinceEpoch,
      updatedAt: model.updatedAt.millisecondsSinceEpoch,
      remoteId: null,
      syncStatus: 0,
    );
  }

  // Convert int (timestamp) back to DateTime
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);
  DateTime get updatedAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(updatedAt);

  // Convert imageUrls JSON string back to List<String>
  List<String> get imageUrlsList {
    if (imageUrls == null || imageUrls!.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(imageUrls!));
    } catch (e) {
      return [];
    }
  }

  // Convert to Map for ProductModel
  Map<String, dynamic> toModelMap() {
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
      'barcode': barcode,
      'barcodeType': barcodeType,
      'customBarcodeId': customBarcodeId,
      'hideInEcommerce': hideInEcommerce,
      'nonVat': nonVat,
      'unlimitedStock': unlimitedStock,
      'hideInEMenu': hideInEMenu,
      'productLocation': productLocation,
      'imageUrls': imageUrlsList,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Copy with method for updates
  ProductEntity copyWith({
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
    int? createdAt,
    int? updatedAt,
    String? remoteId,
    int? syncStatus,
  }) {
    return ProductEntity(
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
      imageUrls: imageUrls != null
          ? (imageUrls.isNotEmpty ? jsonEncode(imageUrls) : null)
          : this.imageUrls,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
