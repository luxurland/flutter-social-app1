import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api/api_service.dart';
import 'theme.dart';
import 'app_shell.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final api = ApiService("https://1.mod-mhsn.workers.dev/");
  bool darkMode = false;

  void toggleTheme() {
    setState(() {
      darkMode = !darkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Social App",
      theme: darkMode ? AppTheme.dark : AppTheme.light,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      home: AppShell(api: api),
    );
  }
}
