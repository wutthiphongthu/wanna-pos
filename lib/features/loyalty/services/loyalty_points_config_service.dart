import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../core/utils/storage_service.dart';
import '../models/loyalty_points_config.dart';
import 'loyalty_points_config_service_interface.dart';

const _keyPointsPerBaht = 'loyalty_points_per_baht';
const _keyCategoryMode = 'loyalty_category_mode';
const _keyCategoryList = 'loyalty_category_list';

@Injectable(as: ILoyaltyPointsConfigService)
class LoyaltyPointsConfigService implements ILoyaltyPointsConfigService {
  final StorageService _storage;

  LoyaltyPointsConfigService(this._storage);

  Future<LoyaltyPointsConfig> getConfig() async {
    final pointsPerBaht = await _storage.getInt(_keyPointsPerBaht);
    final categoryMode = await _storage.getString(_keyCategoryMode);
    final categoryListJson = await _storage.getString(_keyCategoryList);

    List<String> categoryNames = [];
    if (categoryListJson != null && categoryListJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(categoryListJson);
        if (decoded is List) {
          categoryNames = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return LoyaltyPointsConfig(
      pointsPerBaht: pointsPerBaht ?? 10,
      categoryMode: categoryMode ?? 'all',
      categoryNames: categoryNames,
    );
  }

  Future<void> saveConfig(LoyaltyPointsConfig config) async {
    await _storage.setInt(_keyPointsPerBaht, config.pointsPerBaht);
    await _storage.setString(_keyCategoryMode, config.categoryMode);
    await _storage.setString(
      _keyCategoryList,
      jsonEncode(config.categoryNames),
    );
  }
}
