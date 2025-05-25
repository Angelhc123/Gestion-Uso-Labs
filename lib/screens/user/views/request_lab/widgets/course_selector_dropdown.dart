import 'package:controlusolab/models/course_model.dart';
import 'package:flutter/material.dart';
import '../utils/form_decorations.dart'; // Usaremos la misma decoración
import '../../../../../utils/app_colors.dart';

class CourseSelectorDropdown extends StatelessWidget {
  final CourseModel? selectedCourse;
  final List<CourseModel> courses;
  final Function(CourseModel?) onChanged;
  final String? Function(CourseModel?)? validator;
  final bool isLoading;

  const CourseSelectorDropdown({
    super.key,
    required this.selectedCourse,
    required this.courses,
    required this.onChanged,
    this.validator,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: accentPurple),
            ),
            const SizedBox(width: 16),
            Text("Cargando cursos...", style: TextStyle(color: textOnDarkSecondary.withOpacity(0.7))),
          ],
        ),
      );
    }

    return DropdownButtonFormField<CourseModel>(
      decoration: buildInputDecoration('Curso*', prefixIconData: Icons.book_outlined),
      value: selectedCourse,
      items: courses.map((CourseModel course) {
        return DropdownMenuItem<CourseModel>(
          value: course,
          child: Text(course.name, style: const TextStyle(color: textOnDarkSecondary, overflow: TextOverflow.ellipsis)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: textOnDark),
      dropdownColor: primaryDarkPurple.withOpacity(0.95),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: accentPurple),
      hint: courses.isEmpty ? const Text("No hay cursos disponibles", style: TextStyle(color: textOnDarkSecondary)) : null,
    );
  }
}
