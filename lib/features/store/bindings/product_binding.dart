import 'package:get/get.dart';
import '../data/product_service.dart';
import '../data/product_repository.dart';
import '../controller/product_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProductService());
    Get.lazyPut(() => ProductRepository(Get.find()));
    Get.lazyPut(() => ProductController(Get.find()));
  }
}
