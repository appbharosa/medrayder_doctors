
import 'package:equatable/equatable.dart';
import '../../../data/models/dashboard_response_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardResponseModel data;
  const DashboardLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class DashboardError extends DashboardState {
  final String error;
  const DashboardError(this.error);
  @override
  List<Object?> get props => [error];
}