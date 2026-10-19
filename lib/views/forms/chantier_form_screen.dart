import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';

class ChantierFormScreen extends StatefulWidget {
  final int projectId;
  final String token;

  const ChantierFormScreen({
    super.key,
    required this.projectId,
    required this.token,
  });

  @override
  State<ChantierFormScreen> createState() => _ChantierFormScreenState();
}

class _ChantierFormScreenState extends State<ChantierFormScreen> {
  final _commentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitJournalEntry() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/projects/${widget.projectId}/journal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'comment': _commentController.text.trim(),
          'date': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, true); // Retourne true pour indiquer le succès
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Erreur lors de l\'enregistrement (${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion au serveur')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal de Chantier"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes et avancement des travaux du jour',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitJournalEntry,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('ENREGISTRER L\'ENTRÉE',
                      style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
