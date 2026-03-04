import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ProductService {
  final Dio _dio = DioClient.dio;

  Future<Map<String, dynamic>> createProduct(
      int storeId, String name, String description, double price, int stock) async {
    final res = await _dio.post("/product/create", data: {
      "store_id": storeId,
      "name": name,
      "description": description,
      "price": price,
      "stock": stock,
    });
    return res.data;
  }

  Future<List<dynamic>> getProductsByStore(int storeId) async {
    final res = await _dio.get("/product/by-store", queryParameters: {
      "store_id": storeId,
    });
    return res.data;
  }

  Future<void> hideProduct(int productId) async {
    await _dio.post("/product/hide", data: {"product_id": productId});
  }
}
