import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Exemple : Sauvegarder un token d'authentification
  static Future<void> setAuthToken(String token) async {
    await _preferences.setString('auth_token', token);
  }

  static String? getAuthToken() {
    return _preferences.getString('auth_token');
  }

  // Nettoyer lors de la déconnexion
  static Future<void> clear() async {
    await _preferences.clear();
  }
}