import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  final NotificationsController controller = Get.find();

  NotificationsScreen({super.key});

  Widget _notificationItem(Map<String, dynamic> n, int index) {
    final isRead = n["read"];
    final color = isRead ? Colors.grey.shade300 : Color(0xFFE6F7FF);

    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.done, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          controller.markAsRead(index);
        } else {
          controller.deleteNotification(index);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isRead ? Colors.grey : Color(0xFF0B5FFF),
              child: Icon(
                Icons.notifications,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n["title"],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(n["body"], style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 6),
                  Text(n["date"],
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Color(0xFF0B5FFF),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _groupTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        elevation: 0,
      ),
      body: Obx(() {
        final today = controller.notifications
            .where((n) => n["date"] == "Today")
            .toList();
        final yesterday = controller.notifications
            .where((n) => n["date"] == "Yesterday")
            .toList();

        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            if (today.isNotEmpty) _groupTitle("Today"),
            ...today.asMap().entries.map(
                  (e) => _notificationItem(e.value, e.key),
                ),

            if (yesterday.isNotEmpty) _groupTitle("Yesterday"),
            ...yesterday.asMap().entries.map(
                  (e) => _notificationItem(e.value, e.key + today.length),
                ),
          ],
        );
      }),
    );
  }
}
