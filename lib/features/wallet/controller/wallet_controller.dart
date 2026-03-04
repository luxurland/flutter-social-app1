import 'package:get/get.dart';

class WalletController extends GetxController {
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

    // TODO: ربط مع Worker API
    await Future.delayed(Duration(milliseconds: 500));

    balance.value = 42.50;

    transactions.value = [
      {"type": "call", "amount": -1.5, "date": "2026-03-01"},
      {"type": "recharge", "amount": 10.0, "date": "2026-02-28"},
      {"type": "store", "amount": -5.0, "date": "2026-02-27"},
      {"type": "withdraw", "amount": -20.0, "date": "2026-02-25"},
    ];

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
