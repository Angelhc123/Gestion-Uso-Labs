import 'package:flutter/material.dart';
import '../utils/form_decorations.dart'; // Usaremos la misma decoración
import '../../../../../utils/app_colors.dart';

class CycleSelectorDropdown extends StatelessWidget {
  final String? selectedCycle;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const CycleSelectorDropdown({
    super.key,
    required this.selectedCycle,
    required this.onChanged,
    this.validator,
  });

  // Lista de ciclos en números romanos
  static const List<String> _romanCycles = [
    'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X'
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: buildInputDecoration('Ciclo*', prefixIconData: Icons.school_outlined),
      value: selectedCycle,
      items: _romanCycles.map((String cycle) {
        return DropdownMenuItem<String>(
          value: cycle,
          child: Text(cycle, style: const TextStyle(color: textOnDarkSecondary)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: textOnDark),
      dropdownColor: primaryDarkPurple.withOpacity(0.95),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: accentPurple),
    );
  }
}
