import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/firebase/firestore_paths.dart';
import '../../../../database/entities/sale_entity.dart';
import '../../../../database/entities/sale_line_item_entity.dart';
import '../../auth/services/auth_service_interface.dart';
import '../services/sale_detail_dto.dart';
import 'sales_repository_interface.dart';

@injectable
class SalesRepositoryFirebaseImpl implements ISalesRepository {
  final IAuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SalesRepositoryFirebaseImpl(this._authService);

  Future<String> _storeId() async =>
      (await _authService.getCurrentStoreId()).toString();

  Map<String, dynamic> _saleToMap(SaleEntity s) => {
        'storeId': s.storeId.toString(),
        'saleId': s.saleId,
        'customerId': s.customerId,
        'customerName': s.customerName,
        'totalAmount': s.totalAmount,
        'paymentMethod': s.paymentMethod,
        'status': s.status,
        'amountReceived': s.amountReceived,
        'changeAmount': s.changeAmount,
        'createdAt': s.createdAt,
        'updatedAt': s.updatedAt,
      };

  SaleEntity _saleFromDoc(String docId, Map<String, dynamic> data) {
    return SaleEntity(
      id: null,
      storeId: int.tryParse((data['storeId'] ?? '1').toString()) ?? 1,
      saleId: (data['saleId'] ?? docId).toString(),
      customerId: (data['customerId'] ?? '').toString(),
      customerName: (data['customerName'] ?? '').toString(),
      totalAmount: (data['totalAmount'] ?? 0) is double
          ? (data['totalAmount'] ?? 0) as double
          : (data['totalAmount'] ?? 0).toDouble(),
      paymentMethod: (data['paymentMethod'] ?? 'cash').toString(),
      status: (data['status'] ?? 'completed').toString(),
      amountReceived: (data['amountReceived'] ?? 0) is double
          ? (data['amountReceived'] ?? 0) as double
          : (data['amountReceived'] ?? 0).toDouble(),
      changeAmount: (data['changeAmount'] ?? 0) is double
          ? (data['changeAmount'] ?? 0) as double
          : (data['changeAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] ?? 0) is int
          ? (data['createdAt'] ?? 0) as int
          : int.tryParse((data['createdAt'] ?? '0').toString()) ?? 0,
      updatedAt: (data['updatedAt'] ?? 0) is int
          ? (data['updatedAt'] ?? 0) as int
          : int.tryParse((data['updatedAt'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> _lineItemToMap(SaleLineItemEntity li) => {
        'productId': li.productId,
        'productName': li.productName,
        'quantity': li.quantity,
        'unitPrice': li.unitPrice,
        'itemDiscount': li.itemDiscount,
        'lineTotal': li.lineTotal,
      };

  SaleLineItemEntity _lineItemFromDoc(Map<String, dynamic> data) {
    return SaleLineItemEntity(
      id: null,
      saleId: 0,
      productId: (data['productId'] ?? 0) is int
          ? (data['productId'] ?? 0) as int
          : int.tryParse((data['productId'] ?? '0').toString()) ?? 0,
      productName: (data['productName'] ?? '').toString(),
      quantity: (data['quantity'] ?? 0) is int
          ? (data['quantity'] ?? 0) as int
          : int.tryParse((data['quantity'] ?? '0').toString()) ?? 0,
      unitPrice: (data['unitPrice'] ?? 0) is double
          ? (data['unitPrice'] ?? 0) as double
          : (data['unitPrice'] ?? 0).toDouble(),
      itemDiscount: (data['itemDiscount'] ?? 0) is double
          ? (data['itemDiscount'] ?? 0) as double
          : (data['itemDiscount'] ?? 0).toDouble(),
      lineTotal: (data['lineTotal'] ?? 0) is double
          ? (data['lineTotal'] ?? 0) as double
          : (data['lineTotal'] ?? 0).toDouble(),
    );
  }

  @override
  Future<Either<Failure, void>> createSaleWithLineItems(
    SaleEntity sale,
    List<SaleLineItemEntity> lineItems,
  ) async {
    try {
      final storeId = await _storeId();
      final saleRef = _firestore.doc(
        FirestorePaths.storeSale(storeId, sale.saleId),
      );
      await saleRef.set(_saleToMap(sale));

      if (lineItems.isNotEmpty) {
        final batch = _firestore.batch();
        for (var i = 0; i < lineItems.length; i++) {
          final li = lineItems[i];
          final docId = '${i}_${DateTime.now().millisecondsSinceEpoch}';
          final liRef = _firestore.doc(
            FirestorePaths.storeSaleLineItem(storeId, sale.saleId, docId),
          );
          batch.set(liRef, _lineItemToMap(li));
        }
        await batch.commit();
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SaleEntity>>> getSalesByDateRange(
    int storeId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;
      final snap = await _firestore
          .collection(FirestorePaths.storeSales(storeId.toString()))
          .where('createdAt', isGreaterThanOrEqualTo: startMs)
          .where('createdAt', isLessThan: endMs)
          .orderBy('createdAt', descending: true)
          .get();
      return Right(
        snap.docs.map((d) => _saleFromDoc(d.id, d.data())).toList(),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SaleEntity>>> getLatestSales(
    int storeId,
    int limit,
  ) async {
    try {
      final snap = await _firestore
          .collection(FirestorePaths.storeSales(storeId.toString()))
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return Right(
        snap.docs.map((d) => _saleFromDoc(d.id, d.data())).toList(),
      );
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SaleDetailDto?>> getSaleDetailBySaleId(
    int storeId,
    String saleId,
  ) async {
    try {
      final storeIdStr = storeId.toString();
      final saleDoc = await _firestore
          .doc(FirestorePaths.storeSale(storeIdStr, saleId))
          .get();
      if (!saleDoc.exists || saleDoc.data() == null) return Right(null);

      final sale = _saleFromDoc(saleDoc.id, saleDoc.data()!);
      final lineItemsSnap = await _firestore
          .collection(FirestorePaths.storeSaleLineItems(storeIdStr, saleId))
          .get();
      final lineItems = lineItemsSnap.docs
          .map((d) => _lineItemFromDoc(d.data()))
          .toList();
      return Right(SaleDetailDto(sale: sale, lineItems: lineItems));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSale(SaleEntity sale) async {
    try {
      final storeId = await _storeId();
      await _firestore
          .doc(FirestorePaths.storeSale(storeId, sale.saleId))
          .update({'status': 'cancelled', 'updatedAt': DateTime.now().millisecondsSinceEpoch});
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
