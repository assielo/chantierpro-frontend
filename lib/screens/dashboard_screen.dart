import 'package:flutter/material.dart';

import '../services/chantier_service.dart';
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
  final ChantierService _chantierService = ChantierService();
  late Future<Map<String, dynamic>> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    setState(() {
      _dashboardDataFuture = _chantierService.getDashboardData();
    });
  }

  void _openChantierMenu(BuildContext context, int projectId, String title) {
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
              Row(
                children: [
                  const Icon(Icons.apartment, color: Color(0xFF1E3A8A)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
                title: const Text('Budget & Stocks'),
                subtitle: const Text(
                  'Consulter les achats et niveaux de stock',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
                leading: const Icon(
                  Icons.report_problem_outlined,
                  color: Colors.orange,
                ),
                title: const Text('Réserves & Anomalies'),
                subtitle: const Text(
                  'Signaler et suivre les anomalies du site',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Erreur de connexion au serveur Laravel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadDashboardData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data ?? {};
          final stats = data['stats'] ?? {};
          final List chantiersList = data['chantiers'] ?? [];

          return SingleChildScrollView(
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

                // SECTION 1 : STATISTIQUES DYNAMIQUES
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
                          title: 'Chantiers',
                          mainStat:
                              '${stats['chantiers_en_cours'] ?? 0} en cours',
                          subStat:
                              '${stats['chantiers_termines'] ?? 0} terminés',
                          icon: Icons.construction,
                          color: Colors.blue,
                          isWide: isWide,
                        ),
                        SizedBox(
                          height: isWide ? 0 : 12,
                          width: isWide ? 12 : 0,
                        ),
                        _buildStatCard(
                          title: 'Devis',
                          mainStat:
                              '${stats['devis_en_attente'] ?? 0} en attente',
                          subStat: '${stats['devis_valides'] ?? 0} validés',
                          icon: Icons.assignment_outlined,
                          color: Colors.orange,
                          isWide: isWide,
                        ),
                        SizedBox(
                          height: isWide ? 0 : 12,
                          width: isWide ? 12 : 0,
                        ),
                        _buildStatCard(
                          title: 'Stocks',
                          mainStat: '${stats['stocks_rupture'] ?? 0} ruptures',
                          subStat: '${stats['total_stocks'] ?? 0} références',
                          icon: Icons.inventory_2_outlined,
                          color: Colors.red,
                          isWide: isWide,
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
                      icon: Icons.report_problem_outlined,
                      label: 'Signaler réserve',
                      color: const Color(0xFFDC2626),
                      onTap: () {
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

                const SizedBox(height: 28),

                // SECTION 3 : LISTE DES CHANTIERS DYNAMIQUES
                const Text(
                  'Chantiers récents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                chantiersList.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Text(
                          'Aucun chantier trouvé en base de données.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chantiersList.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade100),
                          itemBuilder: (context, index) {
                            final chantier = chantiersList[index];
                            final String title =
                                chantier['nom'] ??
                                chantier['title'] ??
                                'Chantier #${chantier['id']}';
                            final double progress =
                                (chantier['progression'] ?? 0.0) / 100.0;
                            final String status =
                                chantier['status'] ?? 'En cours';

                            return ListTile(
                              onTap: () => _openChantierMenu(
                                context,
                                chantier['id'],
                                title,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.apartment,
                                  color: Colors.blue,
                                ),
                              ),
                              title: Text(
                                title,
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
                                      value: progress,
                                      backgroundColor: Colors.grey.shade200,
                                      color: Colors.blue,
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Progression : ${(progress * 100).toInt()}%',
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
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.blue,
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
                      'Budget & Stocks',
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
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String mainStat,
    required String subStat,
    required IconData icon,
    required Color color,
    required bool isWide,
  }) {
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
