import 'package:get/get.dart';
import '../data/store_service.dart';
import '../data/store_repository.dart';
import '../controller/store_controller.dart';

class StoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StoreService());
    Get.lazyPut(() => StoreRepository(Get.find()));
    Get.lazyPut(() => StoreController(Get.find()));
  }
}
