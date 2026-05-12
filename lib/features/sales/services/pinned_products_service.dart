import 'package:injectable/injectable.dart';

import '../../../core/utils/storage_service.dart';
import '../../auth/services/auth_service_interface.dart';

/// เก็บรายการ product id ที่ปักหมุดในหน้าขาย แยกตามร้าน (SharedPreferences)
@injectable
class PinnedProductsService {
  final StorageService _storage;
  final IAuthService _auth;

  PinnedProductsService(this._storage, this._auth);

  String _key(int storeId) => 'pos_pinned_product_ids_v1_$storeId';

  Future<List<int>> getPinnedProductIds() async {
    final storeId = await _auth.getCurrentStoreId();
    final raw = await _storage.getString(_key(storeId));
    if (raw == null || raw.trim().isEmpty) return [];
    return raw
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
  }

  Future<void> _save(int storeId, List<int> ids) async {
    await _storage.setString(_key(storeId), ids.join(','));
  }

  /// สลับปักหมุด — ลำดับปักหมุด = ลำดับที่กด (แสดงก่อนในกริด)
  Future<void> togglePin({required int productId}) async {
    final storeId = await _auth.getCurrentStoreId();
    final ids = await getPinnedProductIds();
    if (ids.contains(productId)) {
      ids.remove(productId);
    } else {
      ids.add(productId);
    }
    await _save(storeId, ids);
  }
}
