import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/sale.dart';

part 'sale_model.g.dart';

@JsonSerializable()
class SaleModel {
  final String id;
  final String customerId;
  final List<SaleItemModel> items;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final String status;

  const SaleModel({
    required this.id,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    required this.status,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) =>
      _$SaleModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaleModelToJson(this);

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      customerId: sale.customerId,
      items: sale.items.map((item) => SaleItemModel.fromEntity(item)).toList(),
      totalAmount: sale.totalAmount,
      paymentMethod: sale.paymentMethod,
      createdAt: sale.createdAt,
      status: sale.status,
    );
  }

  Sale toEntity() {
    return Sale(
      id: id,
      customerId: customerId,
      items: items.map((item) => item.toEntity()).toList(),
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      status: status,
    );
  }
}

@JsonSerializable()
class SaleItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) =>
      _$SaleItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$SaleItemModelToJson(this);

  factory SaleItemModel.fromEntity(SaleItem item) {
    return SaleItemModel(
      productId: item.productId,
      productName: item.productName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalPrice: item.totalPrice,
    );
  }

  SaleItem toEntity() {
    return SaleItem(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }
}
