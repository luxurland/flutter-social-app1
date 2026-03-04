import 'package:get/get.dart';

class NotificationsController extends GetxController {
  var notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    notifications.value = [
      {
        "title": "New Call",
        "body": "You received a call yesterday",
        "date": "Today",
        "read": false
      },
      {
        "title": "New Product",
        "body": "A seller added a new product",
        "date": "Yesterday",
        "read": true
      },
      {
        "title": "Wallet Update",
        "body": "Your balance increased by 10€",
        "date": "Yesterday",
        "read": false
      },
    ];
  }

  void markAsRead(int index) {
    notifications[index]["read"] = true;
    notifications.refresh();
  }

  void deleteNotification(int index) {
    notifications.removeAt(index);
  }
}
