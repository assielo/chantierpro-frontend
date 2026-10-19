import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Importation du service centralisé
import '../../services/api_service.dart';

class ChantierFormScreen extends StatefulWidget {
  const ChantierFormScreen({super.key});

  @override
  State<ChantierFormScreen> createState() => _ChantierFormScreenState();
}

class _ChantierFormScreenState extends State<ChantierFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de saisie
  final _cityController = TextEditingController(text: 'Bouaké');
  final _roomsController = TextEditingController(text: '4');
  final _surfaceController = TextEditingController(text: '500');
  final _budgetController = TextEditingController(text: '20000000');

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _cityController.dispose();
    _roomsController.dispose();
    _surfaceController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  // Soumission du formulaire vers l'API FastAPI
  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/estimates'), // Pointé vers Laravel
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'budget': double.tryParse(_budgetController.text) ?? 0.0,
          'land_surface': double.tryParse(_surfaceController.text) ?? 0.0,
          'city': _cityController.text.trim(),
          'num_rooms': int.tryParse(_roomsController.text) ?? 0,
          'finishing_level':
              'Standard', // Ajoutez ou liez un champ pour ce paramètre
          'roof_type': 'Tôle', // Ajoutez ou liez un champ pour ce paramètre
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Succès : on retourne true pour indiquer à la liste de se rafraîchir
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (response.statusCode == 401) {
        // Token expiré ou invalide
        ApiService.token = null;
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['detail'] ??
              'Erreur lors de l\'enregistrement (${response.statusCode})';
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
      appBar: AppBar(
        title: const Text('Nouveau Chantier'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville du chantier',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Veuillez entrer une ville'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _roomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de pièces',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => int.tryParse(value ?? '') == null
                        ? 'Veuillez entrer un nombre valide'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _surfaceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Surface du terrain (m²)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => double.tryParse(value ?? '') == null
                        ? 'Veuillez entrer une surface valide'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget prévisionnel (FCFA)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => double.tryParse(value ?? '') == null
                        ? 'Veuillez entrer un budget valide'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: _loading ? null : _submitProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black),
                          )
                        : const Text(
                            'ENREGISTRER LE CHANTIER',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
