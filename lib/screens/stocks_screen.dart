import 'package:flutter/material.dart';
import '../services/chantier_service.dart';

class StockScreen extends StatefulWidget {
  final int projectId;
  final String token;

  const StockScreen({Key? key, required this.projectId, required this.token})
      : super(key: key);

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  late final ChantierService _chantierService;
  late Future<List<dynamic>> futureStocks;

  @override
  void initState() {
    super.initState();
    _chantierService = ChantierService(widget.token);
    futureStocks = _chantierService.getStockMovements(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Stocks'),
        backgroundColor: Colors.amber[700],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureStocks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Aucun stock enregistré pour ce projet.'));
          }

          final stocks = snapshot.data!;

          return ListView.builder(
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(stock['item_name'] ?? 'Nom inconnu',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('Quantité : ${stock['quantity']} ${stock['unit']}'),
                  trailing: const Icon(Icons.inventory_2, color: Colors.amber),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
