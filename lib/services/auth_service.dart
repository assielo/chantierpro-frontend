import 'dart:convert';

import 'api_service.dart';

class AuthService {
  // Méthode de connexion
  Future<bool> login(String email, String password) async {
    try {
      // Remplacez '/v1/auth/login' ou '/login' selon l'URL exacte de votre backend Laravel
      final response = await ApiService.post('/v1/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Stockage du token reçu dans ApiService
        ApiService.token = data['token'] ?? data['access_token'];
        return true;
      } else {
        print(
          'Erreur d\'authentification : ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Erreur lors de la requête de connexion : $e');
      return false;
    }
  }

  // Récupération du token
  Future<String?> getToken() async {
    return ApiService.token;
  }
}
