import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/post_card.dart';
import '../widgets/product_card.dart';

class UserProfileScreen extends StatefulWidget {
  final ApiService api;
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.api,
    required this.userId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map? user;
  List posts = [];
  List taggedPosts = [];
  List products = [];
  bool loading = true;
  int tabIndex = 0;

  Future<void> loadProfile() async {
    final u = await widget.api.get("/users/${widget.userId}");
    final p = await widget.api.get("/users/${widget.userId}/posts");
    final t = await widget.api.get("/users/${widget.userId}/tagged");
    final pr = await widget.api.get("/users/${widget.userId}/products");

    setState(() {
      user = u["user"];
      posts = p["posts"] ?? [];
      taggedPosts = t["posts"] ?? [];
      products = pr["products"] ?? [];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user!["username"]),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(user!["username"]),
            subtitle: Text("Friends: ${user!["friends_count"] ?? 0}"),
          ),
          const Divider(),
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).hintColor,
            indicatorColor: Theme.of(context).colorScheme.primary,
            onTap: (i) => setState(() => tabIndex = i),
            tabs: const [
              Tab(icon: Icon(Icons.grid_on), text: "Posts"),
              Tab(icon: Icon(Icons.person_pin), text: "Tagged"),
              Tab(icon: Icon(Icons.shopping_bag), text: "Products"),
            ],
            controller: DefaultTabController.of(context),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              initialIndex: tabIndex,
              child: TabBarView(
                children: [
                  ListView(
                    children: posts
                        .map((p) => PostCard(
                              username: p["username"] ?? "",
                              cid: p["cid"] ?? "",
                              publicId: p["public_id"] ?? "",
                              onTap: () {},
                            ))
                        .toList(),
                  ),
                  ListView(
                    children: taggedPosts
                        .map((p) => PostCard(
                              username: p["username"] ?? "",
                              cid: p["cid"] ?? "",
                              publicId: p["public_id"] ?? "",
                              onTap: () {},
                            ))
                        .toList(),
                  ),
                  ListView(
                    children: products
                        .map((p) => ProductCard(
                              username: user!["username"],
                              cid: p["cid"] ?? "",
                              publicId: p["public_id"] ?? "",
                              onTap: () {},
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
