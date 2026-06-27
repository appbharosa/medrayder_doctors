import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/availability.dart';
import 'availability_event.dart';
import 'availability_state.dart';
import '../../../domain/repositories/availability_repository.dart';

class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final AvailabilityRepository repository;

  AvailabilityBloc(this.repository) : super(AvailabilityInitial()) {
    on<ToggleAvailability>(_onToggle);
    on<FetchAvailability>(_onFetch);
  }

  Future<void> _onToggle(
      ToggleAvailability event,
      Emitter<AvailabilityState> emit,
      ) async {
    emit(AvailabilityLoading());
    try {
      final type = event.isOnline ? 'online' : 'offline';
      final availability = await repository.updateAvailability(type);
      emit(AvailabilityLoaded(availability));
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }


  Future<void> _onFetch(FetchAvailability event, Emitter<AvailabilityState> emit) async {
    emit(AvailabilityLoading());
    try {
      // You might need a separate API to get current availability, or you can just use a default.
      // For now, we'll set a default state (offline) and let the toggle update.
      // If your API has a GET endpoint, call it here.
      // Otherwise, just emit a default state.
      emit(AvailabilityLoaded(Availability(availability: 0, isAvailable: false, message: '')));
    } catch (e) {
      emit(AvailabilityError(e.toString()));
    }
  }
}