import 'package:get/get.dart';
import '../data/reports_repository.dart';

class ReportsController extends GetxController {
  final ReportsRepository repo;
  ReportsController(this.repo);

  var reports = <dynamic>[].obs;
  var loading = false.obs;

  Future<void> loadReports() async {
    loading.value = true;
    reports.value = await repo.all();
    loading.value = false;
  }

  Future<void> resolve(int id) async {
    await repo.resolve(id);
    reports.removeWhere((r) => r["id"] == id);
  }
}
