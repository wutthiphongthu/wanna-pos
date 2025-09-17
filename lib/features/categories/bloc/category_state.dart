import '../models/category_model.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  
  const CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  
  const CategoryError(this.message);
}

class CategoryOperationSuccess extends CategoryState {
  final String message;
  final CategoryModel? category;
  
  const CategoryOperationSuccess(this.message, {this.category});
}

class CategoryOperationFailure extends CategoryState {
  final String message;
  
  const CategoryOperationFailure(this.message);
}
