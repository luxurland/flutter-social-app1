import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final ApiService api;
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.api,
    required this.email,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final codeCtrl = TextEditingController();
  bool loading = false;

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> verify() async {
    if (codeCtrl.text.trim().isEmpty) {
      showError("Enter the code");
      return;
    }

    setState(() => loading = true);

    final res = await widget.api.post("/auth/verify-email", {
      "email": widget.email,
      "code": codeCtrl.text.trim(),
    });

    setState(() => loading = false);

    if (res["success"] == true) {
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      showError(res["error"] ?? "Verification failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify email")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "We sent a code to ${widget.email}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Verification code",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : verify,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Verify"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
