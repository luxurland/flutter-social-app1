import 'package:get/get.dart';
import '../../../api/api_service.dart';
import '../data/reports_repository.dart';

class ReportsController extends GetxController {
  late ReportsRepository repo;
  final ApiService api = Get.find();

  var reports = <dynamic>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    repo = ReportsRepository(api);
    loadReports();
  }

  Future<void> loadReports() async {
    loading.value = true;
    reports.value = await repo.all();
    loading.value = false;
  }

  Future<void> resolve(int id) async {
    await repo.resolve(id);
    reports.removeWhere((r) => r["id"] == id);
  }

  Future<void> sendReport(String message) async {
    await repo.send(message);
  }
}
