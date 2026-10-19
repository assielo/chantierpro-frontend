import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardStatsScreen extends StatefulWidget {
  final int projectId;
  final String token;

  const DashboardStatsScreen({
    Key? key,
    required this.projectId,
    required this.token,
  }) : super(key: key);

  @override
  State<DashboardStatsScreen> createState() => _DashboardStatsScreenState();
}

class _DashboardStatsScreenState extends State<DashboardStatsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Vous pourrez appeler ici une méthode de votre ChantierService pour récupérer des stats dynamiques si besoin
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques - Chantier #${widget.projectId}'),
        backgroundColor: Colors.amber[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const Text(
                    'Suivi des effectifs (Ouvriers / Jours)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Conteneur du graphique en barres
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 50, // Valeur maximale de l'axe Y
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const days = [
                                  'Lun',
                                  'Mar',
                                  'Mer',
                                  'Jeu',
                                  'Ven',
                                  'Sam'
                                ];
                                if (value.toInt() < days.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      days[value.toInt()],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(
                                toY: 25,
                                color: Colors.amber[700],
                                width: 16,
                                borderRadius: BorderRadius.circular(4))
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(
                                toY: 30,
                                color: Colors.amber[700],
                                width: 16,
                                borderRadius: BorderRadius.circular(4))
                          ]),
                          BarChartGroupData(x: 2, barRods: [
                            BarChartRodData(
                                toY: 22,
                                color: Colors.amber[700],
                                width: 16,
                                borderRadius: BorderRadius.circular(4))
                          ]),
                          BarChartGroupData(x: 3, barRods: [
                            BarChartRodData(
                                toY: 35,
                                color: Colors.amber[700],
                                width: 16,
                                borderRadius: BorderRadius.circular(4))
                          ]),
                          BarChartGroupData(x: 4, barRods: [
                            BarChartRodData(
                                toY: 40,
                                color: Colors.amber[700],
                                width: 16,
                                borderRadius: BorderRadius.circular(4))
                          ]),
                          BarChartGroupData(x: 5, barRods: [
                            BarChartRodData(
                                toY: 15,
                                color: Colors.amber[700],
                                width: 16,
                                borderRadius: BorderRadius.circular(4))
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Carte d'indicateurs clés
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Indicateurs clés du projet',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12),
                          Text(
                              '• Pic d\'activité atteint le Vendredi (40 ouvriers actifs)'),
                          SizedBox(height: 6),
                          Text(
                              '• Moyenne hebdomadaire stable et conforme aux prévisions'),
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
