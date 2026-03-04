import 'package:get/get.dart';

class ProfileController extends GetxController {
  var username = "User Name".obs;
  var bio = "This is your bio. Add something about yourself.".obs;
  var avatarUrl = "".obs;
  var coverUrl = "".obs;

  var postsCount = 0.obs;
  var productsCount = 0.obs;
  var callsCount = 0.obs;
  var followersCount = 0.obs;

  Future<void> loadProfile() async {
    // TODO: ربط مع API /user/me
  }
}
