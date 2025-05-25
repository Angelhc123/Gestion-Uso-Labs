import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart'; // Asegúrate que esta importación sea correcta

class ComingSoonView extends StatelessWidget {
  final String title;
  const ComingSoonView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // El Scaffold ya no debería estar aquí si ComingSoonView es solo el contenido
      backgroundColor: secondaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.construction_outlined, size: 100, color: accentPurple.withOpacity(0.8)),
            const SizedBox(height: 20),
            Text(
              title, // El título ya se pasa como parámetro
              style: const TextStyle(fontSize: 22, color: textOnDark, fontWeight: FontWeight.bold),
            ),
             const SizedBox(height: 10),
            Text(
              // Mensaje más genérico o específico si se desea
              '"$title" estará disponible próximamente.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: textOnDarkSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
