import 'call_service.dart';

class CallRepository {
  final CallService service;

  CallRepository(this.service);

  Future<int> startCall(String type, int minutes) async {
    final data = await service.startCall(type, minutes);
    return data["call_id"];
  }

  Future<void> joinCall(int callId) async {
    await service.addParticipant(callId);
  }

  Future<DateTime> extendCall(int callId, int minutes) async {
    final data = await service.extendCall(callId, minutes);
    return DateTime.parse(data["expires_at"]);
  }

  Future<void> endCall(int callId) async {
    await service.endCall(callId);
  }

  Future<List<dynamic>> history() async {
    return await service.getCallHistory();
  }
}
