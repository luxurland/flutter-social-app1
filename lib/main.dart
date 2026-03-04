import 'package:flutter/material.dart';
import 'api/api_service.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final api = ApiService("https://1.mod-mhsn.workers.dev/");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Social App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(api: api),
    );
  }
}
