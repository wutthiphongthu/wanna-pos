import 'package:floor/floor.dart';
import '../entities/category_entity.dart';

@dao
abstract class CategoryDao {
  @Query('SELECT * FROM CategoryEntity')
  Future<List<CategoryEntity>> getAllCategories();

  @Query('SELECT * FROM CategoryEntity WHERE isActive = 1')
  Future<List<CategoryEntity>> getActiveCategories();

  @Query('SELECT * FROM CategoryEntity WHERE id = :id')
  Future<CategoryEntity?> getCategoryById(int id);

  @Query(
      'SELECT * FROM CategoryEntity WHERE name LIKE :query OR description LIKE :query')
  Future<List<CategoryEntity>> searchCategories(String query);

  @Query('SELECT * FROM CategoryEntity WHERE name LIKE :name LIMIT 1')
  Future<CategoryEntity?> getCategoryByName(String name);

  @insert
  Future<int> insertCategory(CategoryEntity category);

  @update
  Future<void> updateCategory(CategoryEntity category);

  @delete
  Future<void> deleteCategory(CategoryEntity category);

  @Query('DELETE FROM CategoryEntity WHERE id = :id')
  Future<void> deleteCategoryById(int id);

  @Query(
      'UPDATE CategoryEntity SET isActive = :isActive, updatedAt = :updatedAt WHERE id = :id')
  Future<void> updateCategoryStatus(int id, bool isActive, int updatedAt);

  @Query('DELETE FROM CategoryEntity')
  Future<void> deleteAllCategories();
}
