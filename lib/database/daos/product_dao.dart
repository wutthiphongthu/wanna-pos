import 'package:floor/floor.dart';
import '../entities/product_entity.dart';

@dao
abstract class ProductDao {
  @Query('SELECT * FROM products ORDER BY name ASC')
  Future<List<ProductEntity>> getAllProducts();

  @Query('SELECT * FROM products WHERE isActive = 1 ORDER BY name ASC')
  Future<List<ProductEntity>> getActiveProducts();

  @Query('SELECT * FROM products WHERE id = :id')
  Future<ProductEntity?> getProductById(int id);

  @Query('SELECT * FROM products WHERE productCode = :productCode')
  Future<ProductEntity?> getProductByCode(String productCode);

  @Query('SELECT * FROM products WHERE barcode = :barcode')
  Future<ProductEntity?> getProductByBarcode(String barcode);

  @Query(
      'SELECT * FROM products WHERE name LIKE :searchTerm OR productCode LIKE :searchTerm OR barcode LIKE :searchTerm')
  Future<List<ProductEntity>> searchProducts(String searchTerm);

  @Query('SELECT * FROM products WHERE category = :category ORDER BY name ASC')
  Future<List<ProductEntity>> getProductsByCategory(String category);

  @Query(
      'SELECT * FROM products WHERE stockQuantity <= minStockLevel AND isActive = 1')
  Future<List<ProductEntity>> getLowStockProducts();

  @Query(
      'SELECT DISTINCT category FROM products WHERE isActive = 1 ORDER BY category ASC')
  Future<List<String>> getAllCategories();

  @insert
  Future<int> insertProduct(ProductEntity product);

  @update
  Future<int> updateProduct(ProductEntity product);

  @delete
  Future<int> deleteProduct(ProductEntity product);

  @Query(
      'UPDATE products SET stockQuantity = :newQuantity, updatedAt = :updatedAt WHERE id = :id')
  Future<int?> updateStockQuantity(int id, int newQuantity, int updatedAt);

  @Query(
      'UPDATE products SET isActive = :isActive, updatedAt = :updatedAt WHERE id = :id')
  Future<int?> updateProductStatus(int id, bool isActive, int updatedAt);

  @Query('SELECT COUNT(*) FROM products WHERE isActive = 1')
  Future<int?> getActiveProductCount();

  @Query(
      'SELECT COUNT(*) FROM products WHERE stockQuantity <= minStockLevel AND isActive = 1')
  Future<int?> getLowStockProductCount();
}
