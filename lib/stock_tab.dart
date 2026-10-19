import 'package:flutter/material.dart';

class StockTab extends StatelessWidget {
  const StockTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_box),
            label: const Text('Entrée / Sortie de matériel'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.inventory_2, color: Colors.brown),
                    title: Text('Sacs de Ciment CPJ 42.5'),
                    subtitle: Text('Reste en stock : 120 sacs'),
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