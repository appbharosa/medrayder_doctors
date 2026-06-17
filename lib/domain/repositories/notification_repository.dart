import '../../data/models/notification_response_model.dart';

abstract class NotificationRepository {
  Future<NotificationResponseModel> getNotifications({String lang = 'en'});
  Future<NotificationResponseModel> markNotificationAsRead(int id, {String lang = 'en'});
}