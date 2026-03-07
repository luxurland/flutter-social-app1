import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Updated base URL
  static const String baseUrl = "https://flutter-social-app1.luxurland.workers.dev";

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

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Register user
  static Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode >= 400) {
        return {
          'error': data['error'] ?? 'Registration failed',
          'statusCode': response.statusCode,
          'success': false,
        };
      }

      // Auto login after registration (optional)
      if (data['token'] != null) {
        await saveToken(data['token']);
      }

      return {...data, 'success': true};
    } catch (e) {
      return {
        'error': 'Network error: $e',
        'statusCode': 500,
        'success': false,
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 400) {
        return {
          'error': data['error'] ?? 'Login failed',
          'statusCode': response.statusCode,
          'success': false,
        };
      }

      if (data["token"] != null) {
        await saveToken(data["token"]);
      }

      return {...data, 'success': true};
    } catch (e) {
      return {
        'error': 'Network error: $e',
        'statusCode': 500,
        'success': false,
      };
    }
  }

  // Authenticated GET request
  static Future<Map<String, dynamic>> getAuth(String endpoint) async {
    final token = await getToken();
    
    if (token == null) {
      return {
        'error': 'No authentication token found',
        'statusCode': 401,
        'success': false,
      };
    }
    
    final url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);
      
      // If token expired, clear it
      if (response.statusCode == 401) {
        await logout();
        return {
          'error': 'Token expired',
          'statusCode': 401,
          'success': false,
        };
      }
      
      if (response.statusCode >= 400) {
        return {
          'error': data['error'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'success': false,
        };
      }

      return {...data, 'success': true};
    } catch (e) {
      return {
        'error': 'Network error: $e',
        'statusCode': 500,
        'success': false,
      };
    }
  }

  // Authenticated POST request
  static Future<Map<String, dynamic>> postAuth(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    
    if (token == null) {
      return {
        'error': 'No authentication token found',
        'statusCode': 401,
        'success': false,
      };
    }
    
    final url = Uri.parse("$baseUrl$endpoint");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      
      // If token expired, clear it
      if (response.statusCode == 401) {
        await logout();
        return {
          'error': 'Token expired',
          'statusCode': 401,
          'success': false,
        };
      }
      
      if (response.statusCode >= 400) {
        return {
          'error': data['error'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'success': false,
        };
      }

      return {...data, 'success': true};
    } catch (e) {
      return {
        'error': 'Network error: $e',
        'statusCode': 500,
        'success': false,
      };
    }
  }
}
