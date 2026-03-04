import 'package:get/get.dart';
import '../data/posts_repository.dart';

class PostsController extends GetxController {
  final PostsRepository repo;
  PostsController(this.repo);

  var personal = <dynamic>[].obs;
  var products = <dynamic>[].obs;
  var loadingPersonal = false.obs;
  var loadingProducts = false.obs;

  Future<void> loadPersonal() async {
    loadingPersonal.value = true;
    personal.value = await repo.personalFeed();
    loadingPersonal.value = false;
  }

  Future<void> loadProductPosts() async {
    loadingProducts.value = true;
    products.value = await repo.productFeed();
    loadingProducts.value = false;
  }

  Future<void> hidePersonalPost(int id) async {
    await repo.hidePersonal(id);
    personal.removeWhere((p) => p["id"] == id);
  }

  Future<void> hideProductPost(int id) async {
    await repo.hideProductPost(id);
    products.removeWhere((p) => p["id"] == id);
  }
}
