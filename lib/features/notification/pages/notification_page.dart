import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart' as di;
import '../../../data/models/notification_model.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final NotificationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<NotificationBloc>()..add(const FetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          backgroundColor: const Color(0xff1565C0),
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationMarkedRead) {
              // Optional: show toast
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification marked as read'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is NotificationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              final notifications = state.data.result.notifications;
              final unreadCount = state.data.result.unreadCount;
              return _buildNotificationList(context, notifications, unreadCount);
            } else if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.error),
                    ElevatedButton(
                      onPressed: () => context.read<NotificationBloc>().add(const FetchNotifications()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context, List<NotificationModel> notifications, int unreadCount) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No notifications', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (unreadCount > 0)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$unreadCount unread notifications',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: notification.isRead ? Colors.white : Colors.blue.shade50,
                child: ListTile(
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: notification.isRead
                      ? const Icon(Icons.done_all, color: Colors.grey)
                      : const Icon(Icons.circle, color: Colors.blue, size: 12),
                  onTap: () async {
                    if (!notification.isRead) {
                      // Mark as read
                      context.read<NotificationBloc>().add(
                        MarkNotificationRead(notification.id),
                      );
                      // The BLoC will refresh the list after marking.
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}