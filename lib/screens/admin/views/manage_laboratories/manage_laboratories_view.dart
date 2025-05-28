import 'package:flutter/material.dart';
import 'package:controlusolab/utils/app_colors.dart';

class ManageLaboratoriesView extends StatelessWidget {
  const ManageLaboratoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Gestionar Laboratorios (Próximamente)',
        style: TextStyle(fontSize: 18, color: textOnDarkSecondary),
      ),
    );
  }
}
