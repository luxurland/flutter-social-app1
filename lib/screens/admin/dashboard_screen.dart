import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class DashboardScreen extends StatelessWidget {
  final ApiService api;
  const DashboardScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: FutureBuilder(
        future: api.get("/moderator/dashboard"),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final d = snap.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text("Users: ${d["users"]}"),
              Text("Personal Posts: ${d["personal_posts"]}"),
              Text("Merchant Posts: ${d["merchant_posts"]}"),
              Text("Pending Reports: ${d["pending_reports"]}"),
            ],
          );
        },
      ),
    );
  }
}
