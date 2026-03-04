import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController controller = Get.find();

  SettingsScreen({super.key});

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF0B5FFF)),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        elevation: 0,
      ),
      body: ListView(
        children: [
          _sectionTitle("Appearance"),
          Obx(() => SwitchListTile(
                title: Text("Dark Mode"),
                secondary: Icon(Icons.dark_mode, color: Color(0xFF0B5FFF)),
                value: controller.darkMode.value,
                onChanged: (v) => controller.toggleDarkMode(),
              )),

          _sectionTitle("Preferences"),
          Obx(() => _settingTile(
                icon: Icons.language,
                title: "Language",
                subtitle: controller.language.value,
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Get.theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text("English"),
                            onTap: () {
                              controller.changeLanguage("English");
                              Get.back();
                            },
                          ),
                          ListTile(
                            title: Text("Arabic"),
                            onTap: () {
                              controller.changeLanguage("Arabic");
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),

          _sectionTitle("Privacy"),
          _settingTile(
            icon: Icons.lock,
            title: "Privacy Settings",
            onTap: () {},
          ),

          _sectionTitle("Account"),
          _settingTile(
            icon: Icons.person,
            title: "Account Info",
            onTap: () {},
          ),
          _settingTile(
            icon: Icons.logout,
            title: "Logout",
            onTap: () => controller.logout(),
          ),

          _sectionTitle("App Info"),
          _settingTile(
            icon: Icons.info,
            title: "About App",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
