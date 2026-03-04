import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/store_controller.dart';

class StoreScreen extends StatelessWidget {
  final StoreController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.loadMyStore();

    return Scaffold(
      appBar: AppBar(title: Text("My Store")),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(child: CircularProgressIndicator());
        }
        final s = controller.store.value;
        if (s == null || s.isEmpty) {
          return Center(child: Text("No store yet"));
        }
        return Column(
          children: [
            ListTile(
              title: Text(s["name"] ?? ""),
              subtitle: Text(s["description"] ?? ""),
            ),
          ],
        );
      }),
    );
  }
}
