import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widgets/post_card.dart';

class TaggedPostsScreen extends StatefulWidget {
  final ApiService api;
  final String userId;

  const TaggedPostsScreen({
    super.key,
    required this.api,
    required this.userId,
  });

  @override
  State<TaggedPostsScreen> createState() => _TaggedPostsScreenState();
}

class _TaggedPostsScreenState extends State<TaggedPostsScreen> {
  List posts = [];
  bool loading = true;

  Future<void> loadTagged() async {
    final res = await widget.api.get("/tags/user/${widget.userId}");
    setState(() {
      posts = res["posts"] ?? [];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTagged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tagged posts")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: posts
                  .map((p) => PostCard(
                        username: p["username"] ?? "",
                        cid: p["cid"] ?? "",
                        publicId: p["public_id"] ?? "",
                        onTap: () {},
                      ))
                  .toList(),
            ),
    );
  }
}
