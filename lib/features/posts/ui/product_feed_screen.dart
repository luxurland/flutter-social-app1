import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/posts_controller.dart';

class ProductFeedScreen extends StatelessWidget {
  final PostsController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    controller.loadProductPosts();

    return Scaffold(
      appBar: AppBar(title: Text("Product Feed")),
      body: Obx(() {
        if (controller.loadingProducts.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, i) {
            final p = controller.products[i];
            return ListTile(
              title: Text(p["public_id"] ?? ""),
              subtitle: Text("Product ID: ${p["product_id"]}"),
              trailing: IconButton(
                icon: Icon(Icons.hide_source),
                onPressed: () => controller.hideProductPost(p["id"]),
              ),
            );
          },
        );
      }),
    );
  }
}
