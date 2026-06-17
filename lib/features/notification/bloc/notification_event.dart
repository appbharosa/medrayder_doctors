import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {
  final String lang;
  const FetchNotifications({this.lang = 'en'});
  @override
  List<Object?> get props => [lang];
}

class MarkNotificationRead extends NotificationEvent {
  final int id;
  final String lang;
  const MarkNotificationRead(this.id, {this.lang = 'en'});
  @override
  List<Object?> get props => [id, lang];
}

class ResetNotificationState extends NotificationEvent {}