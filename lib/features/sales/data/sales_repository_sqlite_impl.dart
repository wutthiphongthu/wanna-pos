import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/sync/sync_constants.dart';
import '../../../../database/database_service.dart';
import '../../../../database/entities/sale_entity.dart';
import '../../../../database/entities/sale_line_item_entity.dart';
import 'sales_repository_interface.dart';
import '../services/sale_detail_dto.dart';

@Injectable(as: ISalesRepository)
class SalesRepositorySqliteImpl implements ISalesRepository {
  final DatabaseService _db;

  SalesRepositorySqliteImpl(this._db);

  @override
  Future<Either<Failure, void>> createSaleWithLineItems(
    SaleEntity sale,
    List<SaleLineItemEntity> lineItems,
  ) async {
    try {
      final database = await _db.database;
      final saleRowId = await database.saleDao.insertSale(sale);
      if (lineItems.isNotEmpty) {
        final itemsWithSaleId = lineItems
            .map((li) => SaleLineItemEntity(
                  id: li.id,
                  saleId: saleRowId,
                  productId: li.productId,
                  productName: li.productName,
                  quantity: li.quantity,
                  unitPrice: li.unitPrice,
                  itemDiscount: li.itemDiscount,
                  lineTotal: li.lineTotal,
                  remoteId: li.remoteId,
                  syncStatus: SyncStatus.dirty,
                ))
            .toList();
        await database.saleLineItemDao.insertLineItems(itemsWithSaleId);
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
      final db = await _db.database;
      final startMs = start.millisecondsSinceEpoch;
      final endMs = end.millisecondsSinceEpoch;
      final sales =
          await db.saleDao.getSalesByDateRange(storeId, startMs, endMs);
      return Right(sales);
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
      final db = await _db.database;
      final sales = await db.saleDao.getLatestSalesByStore(storeId, limit);
      return Right(sales);
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
      final db = await _db.database;
      final sale = await db.saleDao.getSaleById(storeId, saleId);
      if (sale == null) return Right(null);
      final lineItems =
          await db.saleLineItemDao.getLineItemsBySaleId(sale.id!);
      return Right(SaleDetailDto(sale: sale, lineItems: lineItems));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelSale(SaleEntity sale) async {
    try {
      final db = await _db.database;
      final updated = SaleEntity(
        id: sale.id,
        storeId: sale.storeId,
        saleId: sale.saleId,
        customerId: sale.customerId,
        customerName: sale.customerName,
        totalAmount: sale.totalAmount,
        paymentMethod: sale.paymentMethod,
        status: 'cancelled',
        amountReceived: sale.amountReceived,
        changeAmount: sale.changeAmount,
        createdAt: sale.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await db.saleDao.updateSale(updated);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
