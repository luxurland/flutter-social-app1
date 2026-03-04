import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'post_viewer.dart';
import 'merchant_post_viewer.dart';

class FeedScreen extends StatefulWidget {
  final ApiService api;
  const FeedScreen({super.key, required this.api});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  PageController controller = PageController();
  List posts = [];
  bool loading = true;

  Future<void> loadFeed() async {
    final res = await widget.api.get("/posts/feed");
    setState(() {
      posts = res["posts"] ?? [];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadFeed();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (posts.isEmpty) {
      return const Center(child: Text("No posts yet"));
    }

    return PageView.builder(
      controller: controller,
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      itemBuilder: (_, i) {
        final p = posts[i];
        final kind = p["kind"];

        if (kind == "merchant") {
          return MerchantPostViewer(
            api: widget.api,
            post: p,
          );
        }

        return PostViewer(
          api: widget.api,
          post: p,
        );
      },
    );
  }
}
