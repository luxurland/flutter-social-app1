import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'friend_requests_screen.dart';

class FriendsScreen extends StatefulWidget {
  final ApiService api;
  const FriendsScreen({super.key, required this.api});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List friends = [];
  bool loading = true;

  Future<void> loadFriends() async {
    final res = await widget.api.get("/friends/list");
    setState(() {
      friends = res["friends"] ?? [];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FriendRequestsScreen(api: widget.api),
                ),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: friends.map((f) {
                return ListTile(
                  title: Text(f["username"]),
                  subtitle: Text("Friends: ${f["friends_count"] ?? 0}"),
                );
              }).toList(),
            ),
    );
  }
}
