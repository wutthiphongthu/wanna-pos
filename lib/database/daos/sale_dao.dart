import 'package:floor/floor.dart';
import '../entities/sale_entity.dart';

@dao
abstract class SaleDao {
  @Query('SELECT * FROM sales WHERE store_id = :storeId')
  Future<List<SaleEntity>> getAllSalesByStore(int storeId);

  @Query('SELECT * FROM sales WHERE store_id = :storeId AND saleId = :saleId')
  Future<SaleEntity?> getSaleById(int storeId, String saleId);

  @Query(
      'SELECT * FROM sales WHERE store_id = :storeId AND remote_id = :remoteId')
  Future<SaleEntity?> getSaleByRemoteId(int storeId, String remoteId);

  @Query(
      'SELECT * FROM sales WHERE store_id = :storeId AND sync_status = 1')
  Future<List<SaleEntity>> getDirtySalesByStore(int storeId);

  @insert
  Future<int> insertSale(SaleEntity sale);

  @update
  Future<int> updateSale(SaleEntity sale);

  @delete
  Future<int> deleteSale(SaleEntity sale);

  @Query('SELECT * FROM sales WHERE store_id = :storeId AND status = :status')
  Future<List<SaleEntity>> getSalesByStatus(int storeId, String status);

  @Query('SELECT * FROM sales WHERE store_id = :storeId AND created_at BETWEEN :startDate AND :endDate')
  Future<List<SaleEntity>> getSalesByDateRange(int storeId, int startDate, int endDate);

  /// บิลล่าสุดตาม created_at (ใช้ id ของ sales เป็น sale_id ใน line items)
  @Query('SELECT * FROM sales WHERE store_id = :storeId ORDER BY created_at DESC LIMIT :limit')
  Future<List<SaleEntity>> getLatestSalesByStore(int storeId, int limit);

  @Query('SELECT * FROM sales WHERE id = :id')
  Future<SaleEntity?> getSaleByPrimaryId(int id);
}
