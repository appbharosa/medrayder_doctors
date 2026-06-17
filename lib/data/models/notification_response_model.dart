import 'notification_model.dart';

class NotificationResponseModel {
  final int status;
  final String message;
  final NotificationResult result;

  NotificationResponseModel({
    required this.status,
    required this.message,
    required this.result,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      status: json['status'] ?? 0,
      message: json['message']?.toString() ?? '',
      result: NotificationResult.fromJson(json['result'] ?? {}),
    );
  }
}

class NotificationResult {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationResult({
    required this.notifications,
    required this.unreadCount,
  });

  factory NotificationResult.fromJson(Map<String, dynamic> json) {
    final notificationsList = json['notifications'] as List? ?? [];
    return NotificationResult(
      notifications: notificationsList
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}