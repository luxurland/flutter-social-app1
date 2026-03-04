import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CallHistoryScreen extends StatefulWidget {
  final String baseUrl;
  final String userId;

  const CallHistoryScreen({
    super.key,
    required this.baseUrl,
    required this.userId,
  });

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  List<dynamic> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final uri = Uri.parse("${widget.baseUrl}/calls/history");

    final res = await http.get(uri, headers: {
      "x-user-id": widget.userId,
    });

    if (res.statusCode == 200) {
      setState(() {
        history = jsonDecode(res.body)["history"];
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Call History"),
        backgroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, i) {
                final item = history[i];
                return _historyItem(item);
              },
            ),
    );
  }

  Widget _historyItem(dynamic item) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item["call_type"] == "video" ? "Video Call" : "Voice Call",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            "Participants: ${item["participants"]}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "Names: ${item["names"].join(", ")}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            "Total Price: €${item["total_price"]}",
            style: const TextStyle(color: Colors.greenAccent),
          ),
          const SizedBox(height: 8),
          Text(
            "Duration: ${item["duration"]} minutes",
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
