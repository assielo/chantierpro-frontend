import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'stocks_screen.dart';
import 'dashboard_stats_screen.dart';
import 'materials_calculation_screen.dart';
import 'export_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  final String token;
  final int projectId = 1;

  const HomeMenuScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChantierPro - Gestion'),
        backgroundColor: Colors.amber[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              final authService = AuthService();
              await authService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête de bienvenue
            Card(
              elevation: 3,
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chantier actif en cours',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Projet #$projectId - Résidence Akwaba',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Modules de gestion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grille des modules
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // 1. Journal de chantier
                  _buildMenuCard(
                    context,
                    title: 'Journal de chantier',
                    icon: Icons.book,
                    color: Colors.blue,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Module Journal de chantier')),
                      );
                    },
                  ),

                  // 2. Gestion des Stocks
                  _buildMenuCard(
                    context,
                    title: 'Gestion des Stocks',
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StockScreen(projectId: projectId, token: token),
                        ),
                      );
                    },
                  ),

                  // 3. Réserves et Malfaçons
                  _buildMenuCard(
                    context,
                    title: 'Réserves & Malfaçons',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.red,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Module Réserves')),
                      );
                    },
                  ),

                  // 4. Statistiques & Graphiques
                  _buildMenuCard(
                    context,
                    title: 'Statistiques (fl_chart)',
                    icon: Icons.bar_chart,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardStatsScreen(
                              projectId: projectId, token: token),
                        ),
                      );
                    },
                  ),

                  // 5. Variabilité des matériaux (Ferraillage, Sable/Gravier, Parpaings)
                  _buildMenuCard(
                    context,
                    title: 'Variabilité des Matériaux',
                    icon: Icons.architecture,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaterialsCalculationScreen(
                            projectId: projectId,
                            token: token,
                          ),
                        ),
                      );
                    },
                  ),

                  // 6. Export Excel (.xlsx)
                  // 6. Export Excel (.xlsx)
                  _buildMenuCard(
                    context,
                    title: 'Export Excel (Deals/Rapports)',
                    icon: Icons.table_chart,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExportScreen(
                            projectId: projectId,
                            token: token,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget personnalisé pour chaque carte du menu
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
