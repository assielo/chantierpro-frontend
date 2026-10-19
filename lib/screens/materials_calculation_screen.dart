import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_saver/file_saver.dart';

class MaterialsCalculationScreen extends StatefulWidget {
  final int projectId;
  final String token;

  const MaterialsCalculationScreen({
    Key? key,
    required this.projectId,
    required this.token,
  }) : super(key: key);

  @override
  _MaterialsCalculationScreenState createState() =>
      _MaterialsCalculationScreenState();
}

class _MaterialsCalculationScreenState
    extends State<MaterialsCalculationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de saisie (correspondant à l'interface de l'image et aux API)
  final TextEditingController _surfaceController = TextEditingController();
  final TextEditingController _niveauxController =
      TextEditingController(text: '1');
  final TextEditingController _budgetController =
      TextEditingController(text: '20000000');
  final TextEditingController _cityController =
      TextEditingController(text: 'Bouaké');
  final TextEditingController _roomsController =
      TextEditingController(text: '4');
  final TextEditingController _finishingController =
      TextEditingController(text: 'Standard');
  final TextEditingController _roofController =
      TextEditingController(text: 'Tôle');

  // États de chargement et retours d'API
  bool _isLoading = false;
  bool _isExcelLoading = false;
  String? _error;
  Map<String, dynamic>? _resultData;

  // Résultats calculés localement (Métrés affichés dans les cartes)
  double _totalBriques = 0;
  double _totalSableM3 = 0;
  double _totalGravierM3 = 0;
  double _totalFerraillageKg = 0;

  @override
  void dispose() {
    _surfaceController.dispose();
    _niveauxController.dispose();
    _budgetController.dispose();
    _cityController.dispose();
    _roomsController.dispose();
    _finishingController.dispose();
    _roofController.dispose();
    super.dispose();
  }

  // 1. Calcul local des matériaux et appel de l'API Laravel
  Future<void> _calculerMateriauxEtDevis() async {
    if (!_formKey.currentState!.validate()) return;

    double surface = double.tryParse(_surfaceController.text) ?? 0.0;
    int niveaux = int.tryParse(_niveauxController.text) ?? 1;
    double surfaceTotale = surface * niveaux;

    setState(() {
      _isLoading = true;
      _error = null;
      _resultData = null;

      // Calculs basés sur les ratios standards BTP
      _totalBriques = surfaceTotale * 12.5 * 3;
      _totalSableM3 = surfaceTotale * 0.045;
      _totalGravierM3 = surfaceTotale * 0.035;
      _totalFerraillageKg = surfaceTotale * 15.0;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/estimates'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'project_id': widget.projectId,
          'budget': double.parse(_budgetController.text),
          'land_surface': surface,
          'niveaux': niveaux,
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
            content: Text("Estimation et métrés calculés avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error = data['message'] ??
              'Erreur lors du calcul distant (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Mode local actif (Erreur de connexion serveur : $e)';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. Exportation du fichier Excel (.xlsx) via FastAPI
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
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          "project_id": widget.projectId,
          "budget": double.tryParse(_budgetController.text) ?? 0.0,
          "surface": double.tryParse(_surfaceController.text) ?? 0.0,
          "niveaux": int.tryParse(_niveauxController.text) ?? 1,
          "ville": _cityController.text.trim(),
          "nombre_pieces": int.tryParse(_roomsController.text) ?? 1,
          "niveau_finition": _finishingController.text.trim(),
          "type_toiture": _roofController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        String fileName =
            "devis_projet_${widget.projectId}_${_surfaceController.text}m2";

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
        title: Text('Variabilité & Estimation - Projet #${widget.projectId}'),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Paramètres du Chantier',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _surfaceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Surface au sol (m²)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.square_foot),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une surface valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _niveauxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de niveaux (R+...)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.layers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nombre de niveaux';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Champs additionnels pour compléter l'estimation financière
              ExpansionTile(
                title: const Text('Paramètres avancés du devis (Optionnel)',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                children: [
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget prévisionnel (FCFA)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _roomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de pièces',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _finishingController,
                    decoration: const InputDecoration(
                      labelText: 'Niveau de finition',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _roofController,
                    decoration: const InputDecoration(
                      labelText: 'Type de toiture',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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

              // Bouton principal d'estimation
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _calculerMateriauxEtDevis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.calculate, color: Colors.white),
                label: const Text(
                  'Lancer l\'estimation',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),

              // Bouton de téléchargement Excel (.xlsx)
              ElevatedButton.icon(
                onPressed: _isExcelLoading ? null : _submitAndDownloadExcel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: _isExcelLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.file_download, color: Colors.white),
                label: const Text(
                  'TÉLÉCHARGER LE DEVIS EXCEL (.XLSX)',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Résultats Estimés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                'Ferraillage (Acier à béton)',
                '${_totalFerraillageKg.toStringAsFixed(2)} kg',
                Icons.fitness_center,
                Colors.blue,
              ),
              _buildResultCard(
                'Parpaings / Briques',
                '${_totalBriques.toStringAsFixed(0)} unités',
                Icons.grid_view,
                Colors.orange,
              ),
              _buildResultCard(
                'Sable',
                '${_totalSableM3.toStringAsFixed(2)} m³',
                Icons.grain,
                Colors.brown,
              ),
              _buildResultCard(
                'Gravier',
                '${_totalGravierM3.toStringAsFixed(2)} m³',
                Icons.texture,
                Colors.grey,
              ),

              if (_resultData != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  color: Colors.amber[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails Supplémentaires de l\'API',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        if (_resultData!['metrics'] != null) ...[
                          Text(
                              'Surface habitable : ${_resultData!['metrics']['living_surface_m2']} m²'),
                          Text(
                              'Sacs de ciment : ${_resultData!['metrics']['ciment_sacs']} sacs'),
                        ],
                        if (_resultData!['financials'] != null) ...[
                          Text(
                              'Main-d\'œuvre : ${_resultData!['financials']['main_doeuvre_fcfa']} FCFA'),
                          Text(
                              'Marge / Frais annexes : ${_resultData!['financials']['marge_fcfa']} FCFA'),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 36, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber[900]),
        ),
      ),
    );
  }
}
