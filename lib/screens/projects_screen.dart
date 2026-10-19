import 'package:flutter/material.dart';
import 'project_dashboard_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  bool _isListening = false;

  final List<Map<String, dynamic>> projects = [
    {
      'id': 1,
      'name': 'Villa Les Palmiers',
      'location': 'Cocody',
      'progress': '75%',
      'progressValue': 0.75,
      'statusText': 'En cours',
      'icon': Icons.home_rounded,
      'color': const Color(0xFF2563EB),
    },
    {
      'id': 2,
      'name': 'Immeuble Commercial',
      'location': 'Plateau',
      'progress': '30%',
      'progressValue': 0.30,
      'statusText': 'Gros œuvre',
      'icon': Icons.apartment_rounded,
      'color': const Color(0xFFD97706),
    },
    {
      'id': 3,
      'name': 'Complexe Scolaire',
      'location': 'Yopougon',
      'progress': '90%',
      'progressValue': 0.90,
      'statusText': 'Presque fini',
      'icon': Icons.school_rounded,
      'color': const Color(0xFF059669),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 26),
            SizedBox(width: 10),
            Text(
              'CHANTIERPRO AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded,
                color: Colors.white, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Synthèse vocale : Tous les chantiers avancent bien.'),
                  backgroundColor: Color(0xFF0F172A),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assistant Vocal Actif',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dites par exemple : "Le ciment est arrivé à Cocody"',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isListening = !_isListening;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isListening
                            ? 'Écoute en cours... Parlez.'
                            : 'Analyse terminée.'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.redAccent : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isListening ? 'Écoute...' : 'Parler',
                      style: TextStyle(
                        color: _isListening
                            ? Colors.white
                            : const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final Color themeColor = project['color'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDashboardScreen(
                              projectId: project['id'],
                              projectName: project['name'],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    project['icon'],
                                    color: themeColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_pin,
                                              color: Colors.redAccent,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            project['location'],
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: themeColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    project['progress'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: project['progressValue'],
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              builder: (context) => Padding(
                padding: const EdgeInsets.all(24.0),
                // Correction effectuée ici (remplacement de 'ces:' par 'child:')
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Rapport Intelligent IA',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prenez une photo ou dictez votre constat, l’IA s’occupe du reste.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Analyse photo par IA en cours...')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.camera_alt_rounded,
                                    size: 36, color: Colors.blue),
                                SizedBox(height: 8),
                                Text('Photo Chantier',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Enregistrement audio intelligent actif...')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.mic_rounded,
                                    size: 36, color: Colors.orange),
                                SizedBox(height: 8),
                                Text('Dicter Rapport',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 6,
          icon: const Icon(Icons.auto_awesome, color: Colors.amber),
          label: const Text(
            'NOUVEAU RAPPORT IA',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
