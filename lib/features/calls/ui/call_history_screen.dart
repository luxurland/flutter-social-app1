import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/call_controller.dart';

class CallHistoryScreen extends StatelessWidget {
  final CallController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Call History")),
      body: FutureBuilder(
        future: controller.history(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final history = snapshot.data as List;

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, i) {
              final call = history[i];
              return ListTile(
                title: Text("Call ID: ${call['id']}"),
                subtitle: Text("Type: ${call['call_type']}"),
              );
            },
          );
        },
      ),
    );
  }
}
