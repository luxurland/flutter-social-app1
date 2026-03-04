import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class StoreService {
  final Dio _dio = DioClient.dio;

  Future<Map<String, dynamic>> createStore(String name, String description) async {
    final res = await _dio.post("/store/create", data: {
      "name": name,
      "description": description,
    });
    return res.data;
  }

  Future<Map<String, dynamic>> getMyStore() async {
    final res = await _dio.get("/store/me");
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> getStoreById(int id) async {
    final res = await _dio.get("/store/get", queryParameters: {"id": id});
    return Map<String, dynamic>.from(res.data);
  }
}
