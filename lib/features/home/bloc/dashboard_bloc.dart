import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<FetchDashboard>(_onFetchDashboard);
  }

  Future<void> _onFetchDashboard(
      FetchDashboard event,
      Emitter<DashboardState> emit,
      ) async {
    emit(DashboardLoading());
    try {
      final data = await repository.getDashboard(event.type);
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}