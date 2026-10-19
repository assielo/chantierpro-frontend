import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // Remplacement de dart:html par url_launcher

// Importation du service centralisé et du formulaire
import '../../services/api_service.dart';
import '../forms/chantier_form_screen.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  List<dynamic> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  // Récupération sécurisée des chantiers depuis l'API FastAPI
  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse('${ApiService.baseUrl}/projects'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );

      if (res.statusCode == 200) {
        setState(() {
          _projects = jsonDecode(res.body);
        });
      } else if (res.statusCode == 401) {
        // Token expiré ou invalide, redirection vers l'authentification
        ApiService.token = null;
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      }
    } catch (_) {
      // Gestion des erreurs réseau silencieuse
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Ouverture sécurisée du PDF via url_launcher (compatible multiplateforme)
  Future<void> _downloadPdfFromBackend(int projectId) async {
    final url = Uri.parse('${ApiService.baseUrl}/projects/$projectId/pdf');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Impossible d\'ouvrir le fichier PDF')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ouverture du PDF')),
        );
      }
    }
  }

  // Affichage des détails d'un chantier au clic
  void _showDetails(Map<String, dynamic> project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chantier : ${project['city']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre de pièces : ${project['num_rooms']}'),
            Text('Surface Terrain : ${project['land_surface']} m²'),
            Text('Surface Habitable : ${project['living_surface_m2']} m²'),
            const Divider(),
            Text('Sacs de ciment : ${project['ciment_sacs']} sacs'),
            Text('Main d\'œuvre : ${project['main_doeuvre_fcfa']} FCFA'),
            Text('Budget prévu : ${project['budget']} FCFA'),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _downloadPdfFromBackend(project['id']),
            icon: const Icon(Icons.download),
            label: const Text('PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'projects_list_fab',
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          // On attend le retour du formulaire de création en lui passant les paramètres requis
          final bool? created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChantierFormScreen(
                projectId:
                    0, // Ajustez selon votre logique (0 ou ID par défaut)
                token: ApiService.token ?? '',
              ),
            ),
          );

          // Si le chantier a été enregistré avec succès, on rafraîchit la liste
          if (created == true) {
            _fetch();
          }
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(
                  child: Text('Aucun chantier enregistré pour le moment.'),
                )
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _projects.length,
                    itemBuilder: (context, i) {
                      final p = _projects[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading:
                              const Icon(Icons.business, color: Colors.amber),
                          title:
                              Text('${p['city']} - ${p['num_rooms']} pièces'),
                          subtitle: Text(
                              'Ciment: ${p['ciment_sacs']} sacs | M.O: ${p['main_doeuvre_fcfa']} FCFA'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showDetails(p),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
