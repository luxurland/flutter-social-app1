import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://flutter-social-app1.mod-mhsn.workers.dev";

  // Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // Load token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // Register user
  static Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse("$baseUrl/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  // Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (data["token"] != null) {
      await saveToken(data["token"]);
    }

    return data;
  }

  // Authenticated GET request
  static Future<Map<String, dynamic>> getAuth(String endpoint) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return jsonDecode(response.body);
  }

  // Authenticated POST request
  static Future<Map<String, dynamic>> postAuth(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }
}
