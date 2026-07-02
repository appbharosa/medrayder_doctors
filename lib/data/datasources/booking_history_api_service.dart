import 'package:dio/dio.dart';
import '../../core/app_urls/app_urls.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/booking_history.dart';


class BookingHistoryApiService {
  final Dio dio;

  BookingHistoryApiService(this.dio);

  Future<List<BookingHistory>> getBookingHistory() async {
    try {
      final response = await dio.get(AppUrls.bookingHistory);
      if (response.data['status'] == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BookingHistory.fromJson(json)).toList();
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load booking history');
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