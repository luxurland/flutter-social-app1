import 'package:get/get.dart';
import '../../../api/api_service.dart';

class CallController extends GetxController {
  final ApiService api = Get.find();

  var history = [].obs;

  Future<void> loadHistory() async {
    final res = await api.get("calls/history");
    history.value = res;
  }
}
