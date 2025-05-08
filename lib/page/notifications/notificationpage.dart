import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:park/bloc/notification_bloc/notification_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/model/app_notification.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    context.read<NotificationBloc>().add(LoadNotifications(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông báo")),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text("Không có thông báo."));
            }

            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final noti = state.notifications[index];
                return ListTile(
                  leading: Icon(noti.isRead ? Icons.mark_email_read : Icons.mark_email_unread, color: noti.isRead ? Colors.grey : Colors.blue),
                  title: Text(noti.title),
                  subtitle: Text(noti.body),
                  trailing: Text(DateFormat('dd/MM/yyyy HH:mm').format(noti.timestamp)),
                  onTap: () {
                    context.read<NotificationBloc>().add(MarkAsRead(noti.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(noti.body)),
                    );
                  },
                );
              },
            );
          } else if (state is NotificationError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
