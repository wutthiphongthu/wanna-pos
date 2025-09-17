import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final String id;
  final String saleId;
  final double amount;
  final String method;
  final String status;
  final DateTime createdAt;
  final String? transactionId;

  const Payment({
    required this.id,
    required this.saleId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.transactionId,
  });

  @override
  List<Object?> get props => [
        id,
        saleId,
        amount,
        method,
        status,
        createdAt,
        transactionId,
      ];
}
