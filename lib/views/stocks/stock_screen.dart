import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<dynamic> _projects = [];
  int? _selectedProjectId;
  List<dynamic> _stocks = [];
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
            _fetchStocks(_selectedProjectId!);
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement chantiers : $e');
    }
  }

  Future<void> _fetchStocks(int projectId) async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/projects/$projectId/stocks'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _stocks = jsonDecode(response.body);
        });
      } else {
        setState(() => _stocks = []);
      }
    } catch (e) {
      debugPrint('Erreur chargement stocks : $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showAddStockDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController();
    final thresholdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un matériau au stock'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Nom du matériau (ex: Ciment CPJ 42.5)'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Quantité initiale'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(
                    labelText: 'Unité (ex: Sacs, Tonnes, Mètres)'),
              ),
              TextField(
                controller: thresholdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Seuil d\'alerte de rupture'),
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
              await _createStockItem(
                nameController.text.trim(),
                double.tryParse(quantityController.text) ?? 0.0,
                unitController.text.trim(),
                double.tryParse(thresholdController.text) ?? 0.0,
              );
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _createStockItem(
      String name, double quantity, String unit, double threshold) async {
    if (_selectedProjectId == null) return;
    try {
      final response = await http.post(
        Uri.parse(
            '${ApiService.baseUrl}/api/v1/projects/$_selectedProjectId/stocks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({
          'name': name,
          'quantity': quantity,
          'unit': unit,
          'alert_threshold': threshold,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _fetchStocks(_selectedProjectId!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Matériau ajouté au stock avec succès !')),
        );
      }
    } catch (e) {
      debugPrint('Erreur création stock : $e');
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
            // Code corrigé :
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gestion des Stocks & Matériaux',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed:
                    _selectedProjectId == null ? null : _showAddStockDialog,
                icon: const Icon(Icons.add),
                label: const Text('Nouveau Matériau'),
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
                if (val != null) _fetchStocks(val);
              },
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _stocks.isEmpty
                    ? const Center(
                        child:
                            Text('Aucun matériau enregistré pour ce chantier.'))
                    : ListView.builder(
                        itemCount: _stocks.length,
                        itemBuilder: (context, index) {
                          final item = _stocks[index];
                          final double qty = (item['quantity'] ?? 0).toDouble();
                          final double threshold =
                              (item['alert_threshold'] ?? 0).toDouble();
                          final bool isLowStock = qty <= threshold;

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isLowStock
                                    ? Colors.red[100]
                                    : Colors.green[100],
                                child: Icon(
                                  isLowStock
                                      ? Icons.warning
                                      : Icons.inventory_2,
                                  color: isLowStock ? Colors.red : Colors.green,
                                ),
                              ),
                              title: Text(
                                item['name'] ?? 'Matériau inconnu',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Quantité : $qty ${item['unit']} (Seuil d\'alerte : $threshold)',
                              ),
                              trailing: isLowStock
                                  ? Chip(
                                      label: const Text('Stock Bas',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.red,
                                    )
                                  : const Chip(
                                      label: Text('En stock',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      backgroundColor: Colors.green,
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
