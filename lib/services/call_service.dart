import 'dart:convert';
import 'package:http/http.dart' as http;

class CallService {
  final String baseUrl;
  final String userId; // x-user-id from auth/session

  CallService({
    required this.baseUrl,
    required this.userId,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-user-id': userId,
      };

  // Start a call (5 minutes, voice or video)
  Future<Map<String, dynamic>> startCall({
    required String callType, // 'voice' or 'video'
  }) async {
    final uri = Uri.parse('$baseUrl/calls/start');

    final body = jsonEncode({
      'call_type': callType,
    });

    final res = await http.post(uri, headers: _headers, body: body);

    if (res.statusCode != 200) {
      throw Exception('Failed to start call: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw Exception('Start call error: ${data['error']}');
    }

    return data; // contains call_id, expires_at, charged
  }

  // Add a new participant to an existing call
  Future<Map<String, dynamic>> addParticipant({
    required String callId,
    required String newUserId,
  }) async {
    final uri = Uri.parse('$baseUrl/calls/add-participant');

    final body = jsonEncode({
      'call_id': callId,
      'new_user_id': newUserId,
    });

    final res = await http.post(uri, headers: _headers, body: body);

    if (res.statusCode != 200) {
      throw Exception('Failed to add participant: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw Exception('Add participant error: ${data['error']}');
    }

    return data; // contains extra_charged, total_price
  }

  // Extend call duration (15 / 30 / 60 minutes)
  Future<Map<String, dynamic>> extendCall({
    required String callId,
    required int durationMinutes, // 15, 30, or 60
  }) async {
    final uri = Uri.parse('$baseUrl/calls/extend');

    final body = jsonEncode({
      'call_id': callId,
      'duration': durationMinutes.toString(),
    });

    final res = await http.post(uri, headers: _headers, body: body);

    if (res.statusCode != 200) {
      throw Exception('Failed to extend call: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw Exception('Extend call error: ${data['error']}');
    }

    return data; // contains extra_charged, total_price, expires_at
  }

  // End call and finalize payout to owner
  Future<Map<String, dynamic>> endCall({
    required String callId,
  }) async {
    final uri = Uri.parse('$baseUrl/calls/end');

    final body = jsonEncode({
      'call_id': callId,
    });

    final res = await http.post(uri, headers: _headers, body: body);

    if (res.statusCode != 200) {
      throw Exception('Failed to end call: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data['success'] != true) {
      throw Exception('End call error: ${data['error']}');
    }

    return data; // contains total_collected
  }
}
