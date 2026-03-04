import 'package:get/get.dart';
import '../../../api/api_service.dart';

class ProfileController extends GetxController {
  final ApiService api = Get.find();

  var username = "".obs;
  var bio = "".obs;
  var avatarUrl = "".obs;
  var coverUrl = "".obs;

  var postsCount = 0.obs;
  var productsCount = 0.obs;
  var callsCount = 0.obs;
  var followersCount = 0.obs;

  Future<void> loadProfile() async {
    final res = await api.get("user/me");

    username.value = res["username"] ?? "User";
    bio.value = res["bio"] ?? "";
    avatarUrl.value = res["avatar"] ?? "";
    coverUrl.value = res["cover"] ?? "";

    postsCount.value = res["posts"] ?? 0;
    productsCount.value = res["products"] ?? 0;
    callsCount.value = res["calls"] ?? 0;
    followersCount.value = res["followers"] ?? 0;
  }
}
