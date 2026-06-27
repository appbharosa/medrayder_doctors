
import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';

class AvailabilityApiService {
  final Dio _dio;

  AvailabilityApiService(this._dio);

  Future<Map<String, dynamic>> updateAvailability(String type) async {
    final response = await _dio.post(
      AppUrls.availability,
      data: {'type': type},
    );
    return response.data;
  }
}