import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String? token;

  ApiService(this.baseUrl);

  Map<String, String> get headers {
    final h = {"Content-Type": "application/json"};
    if (token != null) h["Authorization"] = "Bearer $token";
    return h;
  }

  Future<Map<String, dynamic>> post(String path, Map body) async {
    final res = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: headers,
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: headers,
    );
    return jsonDecode(res.body);
  }
}
