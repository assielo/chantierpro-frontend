import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExportScreen extends StatelessWidget {
  final int projectId;
  final String token;

  const ExportScreen({Key? key, required this.projectId, required this.token})
      : super(key: key);

  Future<void> _generateAndOpenExcel(BuildContext context) async {
    try {
      // 1. Création d'un classeur Excel
      var excel = Excel.createExcel();

      // Renommer la feuille par défaut
      Sheet sheetObject = excel['Rapport Chantier'];
      excel.delete('Sheet1'); // Supprimer l'ancienne feuille par défaut

      // 2. Ajout des en-têtes
      sheetObject.appendRow([
        TextCellValue('Module'),
        TextCellValue('Description'),
        TextCellValue('Valeur / Quantité'),
        TextCellValue('Date')
      ]);

      // 3. Ajout de lignes de données (Exemple pour le projet Résidence Akwaba)
      sheetObject.appendRow([
        TextCellValue('Ferraillage'),
        TextCellValue('Acier à béton (HA)'),
        TextCellValue('1500 kg'),
        TextCellValue(DateTime.now().toString().split(' ')[0])
      ]);
      sheetObject.appendRow([
        TextCellValue('Parpaings'),
        TextCellValue('Blocs creux 15x20x40'),
        TextCellValue('3750 unités'),
        TextCellValue(DateTime.now().toString().split(' ')[0])
      ]);
      sheetObject.appendRow([
        TextCellValue('Sable'),
        TextCellValue('Sable de rivière'),
        TextCellValue('54.0 m³'),
        TextCellValue(DateTime.now().toString().split(' ')[0])
      ]);
      sheetObject.appendRow([
        TextCellValue('Gravier'),
        TextCellValue('Gravier concassé 15/25'),
        TextCellValue('42.0 m³'),
        TextCellValue(DateTime.now().toString().split(' ')[0])
      ]);

      // 4. Sauvegarde du fichier dans le répertoire temporaire ou de téléchargement de l'appareil
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String filePath =
          "${directory?.path ?? ''}/Rapport_Chantier_Projet_$projectId.xlsx";

      // Encodage et écriture du fichier
      List<int>? fileBytes = excel.encode();
      if (fileBytes != null) {
        File file = File(filePath);
        await file.writeAsBytes(fileBytes);

        // Notification de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Fichier Excel exporté avec succès : $filePath')),
        );

        // Ouvrir automatiquement le fichier
        await OpenFile.open(filePath);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’export Excel : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export de Rapports (.xlsx)'),
        backgroundColor: Colors.amber[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Génération de tableaux Excel',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ce module compile les données du projet en cours (matériaux, stocks, avancement) sous format .xlsx tableur exploitable sur Microsoft Excel ou Google Sheets.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _generateAndOpenExcel(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text(
                'Télécharger le rapport Excel (.xlsx)',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
