import 'package:flutter/material.dart';
import '../utils/form_decorations.dart';
import '../../../../../utils/app_colors.dart';

class RequestTextFormField extends StatelessWidget {
  final String label;
  final IconData? prefixIconData;
  final String? initialValue;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final int? maxLines; // Nueva propiedad
  final TextInputType? keyboardType; // Nueva propiedad

  const RequestTextFormField({
    super.key,
    required this.label,
    this.prefixIconData,
    this.initialValue,
    this.onSaved,
    this.validator,
    this.controller,
    this.maxLines = 1, // Por defecto una línea
    this.keyboardType, // Por defecto el tipo de teclado estándar
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null, // initialValue no se usa si hay controller
      decoration: buildInputDecoration(label, prefixIconData: prefixIconData),
      style: const TextStyle(color: textOnDark),
      onSaved: onSaved,
      validator: validator,
      maxLines: maxLines, // Aplicar maxLines
      keyboardType: keyboardType, // Aplicar keyboardType
    );
  }
}
