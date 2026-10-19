import 'package:flutter/material.dart';
import '../../services/chantier_service.dart';

class ReserveFormScreen extends StatefulWidget {
  final int projectId;
  final String token;

  const ReserveFormScreen(
      {Key? key, required this.projectId, required this.token})
      : super(key: key);

  @override
  _ReserveFormScreenState createState() => _ReserveFormScreenState();
}

class _ReserveFormScreenState extends State<ReserveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;

  void _submitReserve() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final service = ChantierService(widget.token);
      bool success = await service.createReserve(
        projectId: widget.projectId,
        title: _titleController.text,
        description: _descriptionController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Réserve enregistrée avec succès !"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Erreur lors de l'enregistrement de la réserve."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signaler une Réserve / Malfaçon")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                    labelText: "Titre de la réserve (ex: Fissure mur salon)",
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? "Veuillez entrer un titre" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: "Description détaillée",
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? "Veuillez entrer une description" : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitReserve,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text("Enregistrer la Réserve",
                          style: TextStyle(fontSize: 16)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
