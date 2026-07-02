import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/booking_history_repository.dart';
import 'booking_history_event.dart';
import 'booking_history_state.dart';

class BookingHistoryBloc extends Bloc<BookingHistoryEvent, BookingHistoryState> {
  final BookingHistoryRepository repository;

  BookingHistoryBloc({required this.repository}) : super(BookingHistoryInitial()) {
    on<FetchBookingHistory>(_onFetch);
  }

  Future<void> _onFetch(FetchBookingHistory event, Emitter<BookingHistoryState> emit) async {
    emit(BookingHistoryLoading());
    try {
      final bookings = await repository.getBookingHistory();
      emit(BookingHistoryLoaded(bookings));
    } catch (e) {
      emit(BookingHistoryError(e.toString()));
    }
  }
}