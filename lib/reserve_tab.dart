import 'package:flutter/material.dart';

class ReserveTab extends StatelessWidget {
  const ReserveTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.report_problem),
            label: const Text('Signaler une réserve / défaut'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.orange),
                    title: Text('Fissure mur Ouest - Salon'),
                    subtitle: Text('Statut : En attente de reprise'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}