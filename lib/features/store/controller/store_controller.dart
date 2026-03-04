import 'package:get/get.dart';
import '../../../api/api_service.dart';

class StoreController extends GetxController {
  final ApiService api = Get.find();

  var products = [].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    loading.value = true;
    final res = await api.get("store/products");
    products.value = res;
    loading.value = false;
  }
}
