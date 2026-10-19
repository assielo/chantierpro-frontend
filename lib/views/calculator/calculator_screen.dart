import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Exemple de projectId (à adapter selon votre logique métier)
  final int projectId = 1;

  // Méthode de téléchargement du PDF intégrée dans le State (ce qui donne accès à `context` et `mounted`)
  Future<void> _downloadPdfFromBackend(int projectId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Construction de l'URL
    final url = Uri.parse(
        '${ApiService.baseUrl}/api/v1/projects/$projectId/download-estimate');

    try {
      // Si votre route Laravel nécessite un token et que vous ouvrez via launchUrl,
      // vous pouvez passer le token en paramètre d'URL (query parameter) si l'API le supporte,
      // ex: url.replace(queryParameters: {'token': token})

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Impossible d\'ouvrir le lien de téléchargement du PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ouverture du PDF : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculateur et Devis'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _downloadPdfFromBackend(projectId),
          icon: const Icon(Icons.download),
          label: const Text('Télécharger le Devis PDF'),
        ),
      ),
    );
  }
}
