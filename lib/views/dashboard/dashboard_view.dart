import 'package:flutter/material.dart';

// Importations avec les chemins relatifs exacts depuis le dossier 'lib/screens/'
import '../forms/chantier_form_screen.dart';
import '../stocks/stock_form_screen.dart';
import '../reserves/reserve_form_screen.dart';
import '../services/api_service.dart'; // Ajustez si le service est à la racine de lib/ ou dans un sous-dossier

class DashboardView extends StatelessWidget {
  final int projectId;
  final String token;

  const DashboardView({
    Key? key,
    this.projectId = 0,
    this.token = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeToken = token.isNotEmpty ? token : (ApiService.token ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text("ChantierPro - Tableau de Bord"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Sélectionnez un module de saisie :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Bouton 1 : Journal de Chantier
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChantierFormScreen(
                      projectId: projectId,
                      token: activeToken,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.book),
              label: const Text("Journal de Chantier"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton 2 : Gestion des Stocks
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StockFormScreen(
                      projectId: projectId,
                      token: activeToken,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.inventory),
              label: const Text("Gestion des Stocks"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton 3 : Réserves / Malfaçons
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReserveFormScreen(
                      projectId: projectId,
                      token: activeToken,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.warning),
              label: const Text("Signaler une Réserve"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
