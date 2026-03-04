import 'package:get/get.dart';
import '../../../api/api_service.dart';

class SocialController extends GetxController {
  final ApiService api = Get.find();

  var posts = [].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    loading.value = true;
    final res = await api.get("posts");
    posts.value = res;
    loading.value = false;
  }
}
