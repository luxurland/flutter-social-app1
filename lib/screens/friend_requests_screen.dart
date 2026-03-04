import 'package:flutter/material.dart';
import '../api/api_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  final ApiService api;
  const FriendRequestsScreen({super.key, required this.api});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List requests = [];
  bool loading = true;

  Future<void> loadRequests() async {
    final res = await widget.api.get("/friends/requests");
    setState(() {
      requests = res["requests"] ?? [];
      loading = false;
    });
  }

  Future<void> accept(int id) async {
    await widget.api.post("/friends/accept", {"request_id": id});
    loadRequests();
  }

  Future<void> decline(int id) async {
    await widget.api.post("/friends/decline", {"request_id": id});
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
      appBar: AppBar(title: const Text("Friend requests")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: requests.map((r) {
                return ListTile(
                  title: Text(r["from_username"]),
                  subtitle: Text("Request ID: ${r["id"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => accept(r["id"]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => decline(r["id"]),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
