import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final ApiService api;
  const ChatListScreen({super.key, required this.api});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List threads = [];
  bool loading = true;

  Future<void> loadThreads() async {
    final res = await widget.api.get("/messages/threads");
    setState(() {
      threads = res["threads"] ?? [];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadThreads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: threads.map((t) {
                return ListTile(
                  title: Text(t["other_username"]),
                  subtitle: Text(t["last_message"] ?? ""),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          api: widget.api,
                          threadId: t["id"],
                          otherUserName: t["other_username"],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
