import 'package:dio/dio.dart';

import '../../core/app_urls/app_urls.dart';
import '../models/wallet_debit_request_model.dart';
import '../models/wallet_response_model.dart';


class WalletApiService {
  final Dio dio;

  WalletApiService(this.dio);

  Future<WalletResponseModel> getWalletHistory({
    required int doctorId,
    required String type,  // ✅ new required parameter
    String? startDate,
    String? endDate,
    String? transactionType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'doctor_id': doctorId,
        'type': type,  // ✅ added
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        if (transactionType != null && transactionType.isNotEmpty) 'transaction_type': transactionType,
      };
      final response = await dio.get(
        AppUrls.walletHistory,
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data['status'] == 200) {
        return WalletResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load wallet history');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> walletDebit(WalletDebitRequestModel request) async {
    try {
      final response = await dio.post(
        AppUrls.walletDebit,
        data: request.toJson(),
      );
      // Note: status can be 400, so we check status code 200 but allow 400 errors as well
      if (response.statusCode == 200 || response.statusCode == 400) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to process debit request');
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