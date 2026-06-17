import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_api_service.dart';
import '../models/notification_response_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApiService apiService;

  NotificationRepositoryImpl({required this.apiService});

  @override
  Future<NotificationResponseModel> getNotifications({String lang = 'en'}) {
    return apiService.getNotifications(lang: lang);
  }

  @override
  Future<NotificationResponseModel> markNotificationAsRead(int id, {String lang = 'en'}) {
    return apiService.markNotificationAsRead(id, lang: lang);
  }
}