import 'package:floor/floor.dart';
import '../entities/sale_entity.dart';

@dao
abstract class SaleDao {
  @Query('SELECT * FROM sales')
  Future<List<SaleEntity>> getAllSales();

  @Query('SELECT * FROM sales WHERE saleId = :saleId')
  Future<SaleEntity?> getSaleById(String saleId);

  @insert
  Future<int> insertSale(SaleEntity sale);

  @update
  Future<int> updateSale(SaleEntity sale);

  @delete
  Future<int> deleteSale(SaleEntity sale);

  @Query('SELECT * FROM sales WHERE status = :status')
  Future<List<SaleEntity>> getSalesByStatus(String status);

  @Query('SELECT * FROM sales WHERE createdAt BETWEEN :startDate AND :endDate')
  Future<List<SaleEntity>> getSalesByDateRange(int startDate, int endDate);
}
