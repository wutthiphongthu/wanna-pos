import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../auth/services/auth_service_interface.dart';
import '../models/category_model.dart';
import 'category_service_interface.dart';

@injectable
class CategoryServiceFirebase implements ICategoryService {
  final IAuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CategoryServiceFirebase(this._authService);

  Future<String> _storeId() async =>
      (await _authService.getCurrentStoreId()).toString();

  CategoryModel _fromDoc(String docId, Map<String, dynamic> data) {
    return CategoryModel(
      id: int.tryParse(docId),
      storeId: int.tryParse((data['storeId'] ?? '1').toString()) ?? 1,
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      iconName: data['iconName']?.toString(),
      color: data['color']?.toString(),
      isActive: data['isActive'] != false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          (data['createdAt'] ?? 0) is int
              ? (data['createdAt'] ?? 0) as int
              : int.tryParse((data['createdAt'] ?? '0').toString()) ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          (data['updatedAt'] ?? 0) is int
              ? (data['updatedAt'] ?? 0) as int
              : int.tryParse((data['updatedAt'] ?? '0').toString()) ?? 0),
    );
  }

  Map<String, dynamic> _toMap(CategoryModel c) => {
        'storeId': c.storeId.toString(),
        'name': c.name,
        'description': c.description,
        'iconName': c.iconName,
        'color': c.color,
        'isActive': c.isActive,
        'createdAt': c.createdAt.millisecondsSinceEpoch,
        'updatedAt': c.updatedAt.millisecondsSinceEpoch,
      };

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final storeId = await _storeId();
    final snap = await _firestore
        .collection(FirestorePaths.storeCategories(storeId))
        .get();
    return snap.docs.map((d) => _fromDoc(d.id, d.data())).toList();
  }

  @override
  Future<List<CategoryModel>> getActiveCategories() async {
    final storeId = await _storeId();
    final snap = await _firestore
        .collection(FirestorePaths.storeCategories(storeId))
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map((d) => _fromDoc(d.id, d.data())).toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(int id) async {
    final storeId = await _storeId();
    final doc = await _firestore
        .doc(FirestorePaths.storeCategory(storeId, id.toString()))
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return _fromDoc(doc.id, doc.data()!);
  }

  @override
  Future<CategoryModel?> getCategoryByName(String name) async {
    final storeId = await _storeId();
    final snap = await _firestore
        .collection(FirestorePaths.storeCategories(storeId))
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _fromDoc(snap.docs.first.id, snap.docs.first.data());
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    final storeId = await _storeId();
    final id = category.id ?? DateTime.now().millisecondsSinceEpoch;
    final docId = id.toString();
    final now = DateTime.now();
    final c = category.copyWith(
      id: id,
      storeId: int.tryParse(storeId) ?? 1,
      createdAt: now,
      updatedAt: now,
    );
    final data = _toMap(c);
    data['createdAt'] = now.millisecondsSinceEpoch;
    data['updatedAt'] = now.millisecondsSinceEpoch;
    await _firestore
        .doc(FirestorePaths.storeCategory(storeId, docId))
        .set(data);
    return c;
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    if (category.id == null) throw Exception('ไม่สามารถอัปเดตหมวดหมู่ที่ไม่มี ID ได้');
    final storeId = await _storeId();
    final now = DateTime.now();
    final c = category.copyWith(updatedAt: now);
    final data = _toMap(c);
    data['updatedAt'] = now.millisecondsSinceEpoch;
    await _firestore
        .doc(FirestorePaths.storeCategory(storeId, category.id.toString()))
        .update(data);
    return c;
  }

  @override
  Future<void> deleteCategory(int id) async {
    final storeId = await _storeId();
    await _firestore
        .doc(FirestorePaths.storeCategory(storeId, id.toString()))
        .delete();
  }

  @override
  Future<CategoryModel> toggleCategoryStatus(int id) async {
    final c = await getCategoryById(id);
    if (c == null) throw Exception('ไม่พบหมวดหมู่ที่ต้องการเปลี่ยนสถานะ');
    return updateCategory(c.copyWith(isActive: !c.isActive));
  }

  @override
  Future<List<CategoryModel>> searchCategories(String query) async {
    if (query.isEmpty) return getAllCategories();
    final all = await getAllCategories();
    final q = query.toLowerCase();
    return all
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
        .toList();
  }
}
