import 'package:dio/dio.dart';
import '../../core/app_urls/app_urls.dart';
import '../models/bank_detail_model.dart';
import '../models/bank_detail_request_model.dart';
import '../models/bank_detail_response_model.dart';


class BankApiService {
  final Dio dio;

  BankApiService(this.dio);

  // Get bank details – returns raw Map
  Future<Map<String, dynamic>> getBankDetailsRaw() async {
    try {
      final response = await dio.get(AppUrls.bankDetails);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Add bank details – returns raw Map
  Future<Map<String, dynamic>> addBankDetailsRaw(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        AppUrls.addBankDetails,
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update bank details – returns raw Map
  Future<Map<String, dynamic>> updateBankDetailsRaw(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        '${AppUrls.updateBankDetails}/$id',
        data: data,
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Server error: ${response.statusCode}');
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