import '../models/category_model.dart';

abstract class CategoryEvent {
  const CategoryEvent();
}

class LoadAllCategories extends CategoryEvent {
  const LoadAllCategories();
}

class LoadActiveCategories extends CategoryEvent {
  const LoadActiveCategories();
}

class LoadCategoryById extends CategoryEvent {
  final int id;
  
  const LoadCategoryById(this.id);
}

class SearchCategories extends CategoryEvent {
  final String query;
  
  const SearchCategories(this.query);
}

class CreateCategory extends CategoryEvent {
  final CategoryModel category;
  
  const CreateCategory(this.category);
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;
  
  const UpdateCategory(this.category);
}

class DeleteCategory extends CategoryEvent {
  final int id;
  
  const DeleteCategory(this.id);
}

class ToggleCategoryStatus extends CategoryEvent {
  final int id;
  
  const ToggleCategoryStatus(this.id);
}
