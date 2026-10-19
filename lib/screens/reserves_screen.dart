import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/chantier_service.dart';

class ReservesScreen extends StatefulWidget {
  final int projectId;

  const ReservesScreen({super.key, required this.projectId});

  @override
  State<ReservesScreen> createState() => _ReservesScreenState();
}

class _ReservesScreenState extends State<ReservesScreen> {
  late Future<List<dynamic>> _reservesFuture;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadReserves();
  }

  void _loadReserves() {
    setState(() {
      _reservesFuture = _fetchReservesData();
    });
  }

  Future<List<dynamic>> _fetchReservesData() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Utilisateur non authentifié');
    }
    final chantierService = ChantierService(token);
    return await chantierService.getReserves(widget.projectId);
  }

  void _showAddReserveModal() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedStatus = 'Ouverte';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateModal) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Signaler une nouvelle réserve / anomalie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre de l\'anomalie',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description détaillée',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Statut initial',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Ouverte', 'En cours', 'Résolue']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setStateModal(() {
                        selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () async {
                    if (titleController.text.isNotEmpty) {
                      try {
                        final token = await _authService.getToken();
                        if (token == null) {
                          throw Exception('Utilisateur non authentifié');
                        }
                        final chantierService = ChantierService(token);

                        await chantierService.createReserve({
                          'project_id': widget.projectId,
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'status': selectedStatus,
                        });

                        if (mounted) {
                          Navigator.pop(context);
                          _loadReserves();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Réserve enregistrée avec succès !'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Erreur : $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Enregistrer la réserve',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Résolue':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'Ouverte':
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserves & Anomalies du Chantier'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _reservesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Aucune réserve signalée pour ce projet.'),
            );
          }

          final reserves = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: reserves.length,
            itemBuilder: (context, index) {
              final reserve = reserves[index];
              final String status = reserve['status'] ?? 'Ouverte';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    reserve['title'] ?? 'Anomalie',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(reserve['description'] ?? 'Aucune description'),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(status,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: _getStatusColor(status),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'Ouverte', child: Text('Marquer Ouverte')),
                      const PopupMenuItem(
                          value: 'En cours', child: Text('Marquer En cours')),
                      const PopupMenuItem(
                          value: 'Résolue', child: Text('Marquer Résolue')),
                    ],
                    onSelected: (newStatus) async {
                      try {
                        final token = await _authService.getToken();
                        if (token == null) {
                          throw Exception('Utilisateur non authentifié');
                        }
                        final chantierService = ChantierService(token);

                        await chantierService.updateReserveStatus(
                            reserve['id'], newStatus);
                        _loadReserves();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Statut mis à jour avec succès')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Erreur : $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReserveModal,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add_alert, color: Colors.white),
        label: const Text('Signaler une réserve',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
