import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../database/entities/sale_entity.dart';
import '../../../../database/entities/sale_line_item_entity.dart';
import '../services/sale_detail_dto.dart';

/// Interface สำหรับ sales + line items
/// ใช้ทั้ง SQLite และ Firebase ผ่าน DI
abstract class ISalesRepository {
  /// สร้างบิล + รายการสินค้า
  /// SQLite: saleId ใน line items = id ของ sale ที่ insert
  /// Firebase: line items เป็น subcollection ใต้ sale doc
  Future<Either<Failure, void>> createSaleWithLineItems(
    SaleEntity sale,
    List<SaleLineItemEntity> lineItems,
  );

  /// ยอดขายตามช่วงวันที่
  Future<Either<Failure, List<SaleEntity>>> getSalesByDateRange(
    int storeId,
    DateTime start,
    DateTime end,
  );

  /// บิลล่าสุด
  Future<Either<Failure, List<SaleEntity>>> getLatestSales(
    int storeId,
    int limit,
  );

  /// รายละเอียดบิล (หัวบิล + รายการ) โดยใช้ saleId (string เช่น S1734567890)
  Future<Either<Failure, SaleDetailDto?>> getSaleDetailBySaleId(
    int storeId,
    String saleId,
  );

  /// ยกเลิกบิล
  Future<Either<Failure, void>> cancelSale(SaleEntity sale);
}
