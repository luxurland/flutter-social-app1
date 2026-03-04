import 'package:flutter/material.dart';
import '../api/api_service.dart';

class StoreScreen extends StatefulWidget {
  final ApiService api;
  const StoreScreen({super.key, required this.api});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  Map? store;
  List products = [];
  bool loading = true;

  Future<void> loadStore() async {
    final s = await widget.api.get("/store/mine");
    final p = await widget.api.get("/store/products/mine");

    setState(() {
      store = s["store"];
      products = p["products"] ?? [];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadStore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Store")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : store == null
              ? const Center(child: Text("No store found"))
              : ListView(
                  children: [
                    ListTile(
                      title: Text(store!["name"]),
                      subtitle: Text(store!["description"] ?? ""),
                    ),
                    const Divider(),
                    ...products.map((p) => ListTile(
                          title: Text(p["name"]),
                          subtitle: Text("Price: ${p["price"]}"),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              "/product_details",
                              arguments: p["id"],
                            );
                          },
                        ))
                  ],
                ),
    );
  }
}
