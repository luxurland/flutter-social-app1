import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/posts_controller.dart';

class PersonalFeedScreen extends StatelessWidget {
  final PostsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.loadPersonal();

    return Scaffold(
      appBar: AppBar(title: Text("Personal Feed")),
      body: Obx(() {
        if (controller.loadingPersonal.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.personal.length,
          itemBuilder: (context, i) {
            final p = controller.personal[i];
            return ListTile(
              title: Text(p["public_id"] ?? ""),
              subtitle: Text(p["cid"] ?? ""),
              trailing: IconButton(
                icon: Icon(Icons.hide_source),
                onPressed: () => controller.hidePersonalPost(p["id"]),
              ),
            );
          },
        );
      }),
    );
  }
}
