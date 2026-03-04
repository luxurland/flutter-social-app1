import '../../../api/api_service.dart';

class ReportsRepository {
  final ApiService api;

  ReportsRepository(this.api);

  Future<List<dynamic>> all() async {
    return await api.get("reports");
  }

  Future<void> resolve(int id) async {
    await api.post("reports/resolve", {"id": id});
  }

  Future<void> send(String message) async {
    await api.post("reports", {"message": message});
  }
}
