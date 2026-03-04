import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class ReportsScreen extends StatefulWidget {
  final ApiService api;
  const ReportsScreen({super.key, required this.api});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List reports = [];
  bool loading = true;

  Future<void> loadReports() async {
    final res = await widget.api.get("/admin/reports");
    setState(() {
      reports = res["reports"] ?? [];
      loading = false;
    });
  }

  Future<void> resolveReport(int id) async {
    await widget.api.post("/admin/reports/$id/resolve", {});
    loadReports();
  }

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: reports.map((r) {
                return Card(
                  child: ListTile(
                    title: Text("Post: ${r["post_public_id"]}"),
                    subtitle: Text("Reason: ${r["reason"]}"),
                    trailing: ElevatedButton(
                      onPressed: () => resolveReport(r["id"]),
                      child: const Text("Resolve"),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
