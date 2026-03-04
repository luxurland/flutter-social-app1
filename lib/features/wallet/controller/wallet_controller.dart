import 'package:get/get.dart';
import '../../../api/api_service.dart';

class WalletController extends GetxController {
  final ApiService api = Get.find();

  var balance = 0.0.obs;
  var transactions = <Map<String, dynamic>>[].obs;
  var loading = false.obs;
  var filter = "All".obs;

  @override
  void onInit() {
    super.onInit();
    loadWallet();
  }

  Future<void> loadWallet() async {
    loading.value = true;

    final res = await api.get("wallet/balance");
    balance.value = res["balance"];

    final tx = await api.get("wallet/transactions");
    transactions.value = List<Map<String, dynamic>>.from(tx);

    loading.value = false;
  }

  List<Map<String, dynamic>> get filteredTransactions {
    if (filter.value == "All") return transactions;
    return transactions.where((t) => t["type"] == filter.value.toLowerCase()).toList();
  }

  void setFilter(String f) {
    filter.value = f;
  }
}
