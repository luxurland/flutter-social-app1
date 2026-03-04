import 'package:get/get.dart';
import '../data/product_repository.dart';

class ProductController extends GetxController {
  final ProductRepository repo;
  ProductController(this.repo);

  var products = <dynamic>[].obs;
  var loading = false.obs;

  Future<void> loadByStore(int storeId) async {
    loading.value = true;
    products.value = await repo.productsByStore(storeId);
    loading.value = false;
  }

  Future<void> hideProduct(int id) async {
    await repo.hide(id);
    products.removeWhere((p) => p["id"] == id);
  }
}
