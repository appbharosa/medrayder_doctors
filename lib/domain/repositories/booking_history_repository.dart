
import '../entities/booking_history.dart';


abstract class BookingHistoryRepository {
  Future<List<BookingHistory>> getBookingHistory();
}