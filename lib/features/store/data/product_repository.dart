import 'product_service.dart';

class ProductRepository {
  final ProductService service;
  ProductRepository(this.service);

  Future<int> createProduct(
      int storeId, String name, String description, double price, int stock) async {
    final data = await service.createProduct(storeId, name, description, price, stock);
    return data["product_id"];
  }

  Future<List<dynamic>> productsByStore(int storeId) =>
      service.getProductsByStore(storeId);

  Future<void> hide(int productId) => service.hideProduct(productId);
}
