import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Importation du service centralisé
import '../../services/api_service.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({super.key});

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  List<dynamic> _logs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  // Récupération des entrées du journal depuis l'API FastAPI
  Future<void> _fetchLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/logs'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _logs = jsonDecode(response.body);
        });
      } else if (response.statusCode == 401) {
        ApiService.token = null;
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      } else {
        setState(() => _error = 'Erreur lors du chargement du journal');
      }
    } catch (e) {
      setState(() => _error = 'Erreur de connexion au serveur');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Boîte de dialogue pour ajouter une entrée au journal
  void _addLog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle entrée au Journal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Titre / Événement'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration:
                  const InputDecoration(labelText: 'Description détaillée'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(context);
                try {
                  final response = await http.post(
                    Uri.parse('${ApiService.baseUrl}/logs'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer ${ApiService.token}',
                    },
                    body: jsonEncode({
                      'title': titleController.text.trim(),
                      'description': descController.text.trim(),
                    }),
                  );
                  if (response.statusCode == 201 ||
                      response.statusCode == 200) {
                    _fetchLogs();
                  }
                } catch (e) {
                  // Gestion d'erreur silencieuse
                }
              }
            },
            child: const Text('Ajouter'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'log_fab', // Tag unique pour éviter le conflit Hero
        onPressed: _addLog,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add_comment, color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _logs.isEmpty
                  ? const Center(
                      child:
                          Text('Aucune entrée dans le journal pour le moment.'))
                  : RefreshIndicator(
                      onRefresh: _fetchLogs,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: const Icon(Icons.menu_book,
                                  color: Colors.amber),
                              title: Text(log['title'] ?? ''),
                              subtitle: Text(log['description'] ?? ''),
                              trailing: Text(
                                log['date'] != null
                                    ? log['date'].toString().substring(0, 10)
                                    : '',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
