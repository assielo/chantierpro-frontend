import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import '../../services/api_service.dart';
import '../../services/journal_socket_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalSocketService _socketService = JournalSocketService();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<dynamic> _projects = [];
  int? _selectedProjectId;

  // Données du journal pour le jour sélectionné
  Map<String, dynamic>? _dailyReport;
  bool _loading = false;

  // Contrôleurs de saisie
  final _weatherController = TextEditingController();
  final _teamCountController = TextEditingController();
  final _progressNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/api/v1/projects'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );
      if (response.statusCode == 200) {
        setState(() {
          _projects = jsonDecode(response.body);
          if (_projects.isNotEmpty) {
            _selectedProjectId = _projects[0]['id'];
            _initWebSocket(_selectedProjectId!);
            _fetchJournalForDate(_selectedProjectId!, _selectedDay);
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement chantiers : $e');
    }
  }

  void _initWebSocket(int projectId) {
    _socketService.connect(projectId, (data) {
      // Rafraîchir les données en temps réel lorsqu'un autre utilisateur modifie le journal
      if (_selectedProjectId != null) {
        _fetchJournalForDate(_selectedProjectId!, _selectedDay);
      }
    });
  }

  Future<void> _fetchJournalForDate(int projectId, DateTime date) async {
    setState(() => _loading = true);
    final formattedDate = date.toIso8601String().split('T')[0];
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiService.baseUrl}/api/v1/projects/$projectId/journal?date=$formattedDate'),
        headers: {'Authorization': 'Bearer ${ApiService.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dailyReport = data;
          _weatherController.text = data['weather'] ?? '';
          _teamCountController.text = (data['team_count'] ?? '').toString();
          _progressNotesController.text = data['progress_notes'] ?? '';
        });
      } else {
        setState(() {
          _dailyReport = null;
          _weatherController.clear();
          _teamCountController.clear();
          _progressNotesController.clear();
        });
      }
    } catch (e) {
      debugPrint('Erreur récupération journal : $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveDailyReport() async {
    if (_selectedProjectId == null) return;
    final formattedDate = _selectedDay.toIso8601String().split('T')[0];

    try {
      final response = await http.post(
        Uri.parse(
            '${ApiService.baseUrl}/api/v1/projects/${_selectedProjectId}/journal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({
          'date': formattedDate,
          'weather': _weatherController.text.trim(),
          'team_count': int.tryParse(_teamCountController.text) ?? 0,
          'progress_notes': _progressNotesController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Notifier via WebSocket
        _socketService.sendMessage({'action': 'update', 'date': formattedDate});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Journal de chantier enregistré avec succès !')),
        );
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde : $e');
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    _weatherController.dispose();
    _teamCountController.dispose();
    _progressNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Journal de Chantier & Plannings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_projects.isNotEmpty)
            DropdownButtonFormField<int>(
              value: _selectedProjectId,
              decoration: const InputDecoration(
                labelText: 'Sélectionner le Chantier',
                border: OutlineInputBorder(),
              ),
              items: _projects
                  .map((p) => DropdownMenuItem<int>(
                        value: p['id'],
                        child: Text('Chantier #${p['id']} - ${p['city']}'),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() => _selectedProjectId = val);
                _socketService.disconnect();
                _initWebSocket(val!);
                _fetchJournalForDate(val, _selectedDay);
              },
            ),
          const SizedBox(height: 12),
          // Calendrier TableCalendar
          Card(
            elevation: 2,
            child: TableCalendar(
              firstDay: DateTime.utc(2025, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                if (_selectedProjectId != null) {
                  _fetchJournalForDate(_selectedProjectId!, selectedDay);
                }
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: Colors.blueAccent, shape: BoxShape.circle),
                selectedDecoration:
                    BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              ),
              headerStyle: const HeaderStyle(
                  formatButtonVisible: false, titleCentered: true),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Rapport pour le : ${_selectedDay.toIso8601String().split('T')[0]}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _weatherController,
                          decoration: const InputDecoration(
                            labelText: 'Météo du jour (ex: Ensoleillé, 32°C)',
                            prefixIcon: Icon(Icons.wb_sunny),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _teamCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nombre d\'ouvriers présents sur site',
                            prefixIcon: Icon(Icons.group),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _progressNotesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Avancement des travaux & Remarques',
                            prefixIcon: Icon(Icons.note_alt),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _saveDailyReport,
                          icon: const Icon(Icons.save),
                          label:
                              const Text('Enregistrer le Rapport Journalier'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
