import 'package:flutter/material.dart';
import '../api/api_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ApiService api;
  final int productId;

  const ProductDetailsScreen({
    super.key,
    required this.api,
    required this.productId,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Map? product;
  bool loading = true;

  Future<void> loadProduct() async {
    final res = await widget.api.get("/store/product/${widget.productId}");
    setState(() {
      product = res["product"];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product details")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text("Product not found"))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      product!["name"],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Price: ${product!["price"]}"),
                    const SizedBox(height: 16),
                    Text(product!["description"] ?? ""),
                  ],
                ),
    );
  }
}
