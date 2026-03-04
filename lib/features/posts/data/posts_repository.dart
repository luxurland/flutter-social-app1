import 'posts_service.dart';

class PostsRepository {
  final PostsService service;
  PostsRepository(this.service);

  Future<int> createPersonal(
      String publicId, String postHexId, String cid, String type) async {
    final data = await service.createPersonal(publicId, postHexId, cid, type);
    return data["post_id"];
  }

  Future<List<dynamic>> personalFeed() => service.personalFeed();
  Future<void> hidePersonal(int id) => service.hidePersonal(id);

  Future<int> createProductPost(
      String publicId, String postHexId, int productId, String cid, String type) async {
    final data =
        await service.createProductPost(publicId, postHexId, productId, cid, type);
    return data["post_id"];
  }

  Future<List<dynamic>> productFeed() => service.productFeed();
  Future<void> hideProductPost(int id) => service.hideProductPost(id);
}
