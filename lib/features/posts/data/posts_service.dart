import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class PostsService {
  final Dio _dio = DioClient.dio;

  Future<Map<String, dynamic>> createPersonal(
      String publicId, String postHexId, String cid, String type) async {
    final res = await _dio.post("/posts/personal/create", data: {
      "public_id": publicId,
      "post_hex_id": postHexId,
      "cid": cid,
      "type": type,
    });
    return res.data;
  }

  Future<List<dynamic>> personalFeed() async {
    final res = await _dio.get("/posts/personal/feed");
    return res.data;
  }

  Future<void> hidePersonal(int postId) async {
    await _dio.post("/posts/personal/hide", data: {"post_id": postId});
  }

  Future<Map<String, dynamic>> createProductPost(
      String publicId, String postHexId, int productId, String cid, String type) async {
    final res = await _dio.post("/posts/product/create", data: {
      "public_id": publicId,
      "post_hex_id": postHexId,
      "product_id": productId,
      "cid": cid,
      "type": type,
    });
    return res.data;
  }

  Future<List<dynamic>> productFeed() async {
    final res = await _dio.get("/posts/product/feed");
    return res.data;
  }

  Future<void> hideProductPost(int postId) async {
    await _dio.post("/posts/product/hide", data: {"post_id": postId});
  }
}
