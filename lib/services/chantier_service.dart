import 'dart:convert';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class ChantierService {
  final String token;
  // Remplacez par l'URL de votre API backend
  final String baseUrl = 'http://127.0.0.1:8000/api';

  class ChantierService {
  // Remplacez par l'URL de votre API Laravel (ex: 10.0.2.2 pour l'émulateur Android, ou localhost pour le Web)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  final AuthService _authService = AuthService();

  // Récupérer les statistiques et la liste des chantiers
  Future<Map<String, dynamic>> getDashboardData() async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'), // Route Laravel à configurer
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Échec de la récupération des données du tableau de bord');
    }
  }
}

  Future<void> createDailyLog(int projectId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects/$projectId/journals'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de l\'enregistrement du journal');
    }
  }

  Future<void> createReserve(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reserves'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de la création de la réserve');
    }
  }

  Future<void> updateReserveStatus(int reserveId, String status) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/reserves/$reserveId/status'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour du statut');
    }
  }

  // --- Journal de Chantier ---
  Future<void> saveJournal(int projectId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects/$projectId/journals'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Erreur lors de l\'enregistrement du journal');
    }
  }

  // --- Devis & Estimations ---
  Future<Map<String, dynamic>> calculateEstimate(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/estimates/calculate'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du calcul du devis');
    }
  }

  Future<void> downloadEstimatePdf(int estimateId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/estimates/$estimateId/pdf'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors du téléchargement du PDF');
    }
    // Gérer l'ouverture ou l'enregistrement du PDF selon vos besoins
  }
}
