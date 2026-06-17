import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';
import '../models/notification_response_model.dart';


class NotificationApiService {
  final Dio dio;

  NotificationApiService(this.dio);

  Future<NotificationResponseModel> getNotifications({String lang = 'en'}) async {
    try {
      final response = await dio.get(
        AppUrls.getNotifications,
        queryParameters: {'lang': lang},
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return NotificationResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load notifications');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<NotificationResponseModel> markNotificationAsRead(int id, {String lang = 'en'}) async {
    try {
      final response = await dio.post(
        AppUrls.readNotifications,
        queryParameters: {'id': id, 'lang': lang},
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return NotificationResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to mark notification as read');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['message'] ?? 'Server error occurred';
    } else {
      return error.message ?? 'Network error';
    }
  }
}