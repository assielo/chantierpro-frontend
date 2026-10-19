import 'package:flutter/material.dart';

import 'reserves_screen.dart';
import 'budget_stocks_screen.dart';
import 'chantier_form_screen.dart';

class ChantierDashboardScreen extends StatefulWidget {
  const ChantierDashboardScreen({super.key});

  @override
  State<ChantierDashboardScreen> createState() =>
      _ChantierDashboardScreenState();
}

class _ChantierDashboardScreenState extends State<ChantierDashboardScreen> {
  final List<Map<String, dynamic>> _chantiers = [
    {
      'id': 1,
      'title': 'Villa R+1 - Cocody Angré',
      'progress': 0.65,
      'progressText': '65%',
      'status': 'En cours',
      'color': Colors.blue,
    },
    {
      'id': 2,
      'title': 'Rénovation Bureaux - Plateau',
      'progress': 0.20,
      'progressText': '20%',
      'status': 'En attente',
      'color': Colors.orange,
    },
    {
      'id': 3,
      'title': 'Immeuble Commercial - Marcory',
      'progress': 1.0,
      'progressText': '100%',
      'status': 'Terminé',
      'color': Colors.green,
    },
  ];

  void _navigateToChantier(BuildContext context, int projectId, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.inventory_2, color: Colors.blue),
                title: const Text('Budget & Stocks'),
                subtitle: const Text('Suivi des matériaux et dépenses'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BudgetStocksScreen(projectId: projectId),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_problem, color: Colors.orange),
                title: const Text('Réserves & Anomalies'),
                subtitle: const Text('Gestion des réserves du chantier'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReservesScreen(projectId: projectId),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('ChantierPro - Tableau de Bord Global'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenue sur ChantierPro',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pilotage et suivi de vos activités de construction',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // SECTION 1 : STATISTIQUES
            const Text(
              'Indicateurs clés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 700;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      'Chantiers',
                      '${_chantiers.length} actifs',
                      '12 terminés',
                      Icons.construction,
                      Colors.blue,
                      isWide,
                    ),
                    SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                    _buildStatCard(
                      'Devis',
                      '4 en attente',
                      '18 validés',
                      Icons.assignment_outlined,
                      Colors.orange,
                      isWide,
                    ),
                    SizedBox(height: isWide ? 0 : 12, width: isWide ? 12 : 0),
                    _buildStatCard(
                      'Stocks',
                      '3 ruptures',
                      '45 références',
                      Icons.inventory_2,
                      Colors.red,
                      isWide,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // SECTION 2 : ACTIONS RAPIDES
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionChip(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Créer un chantier',
                  color: const Color(0xFF1E3A8A),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChantierFormScreen(),
                      ),
                    );
                  },
                ),
                _buildActionChip(
                  context,
                  icon: Icons.note_add_outlined,
                  label: 'Établir un devis',
                  color: const Color(0xFFD97706),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChantierFormScreen(),
                      ),
                    );
                  },
                ),
                _buildActionChip(
                  context,
                  icon: Icons.menu_book_outlined,
                  label: 'Journal de chantier',
                  color: const Color(0xFF059669),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ouverture du journal de chantier...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // SECTION 3 : LISTE DES CHANTIERS RÉCENTS
            const Text(
              'Chantiers récents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _chantiers.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final chantier = _chantiers[index];
                  return ListTile(
                    onTap: () => _navigateToChantier(
                      context,
                      chantier['id'] as int,
                      chantier['title'] as String,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (chantier['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.apartment,
                        color: chantier['color'] as Color,
                      ),
                    ),
                    title: Text(
                      chantier['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: chantier['progress'] as double,
                            backgroundColor: Colors.grey.shade200,
                            color: chantier['color'] as Color,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Progression : ${chantier['progressText']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Chip(
                      label: Text(
                        chantier['status'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: chantier['color'] as Color,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // SECTION 4 : MODULES DE GESTION
            const Text(
              'Modules de gestion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              children: [
                _buildDashboardCard(
                  context,
                  'Budget & Stocks (Projet 1)',
                  Icons.inventory,
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const BudgetStocksScreen(projectId: 1),
                      ),
                    );
                  },
                ),
                _buildDashboardCard(
                  context,
                  'Réserves & Suivi',
                  Icons.assignment_late,
                  Colors.red,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ReservesScreen(projectId: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String mainStat,
    String subStat,
    IconData icon,
    Color color,
    bool isWide,
  ) {
    Widget cardContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            mainStat,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subStat,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );

    if (isWide) {
      return Expanded(child: cardContent);
    }
    return cardContent;
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
