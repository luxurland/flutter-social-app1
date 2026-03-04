import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  Widget _card(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.blueGrey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              "Welcome!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _card("Social Feed", Icons.people,
                    () => Get.toNamed(AppRoutes.personalFeed)),
                _card("Store", Icons.store,
                    () => Get.toNamed(AppRoutes.store)),
                _card("Calls", Icons.call,
                    () => Get.toNamed(AppRoutes.callLobby)),
                _card("Reports", Icons.report,
                    () => Get.toNamed(AppRoutes.reports)),
              ],
            ),

            SizedBox(height: 30),

            Text("Quick Access", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),

            ListTile(
              leading: Icon(Icons.history),
              title: Text("Call History"),
              onTap: () => Get.toNamed(AppRoutes.callHistory),
            ),

            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text("My Products"),
              onTap: () => Get.toNamed(AppRoutes.products),
            ),
          ],
        ),
      ),
    );
  }
}
