import 'package:get/get.dart';
import '../data/call_repository.dart';

class CallController extends GetxController {
  final CallRepository repo;

  CallController(this.repo);

  var callId = 0.obs;
  var expiresAt = Rxn<DateTime>();
  var isInCall = false.obs;

  Future<void> startCall(String type, int minutes) async {
    callId.value = await repo.startCall(type, minutes);
    isInCall.value = true;
  }

  Future<void> joinCall() async {
    await repo.joinCall(callId.value);
  }

  Future<void> extend(int minutes) async {
    expiresAt.value = await repo.extendCall(callId.value, minutes);
  }

  Future<void> end() async {
    await repo.endCall(callId.value);
    isInCall.value = false;
  }

  Future<List<dynamic>> history() async {
    return await repo.history();
  }
}
