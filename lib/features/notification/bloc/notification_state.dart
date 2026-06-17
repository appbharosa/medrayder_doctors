import 'package:equatable/equatable.dart';
import '../../../data/models/notification_response_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final NotificationResponseModel data;
  const NotificationLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class NotificationMarkedRead extends NotificationState {
  final NotificationResponseModel data;
  const NotificationMarkedRead(this.data);
  @override
  List<Object?> get props => [data];
}

class NotificationError extends NotificationState {
  final String error;
  const NotificationError(this.error);
  @override
  List<Object?> get props => [error];
}