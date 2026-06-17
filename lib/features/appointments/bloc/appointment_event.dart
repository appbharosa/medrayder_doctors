import 'package:equatable/equatable.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();
  @override
  List<Object?> get props => [];
}

class FetchAppointments extends AppointmentEvent {
  final String type;
  final int limit;
  final int offset;

  const FetchAppointments({
    required this.type,
    this.limit = 10,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [type, limit, offset];
}

class LoadMoreAppointments extends AppointmentEvent {
  final String type;
  final int limit;
  final int offset;

  const LoadMoreAppointments({
    required this.type,
    this.limit = 10,
    required this.offset,
  });

  @override
  List<Object?> get props => [type, limit, offset];
}