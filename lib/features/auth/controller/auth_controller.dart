import 'package:get/get.dart';
import '../../../api/api_service.dart';

class AuthController extends GetxController {
  final ApiService api;

  AuthController(this.api);

  var loading = false.obs;

  Future<bool> login(String email, String password) async {
    loading.value = true;

    try {
      final res = await api.post("auth/login", {
        "email": email,
        "password": password,
      });

      api.setToken(res["token"]);
      loading.value = false;
      return true;
    } catch (e) {
      loading.value = false;
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    loading.value = true;

    try {
      final res = await api.post("auth/register", {
        "email": email,
        "password": password,
      });

      api.setToken(res["token"]);
      loading.value = false;
      return true;
    } catch (e) {
      loading.value = false;
      return false;
    }
  }
}
