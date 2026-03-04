import 'package:get/get.dart';
import '../data/store_repository.dart';

class StoreController extends GetxController {
  final StoreRepository repo;
  StoreController(this.repo);

  var store = Rxn<Map<String, dynamic>>();
  var loading = false.obs;

  Future<void> loadMyStore() async {
    loading.value = true;
    store.value = await repo.myStore();
    loading.value = false;
  }

  Future<int> create(String name, String description) async {
    final id = await repo.createStore(name, description);
    await loadMyStore();
    return id;
  }
}
