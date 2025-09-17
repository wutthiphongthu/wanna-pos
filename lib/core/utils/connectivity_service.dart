import 'package:injectable/injectable.dart';

enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

abstract class ConnectivityService {
  Stream<ConnectivityStatus> get connectivityStream;
  Future<ConnectivityStatus> get connectivityStatus;
}

@Injectable(as: ConnectivityService)
class ConnectivityServiceImpl implements ConnectivityService {
  // TODO: Implement actual connectivity monitoring (e.g., connectivity_plus)
  // For now, using placeholder implementation

  @override
  Stream<ConnectivityStatus> get connectivityStream {
    // TODO: Implement actual connectivity stream
    return Stream.value(ConnectivityStatus.connected);
  }

  @override
  Future<ConnectivityStatus> get connectivityStatus async {
    // TODO: Implement actual connectivity check
    return ConnectivityStatus.connected;
  }
}
