import 'package:floor/floor.dart';
import '../entities/category_entity.dart';

@dao
abstract class CategoryDao {
  @Query(
      'SELECT * FROM CategoryEntity WHERE store_id = :storeId AND sync_status != 2')
  Future<List<CategoryEntity>> getAllCategoriesByStore(int storeId);

  @Query(
      'SELECT * FROM CategoryEntity WHERE store_id = :storeId AND isActive = 1 AND sync_status != 2')
  Future<List<CategoryEntity>> getActiveCategoriesByStore(int storeId);

  @Query('SELECT * FROM CategoryEntity WHERE store_id = :storeId AND id = :id')
  Future<CategoryEntity?> getCategoryById(int storeId, int id);

  @Query(
      'SELECT * FROM CategoryEntity WHERE store_id = :storeId AND sync_status != 2 AND (name LIKE :query OR description LIKE :query)')
  Future<List<CategoryEntity>> searchCategoriesByStore(int storeId, String query);

  @Query(
      'SELECT * FROM CategoryEntity WHERE store_id = :storeId AND name LIKE :name AND sync_status != 2 LIMIT 1')
  Future<CategoryEntity?> getCategoryByName(int storeId, String name);

  @Query(
      'SELECT * FROM CategoryEntity WHERE store_id = :storeId AND remote_id = :remoteId')
  Future<CategoryEntity?> getCategoryByRemoteId(int storeId, String remoteId);

  @Query(
      'SELECT * FROM CategoryEntity WHERE store_id = :storeId AND sync_status = 1')
  Future<List<CategoryEntity>> getDirtyCategoriesByStore(int storeId);

  @Query(
      'SELECT * FROM CategoryEntity WHERE store_id = :storeId AND sync_status = 2')
  Future<List<CategoryEntity>> getPendingDeleteCategoriesByStore(int storeId);

  @insert
  Future<int> insertCategory(CategoryEntity category);

  @update
  Future<void> updateCategory(CategoryEntity category);

  @delete
  Future<void> deleteCategory(CategoryEntity category);

  @Query('DELETE FROM CategoryEntity WHERE id = :id')
  Future<void> deleteCategoryById(int id);

  @Query(
      'UPDATE CategoryEntity SET isActive = :isActive, updatedAt = :updatedAt, sync_status = 1 WHERE id = :id')
  Future<void> updateCategoryStatus(int id, bool isActive, int updatedAt);

  @Query('DELETE FROM CategoryEntity WHERE store_id = :storeId')
  Future<void> deleteAllCategoriesByStore(int storeId);
}
