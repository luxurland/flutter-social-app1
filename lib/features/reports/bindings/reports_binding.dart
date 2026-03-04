import 'package:get/get.dart';
import '../data/reports_service.dart';
import '../data/reports_repository.dart';
import '../controller/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReportsService());
    Get.lazyPut(() => ReportsRepository(Get.find()));
    Get.lazyPut(() => ReportsController(Get.find()));
  }
}
