import '../models/category_model.dart';

abstract class ICategoryService {
  Future<List<CategoryModel>> getAllCategories();
  Future<List<CategoryModel>> getActiveCategories();
  Future<CategoryModel?> getCategoryById(int id);
  Future<CategoryModel?> getCategoryByName(String name);
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(int id);
  Future<CategoryModel> toggleCategoryStatus(int id);
  Future<List<CategoryModel>> searchCategories(String query);
}
