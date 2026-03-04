import 'package:flutter/material.dart';
import '../api/api_service.dart';

class MerchantPostViewer extends StatelessWidget {
  final ApiService api;
  final Map post;

  const MerchantPostViewer({
    super.key,
    required this.api,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final username = post["username"] ?? "";
    final cid = post["cid"] ?? "";
    final publicId = post["public_id"] ?? "";
    final productId = post["product_id"];

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: Text(
              "Merchant content from CID:\n$cid",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 120,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@$username",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Post ID: $publicId",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  "Product ID: $productId",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 32,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                "/product_details",
                arguments: productId,
              );
            },
            icon: const Icon(Icons.shopping_cart),
            label: const Text("View product"),
          ),
        ),
      ],
    );
  }
}
