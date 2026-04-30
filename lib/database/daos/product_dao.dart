import 'package:floor/floor.dart';
import '../entities/product_entity.dart';

@dao
abstract class ProductDao {
  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND sync_status != 2 ORDER BY name ASC')
  Future<List<ProductEntity>> getAllProductsByStore(int storeId);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND isActive = 1 AND sync_status != 2 ORDER BY name ASC')
  Future<List<ProductEntity>> getActiveProductsByStore(int storeId);

  @Query('SELECT * FROM products WHERE store_id = :storeId AND id = :id')
  Future<ProductEntity?> getProductById(int storeId, int id);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND remote_id = :remoteId')
  Future<ProductEntity?> getProductByRemoteId(int storeId, String remoteId);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND sync_status = 1')
  Future<List<ProductEntity>> getDirtyProductsByStore(int storeId);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND sync_status = 2')
  Future<List<ProductEntity>> getPendingDeleteProductsByStore(int storeId);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND productCode = :productCode AND sync_status != 2')
  Future<ProductEntity?> getProductByCode(int storeId, String productCode);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND barcode = :barcode AND sync_status != 2')
  Future<ProductEntity?> getProductByBarcode(int storeId, String barcode);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND sync_status != 2 AND (name LIKE :searchTerm OR productCode LIKE :searchTerm OR barcode LIKE :searchTerm)')
  Future<List<ProductEntity>> searchProductsByStore(int storeId, String searchTerm);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND category = :category AND sync_status != 2 ORDER BY name ASC')
  Future<List<ProductEntity>> getProductsByCategory(int storeId, String category);

  @Query(
      'SELECT * FROM products WHERE store_id = :storeId AND stockQuantity <= minStockLevel AND isActive = 1 AND sync_status != 2')
  Future<List<ProductEntity>> getLowStockProductsByStore(int storeId);

  @Query(
      'SELECT DISTINCT category FROM products WHERE store_id = :storeId AND isActive = 1 AND sync_status != 2 ORDER BY category ASC')
  Future<List<String>> getAllCategoriesByStore(int storeId);

  @insert
  Future<int> insertProduct(ProductEntity product);

  @update
  Future<int> updateProduct(ProductEntity product);

  @delete
  Future<int> deleteProduct(ProductEntity product);

  @Query(
      'UPDATE products SET stockQuantity = :newQuantity, updated_at = :updatedAt, sync_status = 1 WHERE id = :id')
  Future<int?> updateStockQuantity(int id, int newQuantity, int updatedAt);

  @Query(
      'UPDATE products SET isActive = :isActive, updated_at = :updatedAt, sync_status = 1 WHERE id = :id')
  Future<int?> updateProductStatus(int id, bool isActive, int updatedAt);

  @Query(
      'SELECT COUNT(*) FROM products WHERE store_id = :storeId AND isActive = 1 AND sync_status != 2')
  Future<int?> getActiveProductCountByStore(int storeId);

  @Query(
      'SELECT COUNT(*) FROM products WHERE store_id = :storeId AND stockQuantity <= minStockLevel AND isActive = 1 AND sync_status != 2')
  Future<int?> getLowStockProductCountByStore(int storeId);
}
