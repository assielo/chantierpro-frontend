import 'package:flutter/material.dart';

// Importations des 5 écrans principaux
import '../calculator/calculator_screen.dart';
import '../projects/projects_list_screen.dart';
import '../logs/daily_log_screen.dart';
import '../reserves/reserve_screen.dart';
import '../stocks/stock_screen.dart';

// Référence vers le token global défini dans l'authentification
String? globalToken;

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CalculatorScreen(),
    ProjectsListScreen(),
    DailyLogScreen(),
    ReserveScreen(),
    StockScreen(),
  ];

  final List<String> _titles = const [
    'Calculateur de Métré',
    'Mes Chantiers',
    'Journal de Chantier',
    'Levées de Réserves',
    'Gestion des Stocks',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              globalToken = null;
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber[900],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Métré'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Chantiers'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber), label: 'Réserves'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Stocks'),
        ],
      ),
    );
  }
}