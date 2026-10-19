import 'package:flutter/material.dart';
import 'budget_stocks_screen.dart';
import 'journal_screen.dart';
import 'reserves_screen.dart';
import 'chantier_form_screen.dart'; // Corrigé : Import du formulaire de saisie des métrés

class ProjectDashboardScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const ProjectDashboardScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialisation des différents onglets en leur passant le projectId
    _screens = [
      _buildOverviewTab(), // Onglet 0 : Le tableau de bord visuel et synthétique complet
      BudgetStocksScreen(projectId: widget.projectId), // Onglet 1 : Stocks
      JournalScreen(projectId: widget.projectId), // Onglet 2 : Journal
      ReservesScreen(projectId: widget.projectId), // Onglet 3 : Réserves
      const ChantierFormScreen(), // Onglet 4 : Métrés & Devis
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          widget.projectName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded,
                color: Colors.amber, size: 26),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Synthèse vocale : Résumé du chantier ${widget.projectName} en cours...'),
                  backgroundColor: const Color(0xFF0F172A),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF3F4F6),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex:
              _currentIndex > 4 ? 0 : _currentIndex, // Sécurité si index étendu
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.grey[500],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Stocks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report_problem_outlined),
              activeIcon: Icon(Icons.report_problem),
              label: 'Réserves',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Métrés',
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget représentant l'onglet principal du Tableau de Bord synthétique ---
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte de résumé visuel global du chantier
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'État d’avancement global',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Icon(Icons.verified_rounded, color: Colors.amber, size: 24),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '75% Terminé',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Text(
            'Actions Rapides',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 15),

          // Grille de gros boutons tactiles
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Voir Photos',
                  subtitle: 'Derniers visuels',
                  icon: Icons.photo_library_rounded,
                  color: const Color(0xFF2563EB),
                  onTap: () => _showInfoSnackBar(
                      'Ouverture de la galerie photos du chantier...'),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  title: 'Écouter Audio',
                  subtitle: 'Dernier rapport vocal',
                  icon: Icons.headphones_rounded,
                  color: const Color(0xFFD97706),
                  onTap: () => _showInfoSnackBar(
                      'Lecture du rapport vocal du chef de chantier...'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  title: 'Matériaux',
                  subtitle: 'Stocks & Stocks bas',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFF059669),
                  onTap: () => setState(
                      () => _currentIndex = 1), // Redirige vers l'onglet Stocks
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildActionCard(
                  title: 'Appeler Chef',
                  subtitle: 'Contact direct',
                  icon: Icons.phone_rounded,
                  color: const Color(0xFFDC2626),
                  onTap: () =>
                      _showInfoSnackBar('Appel du responsable de chantier...'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Text(
            'Derniers Événements IA',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 15),

          // Liste des derniers événements résumés par l'IA
          _buildEventTile(
            title: 'Livraison de ciment validée',
            time: 'Il y a 2 heures',
            icon: Icons.check_circle_rounded,
            color: Colors.green,
          ),
          _buildEventTile(
            title: 'Rapport vocal enregistré par le contremaître',
            time: 'Hier à 16:30',
            icon: Icons.mic_rounded,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTile({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
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
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0F172A),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
