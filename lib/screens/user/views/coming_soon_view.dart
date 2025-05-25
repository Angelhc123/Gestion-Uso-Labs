import 'package:flutter/material.dart';

// Paleta de colores
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);

class ComingSoonView extends StatelessWidget {
  final String title;
  const ComingSoonView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.construction_outlined, size: 100, color: accentPurple.withOpacity(0.8)),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, color: textOnDark, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Esta sección estará disponible próximamente.',
            style: TextStyle(fontSize: 16, color: textOnDarkSecondary),
          ),
        ],
      ),
    );
  }
}
