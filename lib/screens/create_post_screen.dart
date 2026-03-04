import 'package:flutter/material.dart';
import '../api/api_service.dart';

class CreatePostScreen extends StatefulWidget {
  final ApiService api;
  const CreatePostScreen({super.key, required this.api});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final cidCtrl = TextEditingController();
  bool loading = false;

  createPost() async {
    setState(() => loading = true);

    final res = await widget.api.post("/posts/personal", {
      "cid": cidCtrl.text,
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
      appBar: AppBar(title: Text("create post")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: cidCtrl,
              decoration: InputDecoration(labelText: "CID (content link)"),
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
