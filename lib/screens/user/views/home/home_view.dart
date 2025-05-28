import 'package:flutter/material.dart';
import 'package:controlusolab/utils/app_colors.dart'; // Asegúrate de que esta ruta sea correcta

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: secondaryDark, // Fondo consistente con el UserScreen
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.home_work_outlined, // Puedes cambiar esto por un ImageIcon si tienes un logo
              size: 100,
              color: accentPurple.withOpacity(0.8),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bienvenido al Portal de Usuario',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textOnDark,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'Utiliza el menú lateral para navegar por las opciones disponibles, como solicitar laboratorios, ver horarios y gestionar tus solicitudes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textOnDarkSecondary.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
