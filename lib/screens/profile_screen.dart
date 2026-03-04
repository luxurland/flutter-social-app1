import 'package:flutter/material.dart';
import '../api/api_service.dart';

class ProfileScreen extends StatelessWidget {
  final ApiService api;
  const ProfileScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder(
        future: api.get("/auth/me"),
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snap.data!["user"];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text("Username: ${user["username"]}"),
              Text("Role: ${user["role"]}"),
              Text("User HEX ID: ${user["user_hex_id"]}"),
            ],
          );
        },
      ),
    );
  }
}
