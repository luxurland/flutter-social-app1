import 'package:flutter/material.dart';
import '../api/api_service.dart';

class TagRequestsScreen extends StatefulWidget {
  final ApiService api;
  const TagRequestsScreen({super.key, required this.api});

  @override
  State<TagRequestsScreen> createState() => _TagRequestsScreenState();
}

class _TagRequestsScreenState extends State<TagRequestsScreen> {
  List requests = [];
  bool loading = true;

  Future<void> loadRequests() async {
    final res = await widget.api.get("/tags/pending");
    setState(() {
      requests = res["requests"] ?? [];
      loading = false;
    });
  }

  Future<void> approve(int id) async {
    await widget.api.post("/tags/approve", {"request_id": id});
    loadRequests();
  }

  Future<void> remove(int id) async {
    await widget.api.post("/tags/remove", {"request_id": id});
    loadRequests();
  }

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tag requests")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: requests.map((r) {
                return ListTile(
                  title: Text("Post: ${r["post_public_id"]}"),
                  subtitle: Text("From: ${r["from_username"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => approve(r["id"]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => remove(r["id"]),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
