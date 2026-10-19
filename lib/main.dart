import 'package:flutter/material.dart';
import 'screens/projects_screen.dart'; // Assurez-vous que ProjectsScreen est bien dans lib/screens/projects_screen.dart
import 'screens/login_screen.dart';

void main() {
  runApp(const ChantierProApp());
}

class ChantierProApp extends StatelessWidget {
  const ChantierProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChantierPro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(), // 👈 Point de départ : l'écran de connexion
      debugShowCheckedModeBanner: false,
    );
  }
}
