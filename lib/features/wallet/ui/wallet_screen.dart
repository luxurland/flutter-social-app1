import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/wallet_controller.dart';

class WalletScreen extends StatelessWidget {
  final WalletController controller = Get.find();

  WalletScreen({super.key});

  Widget _balanceCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B5FFF),
            Color(0xFF00C2D1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Current Balance",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 8),
              Text(
                "${controller.balance.value.toStringAsFixed(2)} €",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0B5FFF),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Recharge", style: TextStyle(color: Colors.white)),
            onPressed: () {},
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00C2D1),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(Icons.arrow_upward, color: Colors.white),
            label: Text("Withdraw", style: TextStyle(color: Colors.white)),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _filterChips() {
    final filters = ["All", "Call", "Store", "Recharge", "Withdraw"];

    return Obx(() => Wrap(
          spacing: 8,
          children: filters.map((f) {
            final selected = controller.filter.value == f;
            return ChoiceChip(
              label: Text(f),
              selected: selected,
              selectedColor: Color(0xFF0B5FFF),
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
              onSelected: (_) => controller.setFilter(f),
            );
          }).toList(),
        ));
  }

  Widget _transactionItem(Map<String, dynamic> t) {
    final isPositive = t["amount"] > 0;
    final icon = t["type"] == "call"
        ? Icons.call
        : t["type"] == "store"
            ? Icons.shopping_bag
            : t["type"] == "recharge"
                ? Icons.add_circle
                : Icons.arrow_upward;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPositive ? Colors.green : Colors.red,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(t["type"].toString().toUpperCase()),
      subtitle: Text(t["date"]),
      trailing: Text(
        "${t["amount"]} €",
        style: TextStyle(
          color: isPositive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet"),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            _balanceCard(),
            SizedBox(height: 20),
            _actionButtons(),
            SizedBox(height: 20),
            Text("Transactions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _filterChips(),
            SizedBox(height: 10),
            ...controller.filteredTransactions.map(_transactionItem),
          ],
        );
      }),
    );
  }
}
