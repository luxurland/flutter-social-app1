import 'package:flutter/material.dart';
import '../api/api_service.dart';

class ChatScreen extends StatefulWidget {
  final ApiService api;
  final int threadId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.api,
    required this.threadId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  bool loading = true;
  final textCtrl = TextEditingController();

  Future<void> loadMessages() async {
    final res = await widget.api.get("/messages/thread/${widget.threadId}");
    setState(() {
      messages = res["messages"] ?? [];
      loading = false;
    });
  }

  Future<void> sendMessage() async {
    final text = textCtrl.text.trim();
    if (text.isEmpty) return;

    textCtrl.clear();
    await widget.api.post("/messages/send", {
      "thread_id": widget.threadId,
      "text": text,
    });
    loadMessages();
  }

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[messages.length - 1 - i];
                      final mine = m["mine"] == true;
                      return Align(
                        alignment:
                            mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: mine
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m["text"],
                            style: TextStyle(
                              color: mine ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textCtrl,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
