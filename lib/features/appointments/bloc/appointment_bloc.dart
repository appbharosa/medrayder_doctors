import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/appointment_repository.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AppointmentRepository repository;

  AppointmentBloc({required this.repository}) : super(AppointmentInitial()) {
    on<FetchAppointments>(_onFetch);
    on<LoadMoreAppointments>(_onLoadMore);
  }

  Future<void> _onFetch(FetchAppointments event, Emitter<AppointmentState> emit) async {
    emit(AppointmentLoading());
    try {
      final response = await repository.getActiveAppointments(
        type: event.type,
        limit: event.limit,
        offset: event.offset,
      );
      emit(AppointmentLoaded(
        appointments: response.data,
        hasMore: response.pagination.currentPage < response.pagination.totalPages,
        currentPage: response.pagination.currentPage,
      ));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreAppointments event, Emitter<AppointmentState> emit) async {
    final currentState = state;
    if (currentState is! AppointmentLoaded) return;
    if (!currentState.hasMore) return;

    emit(AppointmentLoadMoreLoading(
      existingAppointments: currentState.appointments,
      currentPage: currentState.currentPage,
    ));

    try {
      final response = await repository.getActiveAppointments(
        type: event.type,
        limit: event.limit,
        offset: event.offset,
      );
      final updatedList = [...currentState.appointments, ...response.data];
      emit(AppointmentLoaded(
        appointments: updatedList,
        hasMore: response.pagination.currentPage < response.pagination.totalPages,
        currentPage: response.pagination.currentPage,
      ));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}