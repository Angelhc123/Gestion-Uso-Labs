import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart'; // Ajusta esta ruta si es necesario

InputDecoration buildInputDecoration(String label, {IconData? prefixIconData}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: accentPurple.withOpacity(0.8)),
    prefixIcon: prefixIconData != null ? Icon(prefixIconData, color: accentPurple.withOpacity(0.7)) : null,
    filled: true,
    fillColor: primaryDarkPurple.withOpacity(0.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: accentPurple.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(color: accentPurple, width: 1.5),
    ),
    errorStyle: const TextStyle(color: errorColor),
    hintStyle: TextStyle(color: textOnDarkSecondary.withOpacity(0.7)),
  );
}
