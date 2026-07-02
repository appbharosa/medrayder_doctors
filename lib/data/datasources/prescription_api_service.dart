import 'package:dio/dio.dart';
import '../../core/app_urls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/prescription_request.dart';
import '../models/prescription_response_model.dart';

class PrescriptionApiService {
  final Dio dio;

  PrescriptionApiService(this.dio);

  Future<void> addPrescription(PrescriptionRequest request) async {
    try {
      final response = await dio.post(
        AppUrls.addPrescription,
        data: request.toJson(),
      );
      // ✅ Check the response body status, not just HTTP status
      if (response.data['status'] != 200) {
        throw ServerException(response.data['message'] ?? 'Failed to add prescription');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PrescriptionResponseModel> fetchPrescription({
    required String bookingId,
    required String doctorType,
  }) async {
    try {
      final response = await dio.post(
        AppUrls.addPrescription,
        data: {
          'booking_id': bookingId,
          'doctor_type': doctorType,
          'view_type': 'fetch',
        },
      );
      if (response.data['status'] == 200) {
        return PrescriptionResponseModel.fromJson(response.data['result']);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to fetch prescription');
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