import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart'; // Asegúrate que esta importación sea correcta

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // El Scaffold ya no debería estar aquí si HomeView es solo el contenido
      backgroundColor: secondaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.home_work_outlined, size: 100, color: accentPurple.withOpacity(0.8)),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido al Sistema de Control de Laboratorios',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: textOnDark, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Seleccione una opción del menú para comenzar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textOnDarkSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
