import 'package:flutter/material.dart';

class DailyLogTab extends StatelessWidget {
  const DailyLogTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_comment),
            label: const Text('Ajouter une note de chantier'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Coulage de la dalle R+1'),
                    subtitle: Text('Effectué par 6 ouvriers. Temps clair.'),
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