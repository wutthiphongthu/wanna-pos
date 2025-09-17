import 'package:injectable/injectable.dart';

class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String deviceModel;
  final String operatingSystem;
  final String osVersion;
  final String appVersion;
  final String buildNumber;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.operatingSystem,
    required this.osVersion,
    required this.appVersion,
    required this.buildNumber,
  });
}

abstract class DeviceInfoService {
  Future<DeviceInfo> getDeviceInfo();
}

@Injectable(as: DeviceInfoService)
class DeviceInfoServiceImpl implements DeviceInfoService {
  // TODO: Implement actual device info retrieval (e.g., device_info_plus)
  // For now, using placeholder implementation

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    return const DeviceInfo(
      deviceId: 'unknown',
      deviceName: 'Unknown Device',
      deviceModel: 'Unknown Model',
      operatingSystem: 'Unknown OS',
      osVersion: 'Unknown Version',
      appVersion: '1.0.0',
      buildNumber: '1',
    );
  }
}
