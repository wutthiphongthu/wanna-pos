import 'package:injectable/injectable.dart';

class NotificationData {
  final String id;
  final String title;
  final String body;
  final String? payload;
  final DateTime? scheduledDate;

  const NotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.scheduledDate,
  });
}

abstract class NotificationService {
  Future<void> showNotification(NotificationData notification);
  Future<void> scheduleNotification(NotificationData notification);
  Future<void> cancelNotification(String id);
  Future<void> cancelAllNotifications();
  Future<void> requestPermission();
  Future<bool> hasPermission();
}

@Injectable(as: NotificationService)
class NotificationServiceImpl implements NotificationService {
  // TODO: Implement actual notification handling (e.g., flutter_local_notifications)
  // For now, using placeholder implementation

  @override
  Future<void> showNotification(NotificationData notification) async {
    // TODO: Implement actual notification display
    print('Notification: ${notification.title} - ${notification.body}');
  }

  @override
  Future<void> scheduleNotification(NotificationData notification) async {
    // TODO: Implement actual notification scheduling
    print(
        'Scheduled Notification: ${notification.title} - ${notification.body}');
  }

  @override
  Future<void> cancelNotification(String id) async {
    // TODO: Implement actual notification cancellation
    print('Cancelled Notification: $id');
  }

  @override
  Future<void> cancelAllNotifications() async {
    // TODO: Implement actual notification cancellation
    print('Cancelled All Notifications');
  }

  @override
  Future<void> requestPermission() async {
    // TODO: Implement actual permission request
    print('Requested Notification Permission');
  }

  @override
  Future<bool> hasPermission() async {
    // TODO: Implement actual permission check
    return true;
  }
}
