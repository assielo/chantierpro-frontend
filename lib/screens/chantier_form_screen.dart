import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_saver/file_saver.dart'; // Correction de l'import du package

class ChantierFormScreen extends StatefulWidget {
  const ChantierFormScreen({super.key});

  @override
  State<ChantierFormScreen> createState() => _ChantierFormScreenState();
}

class _ChantierFormScreenState extends State<ChantierFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de saisie correspondant aux attentes de l'EstimateController Laravel & FastAPI
  final TextEditingController _budgetController =
      TextEditingController(text: '20000000');
  final TextEditingController _surfaceController =
      TextEditingController(text: '500');
  final TextEditingController _cityController =
      TextEditingController(text: 'Bouaké');
  final TextEditingController _roomsController =
      TextEditingController(text: '4');
  final TextEditingController _finishingController =
      TextEditingController(text: 'Standard');
  final TextEditingController _roofController =
      TextEditingController(text: 'Tôle');

  bool _isLoading = false;
  bool _isExcelLoading = false;
  String? _error;
  Map<String, dynamic>? _resultData;

  @override
  void dispose() {
    _budgetController.dispose();
    _surfaceController.dispose();
    _cityController.dispose();
    _roomsController.dispose();
    _finishingController.dispose();
    _roofController.dispose();
    super.dispose();
  }

  // 1. Soumission du formulaire vers l'API Laravel (EstimateController)
  Future<void> _submitEstimate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _resultData = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/estimates'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'budget': double.parse(_budgetController.text),
          'land_surface': double.parse(_surfaceController.text),
          'city': _cityController.text.trim(),
          'num_rooms': int.parse(_roomsController.text),
          'finishing_level': _finishingController.text.trim(),
          'roof_type': _roofController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _resultData = data['data'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Devis et métrés calculés avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['message'] ??
              'Erreur lors du calcul (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion au serveur : $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. Soumission vers FastAPI pour générer et télécharger le fichier Excel (.xlsx)
  Future<void> _submitAndDownloadExcel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isExcelLoading = true;
    });

    final url = Uri.parse(
        'http://127.0.0.1:8000/api/v1/estimates/calculate-and-export');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "budget": double.tryParse(_budgetController.text) ?? 0.0,
          "surface": double.tryParse(_surfaceController.text) ?? 0.0,
          "ville": _cityController.text.trim(),
          "nombre_pieces": int.tryParse(_roomsController.text) ?? 1,
          "niveau_finition": _finishingController.text.trim(),
          "type_toiture": _roofController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        // Récupération des octets binaires du fichier Excel
        final bytes = response.bodyBytes;

        // Nom du fichier généré dynamiquement
        String fileName =
            "devis_${_cityController.text.trim().toLowerCase()}_${_surfaceController.text}m2";

        // Sauvegarde et téléchargement automatique via file_saver
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: 'xlsx',
          mimeType: MimeType.microsoftExcel,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Devis Excel téléchargé avec succès !',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la génération du fichier Excel.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur réseau : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExcelLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculateur et Devis - Métrés'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Budget prévisionnel (FCFA)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _surfaceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Surface du terrain (m²)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Ville',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _roomsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de pièces',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _finishingController,
                        decoration: const InputDecoration(
                          labelText: 'Niveau de finition (ex: Standard, Luxe)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _roofController,
                        decoration: const InputDecoration(
                          labelText: 'Type de toiture (ex: Tôle, Tuile)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Champ requis' : null,
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

                      // Bouton de calcul principal (Laravel)
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitEstimate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black),
                              )
                            : const Text(
                                'CALCULER LE DEVIS',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                      const SizedBox(height: 12),

                      // Bouton d'export Excel (FastAPI)
                      ElevatedButton.icon(
                        onPressed:
                            _isExcelLoading ? null : _submitAndDownloadExcel,
                        icon: const Icon(Icons.file_download,
                            color: Colors.white),
                        label: _isExcelLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'TÉLÉCHARGER LE DEVIS EXCEL (.XLSX)',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // Affichage des résultats du calcul renvoyés par Laravel
                if (_resultData != null) ...[
                  const SizedBox(height: 30),
                  const Divider(thickness: 2),
                  const Text(
                    'Résultats des Estimations & Métrés',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Surface habitable estimée : ${_resultData!['metrics']['living_surface_m2']} m²'),
                          const SizedBox(height: 8),
                          Text(
                              'Sacs de ciment requis : ${_resultData!['metrics']['ciment_sacs']} sacs'),
                          const SizedBox(height: 8),
                          Text(
                              'Main-d\'œuvre : ${_resultData!['financials']['main_doeuvre_fcfa']} FCFA'),
                          const SizedBox(height: 8),
                          Text(
                              'Marge / Frais annexes : ${_resultData!['financials']['marge_fcfa']} FCFA'),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
