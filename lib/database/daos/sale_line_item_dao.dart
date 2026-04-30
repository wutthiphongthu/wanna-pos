import 'package:floor/floor.dart';
import '../entities/sale_line_item_entity.dart';

@dao
abstract class SaleLineItemDao {
  @Query('SELECT * FROM sale_line_items WHERE sale_id = :saleId')
  Future<List<SaleLineItemEntity>> getLineItemsBySaleId(int saleId);

  @insert
  Future<int> insertLineItem(SaleLineItemEntity item);

  @insert
  Future<List<int>> insertLineItems(List<SaleLineItemEntity> items);

  @Query('DELETE FROM sale_line_items WHERE sale_id = :saleId')
  Future<void> deleteBySaleId(int saleId);
}
