import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final ApiService api;
  const LoginScreen({super.key, required this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  login() async {
    setState(() => loading = true);

    final res = await widget.api.post("/auth/login", {
      "username": userCtrl.text,
      "password": passCtrl.text,
    });

    setState(() => loading = false);

    if (res["token"] != null) {
      widget.api.token = res["token"];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(api: widget.api),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["error"] ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Welcome", style: TextStyle(fontSize: 32)),
              SizedBox(height: 20),
              TextField(
                controller: userCtrl,
                decoration: InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: passCtrl,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Login"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
