import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/product_controller.dart';

class ProductsScreen extends StatelessWidget {
  final int storeId;
  final ProductController controller = Get.find();

  ProductsScreen({required this.storeId});

  @override
  Widget build(BuildContext context) {
    controller.loadByStore(storeId);

    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: controller.products.length,
          itemBuilder: (context, i) {
            final p = controller.products[i];
            return ListTile(
              title: Text(p["name"]),
              subtitle: Text("${p["price"]} €"),
              trailing: IconButton(
                icon: Icon(Icons.hide_source),
                onPressed: () => controller.hideProduct(p["id"]),
              ),
            );
          },
        );
      }),
    );
  }
}
