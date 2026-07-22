import 'package:flutter/material.dart';
import '../mock/mock_data.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: MockData.notifications.length,
          itemBuilder: (context, index) {
            final notification = MockData.notifications[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(notification.title),
                subtitle: Text(notification.message),
                trailing: Text(notification.time),
              ),
            );
          },
        ),
      ),
    );
  }
}
