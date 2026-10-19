import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// 1. Écran Journal de Chantier
class JournalDeChantierScreen extends StatelessWidget {
  final int projectId;
  const JournalDeChantierScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Journal de Chantier'),
          backgroundColor: Colors.blue),
      body: const Center(
        child:
            Text('Liste des entrées du journal (Météo, Avancement, Incidents)'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// 2. Écran Gestion des Stocks
class GestionStocksScreen extends StatelessWidget {
  final int projectId;
  const GestionStocksScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Gestion des Stocks'),
          backgroundColor: Colors.orange),
      body: const Center(
        child:
            Text('Suivi des entrées/sorties de matériaux (Ciment, Fers, etc.)'),
      ),
    );
  }
}

// 3. Écran Réserves & Malfaçons
class ReservesMalfaconsScreen extends StatelessWidget {
  final int projectId;
  const ReservesMalfaconsScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Réserves & Malfaçons'),
          backgroundColor: Colors.red),
      body: const Center(
        child: Text('Gestion et levée des réserves du chantier'),
      ),
    );
  }
}

// 4. Écran Statistiques (Intégration fl_chart)
class StatistiquesScreen extends StatelessWidget {
  final int projectId;
  const StatistiquesScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Statistiques du Projet'),
          backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Consommation budgétaire et avancement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 8, color: Colors.green)
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 10, color: Colors.green)
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 14, color: Colors.green)
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
