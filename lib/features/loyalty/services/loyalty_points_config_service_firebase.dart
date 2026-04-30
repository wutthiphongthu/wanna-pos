import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../auth/services/auth_service_interface.dart';
import '../models/loyalty_points_config.dart';
import 'loyalty_points_config_service_interface.dart';

@injectable
class LoyaltyPointsConfigServiceFirebase implements ILoyaltyPointsConfigService {
  final IAuthService _authService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LoyaltyPointsConfigServiceFirebase(this._authService);

  Future<String> _storeId() async =>
      (await _authService.getCurrentStoreId()).toString();

  Future<LoyaltyPointsConfig> getConfig() async {
    final storeId = await _storeId();
    final doc = await _firestore
        .doc(FirestorePaths.storeSettingsLoyalty(storeId))
        .get();
    if (!doc.exists || doc.data() == null) {
      return const LoyaltyPointsConfig();
    }
    final data = doc.data()!;
    final pointsPerBaht = (data['pointsPerBaht'] ?? 10) is int
        ? (data['pointsPerBaht'] ?? 10) as int
        : int.tryParse((data['pointsPerBaht'] ?? '10').toString()) ?? 10;
    final categoryMode = (data['categoryMode'] ?? 'all').toString();
    List<String> categoryNames = [];
    final list = data['categoryNames'];
    if (list != null && list is List) {
      categoryNames = list.map((e) => e.toString()).toList();
    } else if (data['categoryListJson'] != null) {
      try {
        final decoded = jsonDecode((data['categoryListJson'] ?? '[]').toString());
        if (decoded is List) {
          categoryNames = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return LoyaltyPointsConfig(
      pointsPerBaht: pointsPerBaht,
      categoryMode: categoryMode,
      categoryNames: categoryNames,
    );
  }

  Future<void> saveConfig(LoyaltyPointsConfig config) async {
    final storeId = await _storeId();
    await _firestore.doc(FirestorePaths.storeSettingsLoyalty(storeId)).set({
      'pointsPerBaht': config.pointsPerBaht,
      'categoryMode': config.categoryMode,
      'categoryNames': config.categoryNames,
      'categoryListJson': jsonEncode(config.categoryNames),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
