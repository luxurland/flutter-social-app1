import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller = Get.find();

  ProfileScreen({super.key});

  Widget _statItem(String label, RxInt value) {
    return Obx(() => Column(
          children: [
            Text(
              value.value.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label, style: TextStyle(color: Colors.grey)),
          ],
        ));
  }

  Widget _actionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color(0xFFF5F9FF),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF0B5FFF)),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.loadProfile();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            // Cover Photo
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0B5FFF),
                    Color(0xFF00C2D1),
                  ],
                ),
              ),
            ),

            // Avatar
            Transform.translate(
              offset: Offset(0, -40),
              child: Center(
                child: Obx(() {
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: controller.avatarUrl.value.isEmpty
                        ? Icon(Icons.person, size: 50, color: Color(0xFF0B5FFF))
                        : ClipOval(
                            child: Image.network(
                              controller.avatarUrl.value,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                  );
                }),
              ),
            ),

            SizedBox(height: -20),

            // Username + Bio
            Obx(() => Center(
                  child: Text(
                    controller.username.value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                )),
            SizedBox(height: 6),
            Obx(() => Center(
                  child: Text(
                    controller.bio.value,
                    style: TextStyle(color: Colors.grey),
                  ),
                )),

            SizedBox(height: 20),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem("Posts", controller.postsCount),
                _statItem("Products", controller.productsCount),
                _statItem("Calls", controller.callsCount),
                _statItem("Followers", controller.followersCount),
              ],
            ),

            SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _actionButton("Edit Profile", Icons.edit, () {}),
                  SizedBox(height: 10),
                  _actionButton("Wallet", Icons.account_balance_wallet,
                      () => Get.toNamed(AppRoutes.wallet)),
                  SizedBox(height: 10),
                  _actionButton("My Store", Icons.store,
                      () => Get.toNamed(AppRoutes.store)),
                  SizedBox(height: 10),
                  _actionButton("Settings", Icons.settings,
                      () => Get.toNamed(AppRoutes.settings)),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Tabs (Posts – Products – Activity)
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Color(0xFF0B5FFF),
                    labelColor: Color(0xFF0B5FFF),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.image), text: "Posts"),
                      Tab(icon: Icon(Icons.shopping_bag), text: "Products"),
                      Tab(icon: Icon(Icons.history), text: "Activity"),
                    ],
                  ),
                  Container(
                    height: 300,
                    child: TabBarView(
                      children: [
                        Center(child: Text("No posts yet")),
                        Center(child: Text("No products yet")),
                        Center(child: Text("No activity yet")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
