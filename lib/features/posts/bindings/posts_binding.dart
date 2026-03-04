import 'package:get/get.dart';
import '../data/posts_service.dart';
import '../data/posts_repository.dart';
import '../controller/posts_controller.dart';

class PostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PostsService());
    Get.lazyPut(() => PostsRepository(Get.find()));
    Get.lazyPut(() => PostsController(Get.find()));
  }
}
