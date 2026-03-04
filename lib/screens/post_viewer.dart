import 'package:flutter/material.dart';
import '../api/api_service.dart';

class PostViewer extends StatelessWidget {
  final ApiService api;
  final Map post;

  const PostViewer({
    super.key,
    required this.api,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final username = post["username"] ?? "";
    final cid = post["cid"] ?? "";
    final publicId = post["public_id"] ?? "";

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: Text(
              "Content from CID:\n$cid",
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 32,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "@$username",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Post ID: $publicId",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
