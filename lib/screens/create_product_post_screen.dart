import 'package:flutter/material.dart';
import '../api/api_service.dart';

class CreateProductPostScreen extends StatefulWidget {
  final ApiService api;
  const CreateProductPostScreen({super.key, required this.api});

  @override
  State<CreateProductPostScreen> createState() => _CreateProductPostScreenState();
}

class _CreateProductPostScreenState extends State<CreateProductPostScreen> {
  final cidCtrl = TextEditingController();
  final productIdCtrl = TextEditingController();
  bool loading = false;

  createPost() async {
    setState(() => loading = true);

    final res = await widget.api.post("/posts/merchant", {
      "cid": cidCtrl.text,
      "product_id": int.tryParse(productIdCtrl.text),
    });

    setState(() => loading = false);

    if (res["success"] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["error"] ?? "Error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("create product post")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: cidCtrl,
              decoration: InputDecoration(labelText: "CID"),
            ),
            TextField(
              controller: productIdCtrl,
              decoration: InputDecoration(labelText: "Product ID"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : createPost,
              child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("post"),
            )
          ],
        ),
      ),
    );
  }
}
