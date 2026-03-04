import 'store_service.dart';

class StoreRepository {
  final StoreService service;
  StoreRepository(this.service);

  Future<int> createStore(String name, String description) async {
    final data = await service.createStore(name, description);
    return data["store_id"];
  }

  Future<Map<String, dynamic>> myStore() => service.getMyStore();
  Future<Map<String, dynamic>> storeById(int id) => service.getStoreById(id);
}
