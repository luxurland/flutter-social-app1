import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class CallService {
  final Dio _dio = DioClient.dio;

  Future<Map<String, dynamic>> startCall(String type, int minutes) async {
    final response = await _dio.post(
      "/call/start",
      data: {"call_type": type, "duration": minutes},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> addParticipant(int callId) async {
    final response = await _dio.post(
      "/call/add",
      data: {"call_id": callId},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> extendCall(int callId, int minutes) async {
    final response = await _dio.post(
      "/call/extend",
      data: {"call_id": callId, "minutes": minutes},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> endCall(int callId) async {
    final response = await _dio.post(
      "/call/end",
      data: {"call_id": callId},
    );
    return response.data;
  }

  Future<List<dynamic>> getCallHistory() async {
    final response = await _dio.get("/call/history");
    return response.data;
  }
}
