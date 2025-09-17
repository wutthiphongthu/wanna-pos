import 'package:equatable/equatable.dart';

class Sale extends Equatable {
  final String id;
  final String customerId;
  final List<SaleItem> items;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final String status;

  const Sale({
    required this.id,
    required this.customerId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        items,
        totalAmount,
        paymentMethod,
        createdAt,
        status,
      ];

  // Add copyWith method for JSON serialization
  Sale copyWith({
    String? id,
    String? customerId,
    List<SaleItem>? items,
    double? totalAmount,
    String? paymentMethod,
    DateTime? createdAt,
    String? status,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  // Add fromJson factory
  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => SaleItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}

class SaleItem extends Equatable {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
        productId,
        productName,
        quantity,
        unitPrice,
        totalPrice,
      ];

  // Add copyWith method for JSON serialization
  SaleItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  // Add fromJson factory
  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}
