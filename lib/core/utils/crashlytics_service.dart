import 'package:injectable/injectable.dart';

abstract class CrashlyticsService {
  Future<void> log(String message);
  Future<void> logError(dynamic error, StackTrace? stackTrace);
  Future<void> setUserIdentifier(String identifier);
  Future<void> setUserName(String name);
  Future<void> setUserEmail(String email);
  Future<void> setCustomKey(String key, dynamic value);
}

@Injectable(as: CrashlyticsService)
class CrashlyticsServiceImpl implements CrashlyticsService {
  // TODO: Implement actual crashlytics (e.g., firebase_crashlytics)
  // For now, using placeholder implementation

  @override
  Future<void> log(String message) async {
    // TODO: Implement actual logging
    print('Crashlytics Log: $message');
  }

  @override
  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    // TODO: Implement actual error logging
    print('Crashlytics Error: $error');
    if (stackTrace != null) {
      print('Stack Trace: $stackTrace');
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    // TODO: Implement actual user identifier setting
    print('Crashlytics User ID: $identifier');
  }

  @override
  Future<void> setUserName(String name) async {
    // TODO: Implement actual user name setting
    print('Crashlytics User Name: $name');
  }

  @override
  Future<void> setUserEmail(String email) async {
    // TODO: Implement actual user email setting
    print('Crashlytics User Email: $email');
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    // TODO: Implement actual custom key setting
    print('Crashlytics Custom Key: $key = $value');
  }
}
