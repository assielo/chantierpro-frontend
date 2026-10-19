import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Récupérer le token stocké
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // En-têtes HTTP avec authentification Bearer
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Authentification ---
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] ?? data['access_token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
      }
      return data;
    } else {
      throw Exception('Échec de la connexion : ${response.body}');
    }
  }

  // --- Réserves & Anomalies ---
  static Future<List<dynamic>> getReserves(int projectId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId/reserves'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des réserves');
    }
  }

  static Future<void> createReserve(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/reserves'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de la création de la réserve');
    }
  }

  static Future<void> updateReserveStatus(int reserveId, String status) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/reserves/$reserveId/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour du statut');
    }
  }

  // --- Journal de Chantier ---
  static Future<void> saveJournal(
      int projectId, Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/projects/$projectId/journals'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de l\'enregistrement du journal');
    }
  }

  static Future<void> createDailyLog(
      int projectId, Map<String, dynamic> data) async {
    return saveJournal(projectId, data);
  }

  // --- Devis & Estimations ---
  static Future<Map<String, dynamic>> calculateEstimate(
      Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/estimates/calculate'),
      headers: headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du calcul du devis');
    }
  }

  static Future<void> downloadEstimatePdf(int estimateId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/estimates/$estimateId/pdf'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du téléchargement du PDF');
    }
  }
}
