import '../../domain/entities/booking_history.dart';
import '../../domain/repositories/booking_history_repository.dart';
import '../datasources/booking_history_api_service.dart';


class BookingHistoryRepositoryImpl implements BookingHistoryRepository {
  final BookingHistoryApiService apiService;

  BookingHistoryRepositoryImpl({required this.apiService});

  @override
  Future<List<BookingHistory>> getBookingHistory() {
    return apiService.getBookingHistory();
  }
}