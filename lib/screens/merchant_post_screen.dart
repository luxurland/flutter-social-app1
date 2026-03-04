import 'package:flutter/material.dart';
import '../api/api_service.dart';

class MerchantPostScreen extends StatefulWidget {
  final ApiService api;
  final String publicId;

  const MerchantPostScreen({
    super.key,
    required this.api,
    required this.publicId,
  });

  @override
  State<MerchantPostScreen> createState() => _MerchantPostScreenState();
}

class _MerchantPostScreenState extends State<MerchantPostScreen> {
  Map? post;
  bool loading = true;

  Future<void> loadPost() async {
    final res = await widget.api.get("/post/${widget.publicId}");
    setState(() {
      post = res["post"];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Merchant Post")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : post == null
              ? const Center(child: Text("Post not found"))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text("User: ${post!["username"]}"),
                    const SizedBox(height: 10),
                    Text("CID: ${post!["cid"]}"),
                    const SizedBox(height: 10),
                    Text("Public ID: ${post!["public_id"]}"),
                    const SizedBox(height: 10),
                    Text("Product ID: ${post!["product_id"]}"),
                    const SizedBox(height: 20),
                    Text("Created at: ${post!["created_at"]}"),
                  ],
                ),
    );
  }
}
