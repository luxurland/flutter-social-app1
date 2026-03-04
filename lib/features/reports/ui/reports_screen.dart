import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/reports_controller.dart';

class ReportsScreen extends StatelessWidget {
  final ReportsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.loadReports();

    return Scaffold(
      appBar: AppBar(title: Text("Reports")),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.reports.length,
          itemBuilder: (context, i) {
            final r = controller.reports[i];
            return ListTile(
              title: Text("${r["post_type"]} - ${r["post_public_id"]}"),
              subtitle: Text(r["reason"] ?? ""),
              trailing: IconButton(
                icon: Icon(Icons.check),
                onPressed: () => controller.resolve(r["id"]),
              ),
            );
          },
        );
      }),
    );
  }
}
