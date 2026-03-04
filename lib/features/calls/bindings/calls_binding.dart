import 'package:get/get.dart';
import '../data/call_service.dart';
import '../data/call_repository.dart';
import '../controller/call_controller.dart';

class CallsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CallService());
    Get.lazyPut(() => CallRepository(Get.find()));
    Get.lazyPut(() => CallController(Get.find()));
  }
}
