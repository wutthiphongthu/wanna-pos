import 'package:injectable/injectable.dart';
import '../models/category_model.dart';

@injectable
class CategoryService {
  // Mock data สำหรับ demo
  final List<CategoryModel> _categories = [
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

  // ดึงหมวดหมู่ทั้งหมด
  Future<List<CategoryModel>> getAllCategories() async {
    await Future.delayed(const Duration(milliseconds: 300)); // จำลอง API call
    return List.from(_categories);
  }

  // ดึงหมวดหมู่ที่เปิดใช้งาน
  Future<List<CategoryModel>> getActiveCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _categories.where((category) => category.isActive).toList();
  }

  // ดึงหมวดหมู่ตาม ID
  Future<CategoryModel?> getCategoryById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // เพิ่มหมวดหมู่ใหม่
  Future<CategoryModel> createCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newCategory = category.copyWith(
      id: (_categories.isNotEmpty
              ? _categories
                  .map((c) => c.id ?? 0)
                  .reduce((a, b) => a > b ? a : b)
              : 0) +
          1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _categories.add(newCategory);
    return newCategory;
  }

  // อัปเดตหมวดหมู่
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index == -1) {
      throw Exception('ไม่พบหมวดหมู่ที่ต้องการอัปเดต');
    }

    final updatedCategory = category.copyWith(updatedAt: DateTime.now());
    _categories[index] = updatedCategory;
    return updatedCategory;
  }

  // ลบหมวดหมู่
  Future<void> deleteCategory(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('ไม่พบหมวดหมู่ที่ต้องการลบ');
    }

    _categories.removeAt(index);
  }

  // เปิด/ปิดใช้งานหมวดหมู่
  Future<CategoryModel> toggleCategoryStatus(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) {
      throw Exception('ไม่พบหมวดหมู่ที่ต้องการเปลี่ยนสถานะ');
    }

    final updatedCategory = _categories[index].copyWith(
      isActive: !_categories[index].isActive,
      updatedAt: DateTime.now(),
    );

    _categories[index] = updatedCategory;
    return updatedCategory;
  }

  // ค้นหาหมวดหมู่
  Future<List<CategoryModel>> searchCategories(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (query.isEmpty) {
      return getAllCategories();
    }

    return _categories
        .where((category) =>
            category.name.toLowerCase().contains(query.toLowerCase()) ||
            category.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
