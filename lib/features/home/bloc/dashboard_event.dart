import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class FetchDashboard extends DashboardEvent {
  final String type;
  const FetchDashboard(this.type);
  @override
  List<Object?> get props => [type];
}