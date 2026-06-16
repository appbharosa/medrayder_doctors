import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';
import '../models/dashboard_response_model.dart';


class DashboardApiService {
  final Dio dio;

  DashboardApiService(this.dio);

  Future<DashboardResponseModel> getDashboard(String type) async {
    try {
      final response = await dio.get(
        '${AppUrls.dashboard}?type=$type',
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return DashboardResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard');
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