import 'package:injectable/injectable.dart';

import '../../../core/sync/sync_constants.dart';
import '../models/category_model.dart';
import '../../../database/app_database.dart';
import '../../../database/entities/category_entity.dart';
import '../../../features/auth/services/auth_service_interface.dart';
import 'category_service_interface.dart';

@Injectable(as: ICategoryService)
class CategoryService implements ICategoryService {
  final AppDatabase _database;
  final IAuthService _authService;

  CategoryService(this._database, this._authService);

  Future<int> _storeId() => _authService.getCurrentStoreId();

  // ข้อมูล mock สำหรับ seed database
  final List<CategoryModel> _mockCategories = [
    CategoryModel(
      id: 1,
      name: 'อาหาร',
      description: 'อาหารและเครื่องดื่ม',
      iconName: 'restaurant',
      color: '#FF9800',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CategoryModel(
      id: 2,
      name: 'เครื่องดื่ม',
      description: 'เครื่องดื่มทุกประเภท',
      iconName: 'local_drink',
      color: '#2196F3',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CategoryModel(
      id: 3,
      name: 'ของใช้',
      description: 'ของใช้ในครัวเรือน',
      iconName: 'home',
      color: '#4CAF50',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CategoryModel(
      id: 4,
      name: 'เครื่องใช้ไฟฟ้า',
      description: 'อุปกรณ์เครื่องใช้ไฟฟ้า',
      iconName: 'electrical_services',
      color: '#9C27B0',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    CategoryModel(
      id: 5,
      name: 'เสื้อผ้า',
      description: 'เสื้อผ้าและเครื่องแต่งกาย',
      iconName: 'checkroom',
      color: '#E91E63',
      isActive: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // เริ่มต้นข้อมูล (seed database ถ้ายังไม่มีข้อมูล) ตามร้าน
  Future<void> _seedDatabase() async {
    final storeId = await _storeId();
    final existingCategories = await _database.categoryDao.getAllCategoriesByStore(storeId);
    if (existingCategories.isEmpty) {
      for (final category in _mockCategories) {
        final withStore = category.copyWith(storeId: storeId);
        final entity = CategoryEntity.fromModel(withStore);
        await _database.categoryDao.insertCategory(entity);
      }
    }
  }

  // ดึงหมวดหมู่ทั้งหมด (ตามร้านที่ล็อกอิน)
  Future<List<CategoryModel>> getAllCategories() async {
    await _seedDatabase();
    final storeId = await _storeId();
    final entities = await _database.categoryDao.getAllCategoriesByStore(storeId);
    return entities
        .map((entity) => CategoryModel.fromMap(entity.toModelMap()))
        .toList();
  }

  // ดึงหมวดหมู่ที่เปิดใช้งาน
  Future<List<CategoryModel>> getActiveCategories() async {
    await _seedDatabase();
    final storeId = await _storeId();
    final entities = await _database.categoryDao.getActiveCategoriesByStore(storeId);
    return entities
        .map((entity) => CategoryModel.fromMap(entity.toModelMap()))
        .toList();
  }

  // ดึงหมวดหมู่ตาม ID
  Future<CategoryModel?> getCategoryById(int id) async {
    final storeId = await _storeId();
    final entity = await _database.categoryDao.getCategoryById(storeId, id);
    if (entity != null) {
      return CategoryModel.fromMap(entity.toModelMap());
    }
    return null;
  }

  // ดึงหมวดหมู่ตามชื่อ
  Future<CategoryModel?> getCategoryByName(String name) async {
    final storeId = await _storeId();
    final entity = await _database.categoryDao.getCategoryByName(storeId, name);
    if (entity != null) {
      return CategoryModel.fromMap(entity.toModelMap());
    }
    return null;
  }

  // เพิ่มหมวดหมู่ใหม่ (ใช้ร้านปัจจุบัน)
  Future<CategoryModel> createCategory(CategoryModel category) async {
    final storeId = await _storeId();
    final now = DateTime.now();
    final newCategory = category.copyWith(
      storeId: storeId,
      createdAt: now,
      updatedAt: now,
    );

    final entity = CategoryEntity.fromModel(newCategory, syncStatus: SyncStatus.dirty);
    final id = await _database.categoryDao.insertCategory(entity);

    return newCategory.copyWith(id: id);
  }

  // อัปเดตหมวดหมู่
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    if (category.id == null) {
      throw Exception('ไม่สามารถอัปเดตหมวดหมู่ที่ไม่มี ID ได้');
    }

    final updatedCategory = category.copyWith(updatedAt: DateTime.now());
    final entity = CategoryEntity.fromModel(updatedCategory, syncStatus: SyncStatus.dirty);

    await _database.categoryDao.updateCategory(entity);
    return updatedCategory;
  }

  // ลบหมวดหมู่ (ถ้ามี remote_id จะ mark pending_delete รอซิงก์)
  Future<void> deleteCategory(int id) async {
    final storeId = await _storeId();
    final entity = await _database.categoryDao.getCategoryById(storeId, id);
    if (entity == null) return;
    final rid = entity.remoteId;
    if (rid != null && rid.isNotEmpty) {
      await _database.categoryDao.updateCategory(
        entity.copyWith(
          syncStatus: SyncStatus.pendingDelete,
          isActive: false,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      await _database.categoryDao.deleteCategoryById(id);
    }
  }

  // เปิด/ปิดใช้งานหมวดหมู่
  Future<CategoryModel> toggleCategoryStatus(int id) async {
    final storeId = await _storeId();
    final entity = await _database.categoryDao.getCategoryById(storeId, id);
    if (entity == null) {
      throw Exception('ไม่พบหมวดหมู่ที่ต้องการเปลี่ยนสถานะ');
    }

    final newStatus = !entity.isActive;
    final updatedAt = DateTime.now().millisecondsSinceEpoch;

    await _database.categoryDao.updateCategoryStatus(id, newStatus, updatedAt);

    final updatedEntity = await _database.categoryDao.getCategoryById(storeId, id);
    return CategoryModel.fromMap(updatedEntity!.toModelMap());
  }

  // ค้นหาหมวดหมู่
  Future<List<CategoryModel>> searchCategories(String query) async {
    if (query.isEmpty) {
      return getAllCategories();
    }

    final storeId = await _storeId();
    final searchQuery = '%$query%';
    final entities = await _database.categoryDao.searchCategoriesByStore(storeId, searchQuery);
    return entities
        .map((entity) => CategoryModel.fromMap(entity.toModelMap()))
        .toList();
  }
}
