import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  Widget _quickAction(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B5FFF),
              Color(0xFF00C2D1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _placeholderCard(String title) {
    return Container(
      height: 120,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE0E7FF)),
      ),
      child: Center(
        child: Text(title, style: TextStyle(fontSize: 16, color: Colors.grey)),
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
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0B5FFF),
                    Color(0xFF00C2D1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Color(0xFF0B5FFF)),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome back!",
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text("User Name",
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.notifications),
                    child: Icon(Icons.notifications, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Quick Actions
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _quickAction("Social", Icons.people,
                    () => Get.toNamed(AppRoutes.personalFeed)),
                _quickAction("Store", Icons.store,
                    () => Get.toNamed(AppRoutes.store)),
                _quickAction("Calls", Icons.call,
                    () => Get.toNamed(AppRoutes.callLobby)),
                _quickAction("Wallet", Icons.account_balance_wallet,
                    () => Get.toNamed(AppRoutes.wallet)),
              ],
            ),

            SizedBox(height: 20),

            _sectionTitle("Latest Posts"),
            _placeholderCard("No posts yet"),

            _sectionTitle("Latest Products"),
            _placeholderCard("No products yet"),

            _sectionTitle("Recent Calls"),
            _placeholderCard("No calls yet"),
          ],
        ),
      ),
    );
  }
}
