import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class ReservesScreen extends StatefulWidget {
  const ReservesScreen({super.key});

  @override
  State<ReservesScreen> createState() => _ReservesScreenState();
}

class _ReservesScreenState extends State<ReservesScreen> {
  List<dynamic> _projects = [];
  List<dynamic> _reserves = [];
  int? _selectedProjectId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/projects'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _projects = jsonDecode(response.body);
          if (_projects.isNotEmpty) {
            _selectedProjectId = _projects[0]['id'];
            _fetchReserves(_selectedProjectId!);
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement chantiers : $e');
    }
  }

  Future<void> _fetchReserves(int projectId) async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/projects/$projectId/reserves'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _reserves = jsonDecode(response.body);
        });
      } else {
        setState(() => _reserves = []);
      }
    } catch (e) {
      debugPrint('Erreur chargement réserves : $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showAddReserveDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedStatus = 'Ouverte';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Signalement d\'une Réserve / Anomalie'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                      labelText: 'Titre de l\'anomalie (ex: Fissure mur R+1)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Description et localisation précise'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration:
                      const InputDecoration(labelText: 'Statut initial'),
                  items: ['Ouverte', 'En cours', 'Résolue']
                      .map((status) =>
                          DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedStatus = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _createReserve(
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                  selectedStatus,
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  foregroundColor: Colors.white),
              child: const Text('Signaler'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createReserve(
      String title, String description, String status) async {
    if (_selectedProjectId == null) return;
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/v1/reserves'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({
          'project_id': _selectedProjectId,
          'title': title,
          'description': description,
          'status': status,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _fetchReserves(_selectedProjectId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réserve signalée avec succès !')),
        );
      }
    } catch (e) {
      debugPrint('Erreur création réserve : $e');
    }
  }

  Future<void> _updateReserveStatus(int reserveId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiService.baseUrl}/api/v1/reserves/$reserveId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        if (_selectedProjectId != null) {
          _fetchReserves(_selectedProjectId!);
        }
      }
    } catch (e) {
      debugPrint('Erreur mise à jour statut : $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Résolue':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Levées de Réserves & Anomalies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed:
                    _selectedProjectId == null ? null : _showAddReserveDialog,
                icon: const Icon(Icons.add_alert),
                label: const Text('Signaler une réserve'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_projects.isNotEmpty)
            DropdownButtonFormField<int>(
              value: _selectedProjectId,
              decoration: const InputDecoration(
                labelText: 'Sélectionner le Chantier',
                border: OutlineInputBorder(),
              ),
              items: _projects
                  .map((p) => DropdownMenuItem<int>(
                        value: p['id'],
                        child: Text('Chantier #${p['id']} - ${p['city']}'),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedProjectId = val);
                if (val != null) _fetchReserves(val);
              },
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _reserves.isEmpty
                    ? const Center(
                        child: Text('Aucune réserve signalée sur ce chantier.'))
                    : ListView.builder(
                        itemCount: _reserves.length,
                        itemBuilder: (context, index) {
                          final item = _reserves[index];
                          final String status = item['status'] ?? 'Ouverte';

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getStatusColor(status).withOpacity(0.2),
                                child: Icon(Icons.warning_amber,
                                    color: _getStatusColor(status)),
                              ),
                              title: Text(
                                item['title'] ?? 'Anomalie sans titre',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  item['description'] ?? 'Aucune description'),
                              trailing: PopupMenuButton<String>(
                                initialValue: status,
                                onSelected: (newStatus) {
                                  _updateReserveStatus(item['id'], newStatus);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                      value: 'Ouverte', child: Text('Ouverte')),
                                  const PopupMenuItem(
                                      value: 'En cours',
                                      child: Text('En cours')),
                                  const PopupMenuItem(
                                      value: 'Résolue', child: Text('Résolue')),
                                ],
                                child: Chip(
                                  label: Text(status,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  backgroundColor: _getStatusColor(status),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
