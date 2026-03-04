import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api/api_service.dart';
import 'routes/app_routes.dart';
import 'features/home/ui/home_dashboard_screen.dart';

class AppShell extends StatefulWidget {
  final ApiService api;

  const AppShell({super.key, required this.api});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeDashboardScreen(),
    // Social Feed
    GetRouterOutlet(initialRoute: AppRoutes.personalFeed),
    // Store
    GetRouterOutlet(initialRoute: AppRoutes.store),
    // Calls
    GetRouterOutlet(initialRoute: AppRoutes.callLobby),
    // Profile placeholder
    Center(child: Text("Profile Coming Soon")),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Social App"),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Center(
                child: Text(
                  "Menu",
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.report),
              title: Text("Reports"),
              onTap: () => Get.toNamed(AppRoutes.reports),
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.help),
              title: Text("Help"),
              onTap: () {},
            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Social"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Store"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
