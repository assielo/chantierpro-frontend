import 'package:flutter/material.dart';
import '../../services/chantier_service.dart';

class StockFormScreen extends StatefulWidget {
  final int projectId;
  final String token;

  const StockFormScreen(
      {Key? key, required this.projectId, required this.token})
      : super(key: key);

  @override
  _StockFormScreenState createState() => _StockFormScreenState();
}

class _StockFormScreenState extends State<StockFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  bool _isLoading = false;

  void _submitStock() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final service = ChantierService(widget.token);
      bool success = await service.addStockMovement(
        projectId: widget.projectId,
        itemName: _itemController.text,
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Mouvement de stock enregistré avec succès !"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Erreur lors de l'enregistrement du stock."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un Mouvement de Stock")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                    labelText: "Nom de l'article (ex: Ciment, Fer à béton)",
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? "Veuillez entrer un nom d'article" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: "Quantité", border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? "Veuillez indiquer la quantité" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                    labelText: "Unité (ex: sacs, tonnes, unités)",
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? "Veuillez indiquer l'unité" : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitStock,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text("Enregistrer le Stock",
                          style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
