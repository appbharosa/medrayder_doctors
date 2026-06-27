import 'package:equatable/equatable.dart';
import '../../../domain/entities/availability.dart';

abstract class AvailabilityState extends Equatable {
  const AvailabilityState();

  @override
  List<Object?> get props => [];
}

class AvailabilityInitial extends AvailabilityState {}

class AvailabilityLoading extends AvailabilityState {}

class AvailabilityLoaded extends AvailabilityState {
  final Availability availability;

  const AvailabilityLoaded(this.availability);

  @override
  List<Object?> get props => [availability];
}

class AvailabilityError extends AvailabilityState {
  final String message;

  const AvailabilityError(this.message);

  @override
  List<Object?> get props => [message];
}