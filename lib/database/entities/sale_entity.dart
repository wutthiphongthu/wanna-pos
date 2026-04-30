import 'package:floor/floor.dart';

@Entity(tableName: 'sales')
class SaleEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'store_id')
  final int storeId;
  final String saleId;
  final String customerId;
  @ColumnInfo(name: 'customer_name')
  final String customerName;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  @ColumnInfo(name: 'amount_received')
  final double amountReceived;
  @ColumnInfo(name: 'change_amount')
  final double changeAmount;
  @ColumnInfo(name: 'created_at')
  final int createdAt;
  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  @ColumnInfo(name: 'remote_id')
  final String? remoteId;

  @ColumnInfo(name: 'sync_status')
  final int syncStatus;

  SaleEntity({
    this.id,
    this.storeId = 1,
    required this.saleId,
    required this.customerId,
    this.customerName = '',
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    this.amountReceived = 0,
    this.changeAmount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.syncStatus = 0,
  });

  // Convert DateTime to int (timestamp) for storage
  factory SaleEntity.fromDateTime({
    int? id,
    int storeId = 1,
    required String saleId,
    required String customerId,
    String customerName = '',
    required double totalAmount,
    required String paymentMethod,
    required String status,
    double amountReceived = 0,
    double changeAmount = 0,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? remoteId,
    int syncStatus = 1,
  }) {
    return SaleEntity(
      id: id,
      storeId: storeId,
      saleId: saleId,
      customerId: customerId,
      customerName: customerName,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      status: status,
      amountReceived: amountReceived,
      changeAmount: changeAmount,
      createdAt: createdAt.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
      remoteId: remoteId,
      syncStatus: syncStatus,
    );
  }

  SaleEntity copyWith({
    int? id,
    int? storeId,
    String? saleId,
    String? customerId,
    String? customerName,
    double? totalAmount,
    String? paymentMethod,
    String? status,
    double? amountReceived,
    double? changeAmount,
    int? createdAt,
    int? updatedAt,
    String? remoteId,
    int? syncStatus,
  }) {
    return SaleEntity(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      saleId: saleId ?? this.saleId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      amountReceived: amountReceived ?? this.amountReceived,
      changeAmount: changeAmount ?? this.changeAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteId: remoteId ?? this.remoteId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  // Convert int (timestamp) back to DateTime
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);
  DateTime get updatedAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(updatedAt);
}
