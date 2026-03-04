import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'user_profile_screen.dart';
import 'friends_screen.dart';
import 'settings_screen.dart';
import 'chat_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ApiService api;
  const ProfileScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: api.get("/auth/me"),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snap.data!["user"];
        final userId = user["id"].toString();

        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(api: api),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ListTile(
                title: Text(user["username"]),
                subtitle: Text("Role: ${user["role"]}"),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("View my profile"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(
                        api: api,
                        userId: userId,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.group),
                title: const Text("Friends"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendsScreen(api: api),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text("Chats"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatListScreen(api: api),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
