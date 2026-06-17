import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetch);
    on<MarkNotificationRead>(_onMarkRead);
    on<ResetNotificationState>(_onReset);
  }

  Future<void> _onFetch(FetchNotifications event, Emitter<NotificationState> emit) async {
    emit(NotificationLoading());
    try {
      final data = await repository.getNotifications(lang: event.lang);
      emit(NotificationLoaded(data));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkRead(MarkNotificationRead event, Emitter<NotificationState> emit) async {
    // Keep current state (loading) but we want to update unread count after marking
    try {
      final data = await repository.markNotificationAsRead(event.id, lang: event.lang);
      emit(NotificationMarkedRead(data));
      // After marking read, fetch again to refresh list (optional)
      add(FetchNotifications(lang: event.lang));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  void _onReset(ResetNotificationState event, Emitter<NotificationState> emit) {
    emit(NotificationInitial());
  }
}