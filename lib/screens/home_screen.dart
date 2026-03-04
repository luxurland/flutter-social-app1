import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/post_card.dart';
import '../widgets/product_card.dart';
import 'create_post_screen.dart';
import 'create_product_post_screen.dart';
import 'user_post_screen.dart';
import 'merchant_post_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService api;
  const HomeScreen({super.key, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List posts = [];
  bool loading = true;

  Future<void> loadPosts() async {
    final res = await widget.api.get("/posts/home");
    setState(() {
      posts = res["posts"] ?? [];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  void openPost(Map post) {
    final publicId = post["public_id"];
    final kind = post["kind"];

    if (kind == "personal") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserPostScreen(
            api: widget.api,
            publicId: publicId,
          ),
        ),
      );
    } else if (kind == "merchant") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MerchantPostScreen(
            api: widget.api,
            publicId: publicId,
          ),
        ),
      );
    }
  }

  void openCreateMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text("Create Personal Post"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(api: widget.api),
                ),
              ).then((_) => loadPosts());
            },
          ),
          ListTile(
            title: const Text("Create Merchant Post"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateProductPostScreen(api: widget.api),
                ),
              ).then((_) => loadPosts());
            },
          ),
        ],
      ),
    );
  }

  Widget buildPostItem(Map post) {
    final username = post["username"] ?? "";
    final cid = post["cid"] ?? "";
    final publicId = post["public_id"] ?? "";
    final kind = post["kind"];

    if (kind == "personal") {
      return PostCard(
        username: username,
        cid: cid,
        publicId: publicId,
        onTap: () => openPost(post),
      );
    }

    return ProductCard(
      username: username,
      cid: cid,
      publicId: publicId,
      onTap: () => openPost(post),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Feed")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: openCreateMenu,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) => buildPostItem(posts[i]),
            ),
    );
  }
}
