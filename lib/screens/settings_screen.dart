import 'package:flutter/material.dart';
import '../api/api_service.dart';

class SettingsScreen extends StatelessWidget {
  final ApiService api;
  const SettingsScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Privacy"),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text("Payments"),
          ),
        ],
      ),
    );
  }
}
