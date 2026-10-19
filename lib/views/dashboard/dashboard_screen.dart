import 'package:flutter/material.dart';
// Importation du formulaire et de l'écran des réserves avec les chemins relatifs corrects
import '../forms/chantier_form_screen.dart';
import '../views/reserves/reserves_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord - ChantierPro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          // Optionnel : un accès direct aux réserves depuis l'AppBar si besoin
          IconButton(
            icon: const Icon(Icons.assignment_alert),
            tooltip: 'Gérer les réserves',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReservesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vue d\'ensemble',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grille de statistiques
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StatCard(
                    title: 'Chantiers Actifs',
                    value: '12',
                    icon: Icons.business,
                    color: Colors.blue),
                StatCard(
                    title: 'En attente',
                    value: '3',
                    icon: Icons.hourglass_top,
                    color: Colors.orange),
                StatCard(
                    title: 'Employés sur site',
                    value: '45',
                    icon: Icons.people,
                    color: Colors.green),
                StatCard(
                    title: 'Incidents',
                    value: '0',
                    icon: Icons.warning,
                    color: Colors.red),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Derniers Chantiers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Liste des chantiers récents
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.engineering, color: Colors.white),
                    ),
                    title: Text('Chantier Résidence Alpha #${index + 1}'),
                    subtitle:
                        const Text('Statut : En cours • Avancement : 65%'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Vous pouvez rediriger vers les réserves ou le détail du chantier ici
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReservesScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // Bouton flottant pour ouvrir le formulaire
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab_unique_tag',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChantierFormScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Widget réutilisable pour les cartes de statistiques
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
