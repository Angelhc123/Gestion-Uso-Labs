import 'package:flutter/material.dart';

// Paleta de colores (puede moverse a un archivo de tema/constantes global)
const Color primaryDarkPurple = Color(0xFF381E72);
const Color secondaryDark = Color(0xFF1C1B1F);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí iría la lógica para obtener y mostrar los reportes.
    // Por ahora, un placeholder.
    return Scaffold(
      backgroundColor: secondaryDark,
      // El AppBar ya está en AdminScreen con el TabBar.
      // Si esta pantalla se usara de forma independiente, necesitaría su propio AppBar.
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.analytics_outlined, size: 100, color: accentPurple.withOpacity(0.8)),
              const SizedBox(height: 20),
              const Text(
                'Módulo de Reportes',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: textOnDark, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Esta sección mostrará varios reportes y estadísticas del uso de laboratorios.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: textOnDarkSecondary),
              ),
              const SizedBox(height: 30),
              Text(
                'Próximamente...',
                style: TextStyle(fontSize: 18, color: accentPurple.withOpacity(0.9), fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
