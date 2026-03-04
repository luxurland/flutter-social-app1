import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../controller/reports_controller.dart';

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReportsController(Get.find<ApiService>()));
  }
}
