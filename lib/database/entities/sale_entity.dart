import 'package:floor/floor.dart';

@Entity(tableName: 'sales')
class SaleEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String saleId;
  final String customerId;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  @ColumnInfo(name: 'created_at')
  final int createdAt;
  @ColumnInfo(name: 'updated_at')
  final int updatedAt;

  SaleEntity({
    this.id,
    required this.saleId,
    required this.customerId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert DateTime to int (timestamp) for storage
  factory SaleEntity.fromDateTime({
    int? id,
    required String saleId,
    required String customerId,
    required double totalAmount,
    required String paymentMethod,
    required String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return SaleEntity(
      id: id,
      saleId: saleId,
      customerId: customerId,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      status: status,
      createdAt: createdAt.millisecondsSinceEpoch,
      updatedAt: updatedAt.millisecondsSinceEpoch,
    );
  }

  // Convert int (timestamp) back to DateTime
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);
  DateTime get updatedAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(updatedAt);
}
