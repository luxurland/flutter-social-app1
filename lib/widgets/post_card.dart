import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String username;
  final String cid;
  final String publicId;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.username,
    required this.cid,
    required this.publicId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(username),
        subtitle: Text("CID: $cid"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
