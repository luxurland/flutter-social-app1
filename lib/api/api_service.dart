import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String? token;

  ApiService(this.baseUrl);

  void setToken(String t) {
    token = t;
  }

  Future<dynamic> get(String endpoint) async {
    final res = await http.get(
      Uri.parse(baseUrl + endpoint),
      headers: _headers(),
    );
    return _handleResponse(res);
  }

  Future<dynamic> post(String endpoint, Map body) async {
    final res = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  dynamic _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    } else {
      throw Exception("API Error: ${res.body}");
    }
  }
}
