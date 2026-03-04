import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'create_post_screen.dart';
import 'create_product_post_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService api;
  const HomeScreen({super.key, required this.api});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List posts = [];
  bool loading = true;

  loadPosts() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Feed")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("user post"),
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
                  title: Text("merchant post"),
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
        },
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, i) {
                final p = posts[i];
                return Card(
                  margin: EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(p["username"] ?? ""),
                    subtitle: Text("CID: ${p["cid"]}"),
                    trailing: Text(p["kind"]),
                  ),
                );
              },
            ),
    );
  }
}
