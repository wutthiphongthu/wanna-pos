import 'package:floor/floor.dart';

@Entity(tableName: 'sale_line_items')
class SaleLineItemEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'sale_id')
  final int saleId;
  @ColumnInfo(name: 'product_id')
  final int productId;
  @ColumnInfo(name: 'product_name')
  final String productName;
  final int quantity;
  @ColumnInfo(name: 'unit_price')
  final double unitPrice;
  @ColumnInfo(name: 'item_discount')
  final double itemDiscount;
  @ColumnInfo(name: 'line_total')
  final double lineTotal;

  @ColumnInfo(name: 'remote_id')
  final String? remoteId;

  @ColumnInfo(name: 'sync_status')
  final int syncStatus;

  SaleLineItemEntity({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.itemDiscount = 0,
    required this.lineTotal,
    this.remoteId,
    this.syncStatus = 0,
  });

  SaleLineItemEntity copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? itemDiscount,
    double? lineTotal,
    String? remoteId,
    int? syncStatus,
  }) {
    return SaleLineItemEntity(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      lineTotal: lineTotal ?? this.lineTotal,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
