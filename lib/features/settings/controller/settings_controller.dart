import 'package:get/get.dart';

class SettingsController extends GetxController {
  var darkMode = false.obs;
  var language = "English".obs;

  void toggleDarkMode() {
    darkMode.value = !darkMode.value;
  }

  void changeLanguage(String lang) {
    language.value = lang;
  }

  void logout() {
    // TODO: حذف الـ JWT + الانتقال لشاشة تسجيل الدخول
  }
}
