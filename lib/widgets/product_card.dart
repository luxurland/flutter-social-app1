import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String username;
  final String cid;
  final String publicId;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.username,
    required this.cid,
    required this.publicId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: ListTile(
        title: Text(username),
        subtitle: Text("CID: $cid"),
        trailing: const Icon(Icons.shopping_cart),
        onTap: onTap,
      ),
    );
  }
}
