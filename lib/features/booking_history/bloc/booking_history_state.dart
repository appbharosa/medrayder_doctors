import 'package:equatable/equatable.dart';
import '../../../../domain/entities/booking_history.dart';

abstract class BookingHistoryState extends Equatable {
  const BookingHistoryState();
  @override
  List<Object> get props => [];
}

class BookingHistoryInitial extends BookingHistoryState {}

class BookingHistoryLoading extends BookingHistoryState {}

class BookingHistoryLoaded extends BookingHistoryState {
  final List<BookingHistory> bookings;
  const BookingHistoryLoaded(this.bookings);
}

class BookingHistoryError extends BookingHistoryState {
  final String message;
  const BookingHistoryError(this.message);
}