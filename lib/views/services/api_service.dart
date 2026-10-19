import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // NE PAS mettre /v1/auth ici
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static String? token;

  // Obtenir les en-têtes (headers) avec le token si disponible
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Requête GET
  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _headers);
  }

  // Requête POST
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: _headers, body: jsonEncode(data));
  }
}
