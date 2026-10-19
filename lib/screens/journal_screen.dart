import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/chantier_service.dart';

class JournalScreen extends StatefulWidget {
  final int projectId;

  const JournalScreen({super.key, required this.projectId});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _journalController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _saveJournal() async {
    if (_journalController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');

      final chantierService = ChantierService(token);
      await chantierService.createDailyLog(widget.projectId, {
        'content': _journalController.text.trim(),
        'date': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal de chantier enregistré avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        _journalController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal de Chantier'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rédiger une entrée pour aujourd\'hui',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _journalController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description des travaux / faits du jour',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isLoading ? null : _saveJournal,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Enregistrer dans le journal',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
