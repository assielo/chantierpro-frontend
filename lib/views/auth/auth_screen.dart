import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Importation du service centralisé et du tableau de bord
import '../../services/api_service.dart';
import '../dashboard/dashboard_view.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  // Fonction de connexion gérée proprement avec un payload JSON
  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // CORRECTION : Correspond à la route Laravel /api/login
      final response = await http.post(
        // On écrit l'URL complète et directe pour éviter les erreurs de préfixe
        Uri.parse('http://127.0.0.1:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Sécurisation de la récupération du token
        String? token = data['access_token'] ?? data['token'];

        if (token == null) {
          setState(() {
            _error = 'Erreur : Token introuvable dans la réponse du serveur.';
          });
          return;
        }

        ApiService.token = token;

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardView(projectId: 1, token: token),
            ),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error =
              data['message'] ??
              'Identifiants incorrects (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion au serveur : $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ChantierPro Connexion',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A), // Bleu nuit corporate
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilotez vos chantiers en toute simplicité',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: const TextStyle(color: Color(0xFFDC2626)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SE CONNECTER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
