import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

InputDecoration adminInputDecoration(String label, {IconData? prefixIcon}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: accentPurple.withOpacity(0.8)), // Podría ser adminAccentPurple si se define
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: accentPurple.withOpacity(0.7)) : null,
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
