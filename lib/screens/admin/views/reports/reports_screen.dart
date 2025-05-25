import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart'; // Importar colores globales

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implementar la UI de la pantalla de reportes
    return Scaffold(
      backgroundColor: adminViewSecondaryDark, // O secondaryDark si no hay color específico de admin
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 80, color: adminViewAccentPurple), // O accentPurple
            const SizedBox(height: 20),
            const Text(
              'Pantalla de Reportes',
              style: TextStyle(fontSize: 24, color: textOnDark, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Esta sección mostrará varios reportes y estadísticas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textOnDark.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
