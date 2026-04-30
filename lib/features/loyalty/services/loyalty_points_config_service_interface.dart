import '../models/loyalty_points_config.dart';

abstract class ILoyaltyPointsConfigService {
  Future<LoyaltyPointsConfig> getConfig();
  Future<void> saveConfig(LoyaltyPointsConfig config);
}
