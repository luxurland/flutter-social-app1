import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ReportsService {
  final Dio _dio = DioClient.dio;

  Future<void> reportPost(String postType, String postPublicId, String reason) async {
    await _dio.post("/reports/create", data: {
      "post_type": postType,
      "post_public_id": postPublicId,
      "reason": reason,
    });
  }

  Future<List<dynamic>> getReports() async {
    final res = await _dio.get("/reports/all");
    return res.data;
  }

  Future<void> resolveReport(int reportId) async {
    await _dio.post("/reports/resolve", data: {"report_id": reportId});
  }
}
