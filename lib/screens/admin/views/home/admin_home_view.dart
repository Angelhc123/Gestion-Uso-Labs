import 'package:flutter/material.dart';
import 'package:controlusolab/utils/app_colors.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Bienvenido al Panel de Administrador',
        style: TextStyle(fontSize: 20, color: textOnDarkSecondary),
      ),
    );
  }
}
