
import 'package:equatable/equatable.dart';

abstract class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class ToggleAvailability extends AvailabilityEvent {
  final bool isOnline; // true = online, false = offline

  const ToggleAvailability(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class FetchAvailability extends AvailabilityEvent {} // if needed