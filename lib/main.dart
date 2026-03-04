import 'package:flutter/material.dart';
import 'api/api_service.dart';
import 'theme.dart';
import 'app_shell.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final api = ApiService("https://YOUR_WORKER_URL");
  bool darkMode = false;

  void toggleTheme() {
    setState(() {
      darkMode = !darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Social App",
      theme: darkMode ? AppTheme.dark : AppTheme.light,
      home: AppShell(api: api),
    );
  }
}
