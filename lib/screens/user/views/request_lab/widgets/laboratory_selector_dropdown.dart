import 'package:controlusolab/models/laboratory_model.dart';
import 'package:flutter/material.dart';
import '../utils/form_decorations.dart';
import '../../../../../utils/app_colors.dart';

class LaboratorySelectorDropdown extends StatelessWidget {
  final LaboratoryModel? selectedLaboratory;
  final List<LaboratoryModel> laboratories;
  final Function(LaboratoryModel?) onChanged;
  final String? Function(LaboratoryModel?)? validator;

  const LaboratorySelectorDropdown({
    super.key,
    required this.selectedLaboratory,
    required this.laboratories,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<LaboratoryModel>(
      decoration: buildInputDecoration('Laboratorio*', prefixIconData: Icons.lan_outlined),
      value: selectedLaboratory,
      items: laboratories.map((LaboratoryModel lab) {
        return DropdownMenuItem<LaboratoryModel>(
          value: lab,
          child: Text(lab.name, style: const TextStyle(color: textOnDarkSecondary, overflow: TextOverflow.ellipsis)),
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
