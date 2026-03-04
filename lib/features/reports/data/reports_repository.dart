import 'reports_service.dart';

class ReportsRepository {
  final ReportsService service;
  ReportsRepository(this.service);

  Future<void> report(String type, String publicId, String reason) =>
      service.reportPost(type, publicId, reason);

  Future<List<dynamic>> all() => service.getReports();

  Future<void> resolve(int id) => service.resolveReport(id);
}
