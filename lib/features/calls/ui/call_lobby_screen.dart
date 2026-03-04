import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/call_controller.dart';

class CallLobbyScreen extends StatelessWidget {
  final CallController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Start Call")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Start Voice Call (5 min)"),
              onPressed: () async {
                await controller.startCall("voice", 5);
                Get.to(() => CallActiveScreen());
              },
            ),
            ElevatedButton(
              child: Text("Start Video Call (5 min)"),
              onPressed: () async {
                await controller.startCall("video", 5);
                Get.to(() => CallActiveScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
