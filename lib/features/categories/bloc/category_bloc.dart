import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../services/category_service.dart';
import 'category_event.dart';
import 'category_state.dart';

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryService _categoryService;

  CategoryBloc(this._categoryService) : super(CategoryInitial()) {
    on<LoadAllCategories>(_onLoadAllCategories);
    on<LoadActiveCategories>(_onLoadActiveCategories);
    on<LoadCategoryById>(_onLoadCategoryById);
    on<SearchCategories>(_onSearchCategories);
    on<CreateCategory>(_onCreateCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<ToggleCategoryStatus>(_onToggleCategoryStatus);
  }

  Future<void> _onLoadAllCategories(
      LoadAllCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    
    try {
      final categories = await _categoryService.getAllCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('เกิดข้อผิดพลาดในการโหลดหมวดหมู่: ${e.toString()}'));
    }
  }

  Future<void> _onLoadActiveCategories(
      LoadActiveCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    
    try {
      final categories = await _categoryService.getActiveCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('เกิดข้อผิดพลาดในการโหลดหมวดหมู่: ${e.toString()}'));
    }
  }

  Future<void> _onLoadCategoryById(
      LoadCategoryById event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    
    try {
      final category = await _categoryService.getCategoryById(event.id);
      if (category != null) {
        emit(CategoryLoaded([category]));
      } else {
        emit(const CategoryError('ไม่พบหมวดหมู่ที่ต้องการ'));
      }
    } catch (e) {
      emit(CategoryError('เกิดข้อผิดพลาดในการโหลดหมวดหมู่: ${e.toString()}'));
    }
  }

  Future<void> _onSearchCategories(
      SearchCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    
    try {
      final categories = await _categoryService.searchCategories(event.query);
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('เกิดข้อผิดพลาดในการค้นหาหมวดหมู่: ${e.toString()}'));
    }
  }

  Future<void> _onCreateCategory(
      CreateCategory event, Emitter<CategoryState> emit) async {
    try {
      final category = await _categoryService.createCategory(event.category);
      emit(CategoryOperationSuccess('เพิ่มหมวดหมู่สำเร็จ', category: category));
      
      // Reload categories after successful creation
      add(const LoadAllCategories());
    } catch (e) {
      emit(CategoryOperationFailure('เกิดข้อผิดพลาดในการเพิ่มหมวดหมู่: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    try {
      final category = await _categoryService.updateCategory(event.category);
      emit(CategoryOperationSuccess('อัปเดตหมวดหมู่สำเร็จ', category: category));
      
      // Reload categories after successful update
      add(const LoadAllCategories());
    } catch (e) {
      emit(CategoryOperationFailure('เกิดข้อผิดพลาดในการอัปเดตหมวดหมู่: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await _categoryService.deleteCategory(event.id);
      emit(const CategoryOperationSuccess('ลบหมวดหมู่สำเร็จ'));
      
      // Reload categories after successful deletion
      add(const LoadAllCategories());
    } catch (e) {
      emit(CategoryOperationFailure('เกิดข้อผิดพลาดในการลบหมวดหมู่: ${e.toString()}'));
    }
  }

  Future<void> _onToggleCategoryStatus(
      ToggleCategoryStatus event, Emitter<CategoryState> emit) async {
    try {
      final category = await _categoryService.toggleCategoryStatus(event.id);
      final statusText = category.isActive ? 'เปิดใช้งาน' : 'ปิดใช้งาน';
      emit(CategoryOperationSuccess('${statusText}หมวดหมู่สำเร็จ', category: category));
      
      // Reload categories after successful status toggle
      add(const LoadAllCategories());
    } catch (e) {
      emit(CategoryOperationFailure('เกิดข้อผิดพลาดในการเปลี่ยนสถานะหมวดหมู่: ${e.toString()}'));
    }
  }
}
