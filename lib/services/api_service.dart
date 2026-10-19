import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // NE PAS mettre /v1/auth ici
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static String? token;

  // Headers avec le token s'il existe
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Méthode POST requise par AuthService
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: _headers, body: jsonEncode(data));
  }

  // Méthode GET
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _headers);
  }
}
