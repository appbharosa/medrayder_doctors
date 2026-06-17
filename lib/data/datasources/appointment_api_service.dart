import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';
import '../models/appointment_response_model.dart';


class AppointmentApiService {
  final Dio dio;

  AppointmentApiService(this.dio);

  Future<AppointmentResponseModel> getActiveAppointments({
    required String type,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final queryParams = {
        'type': type,
        'limit': limit,
        'offset': offset,
      };
      final response = await dio.get(
        AppUrls.activeAppointments,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return AppointmentResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load appointments');
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