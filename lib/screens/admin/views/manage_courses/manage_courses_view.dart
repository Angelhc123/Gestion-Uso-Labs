import 'package:flutter/material.dart';
import 'package:controlusolab/utils/app_colors.dart';

class ManageCoursesView extends StatelessWidget {
  const ManageCoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Gestionar Cursos (Próximamente)',
        style: TextStyle(fontSize: 18, color: textOnDarkSecondary),
      ),
    );
  }
}
