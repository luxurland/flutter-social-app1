import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/call_controller.dart';

class CallActiveScreen extends StatelessWidget {
  final CallController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Active Call")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text("Call ID: ${controller.callId.value}")),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Join Call"),
              onPressed: () async {
                await controller.joinCall();
              },
            ),
            ElevatedButton(
              child: Text("Extend 5 min"),
              onPressed: () async {
                await controller.extend(5);
              },
            ),
            ElevatedButton(
              child: Text("End Call"),
              onPressed: () async {
                await controller.end();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
