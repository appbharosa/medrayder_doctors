import 'package:equatable/equatable.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/models/appointment_response_model.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();
  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<AppointmentModel> appointments;
  final bool hasMore;
  final int currentPage;

  const AppointmentLoaded({
    required this.appointments,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [appointments, hasMore, currentPage];
}

class AppointmentLoadMoreLoading extends AppointmentState {
  final List<AppointmentModel> existingAppointments;
  final int currentPage;

  const AppointmentLoadMoreLoading({
    required this.existingAppointments,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [existingAppointments, currentPage];
}

class AppointmentError extends AppointmentState {
  final String error;

  const AppointmentError(this.error);
  @override
  List<Object?> get props => [error];
}