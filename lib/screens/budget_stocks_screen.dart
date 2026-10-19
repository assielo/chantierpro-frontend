import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import 'package:flutter/material.dart';

class BudgetStocksScreen extends StatelessWidget {
  final int projectId;

  const BudgetStocksScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'État des Stocks & Matériaux',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_rounded,
                  color: Color(0xFF1E3A8A), size: 28),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Ouverture du formulaire d’ajout de matériau...'),
                    backgroundColor: Color(0xFF0F172A),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 15),
        _buildStockCard(
          name: 'Ciment CPJ 42.5',
          quantity: '150 sacs',
          status: 'Stock normal',
          color: Colors.green,
          icon: Icons.layers_rounded,
        ),
        _buildStockCard(
          name: 'Fers à béton 12mm',
          quantity: '45 barres',
          status: 'Stock bas (Alerte)',
          color: Colors.red,
          icon: Icons.architecture_rounded,
        ),
        _buildStockCard(
          name: 'Sable fin (m³)',
          quantity: '30 m³',
          status: 'Stock normal',
          color: Colors.green,
          icon: Icons.grain_rounded,
        ),
        _buildStockCard(
          name: 'Gravier 15/25',
          quantity: '18 m³',
          status: 'Stock moyen',
          color: Colors.orange,
          icon: Icons.category_rounded,
        ),
      ],
    );
  }

  Widget _buildStockCard({
    required String name,
    required String quantity,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantité : $quantity',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20), // Correction ici
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
