import 'package:controlusolab/models/laboratory_model.dart';
import 'package:flutter/material.dart';
import '../utils/lab_schedule_form_decorations.dart';
import '../../../../../utils/app_colors.dart';

class LaboratoryScheduleSelector extends StatelessWidget {
  final LaboratoryModel? selectedLaboratory;
  final List<LaboratoryModel> laboratories;
  final bool isLoadingLaboratories;
  final Function(LaboratoryModel?) onChanged;

  const LaboratoryScheduleSelector({
    super.key,
    required this.selectedLaboratory,
    required this.laboratories,
    required this.isLoadingLaboratories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingLaboratories) {
      return const Center(child: CircularProgressIndicator(color: accentPurple));
    }
    return DropdownButtonFormField<LaboratoryModel>(
      decoration: buildLabScheduleInputDecoration('Seleccionar Laboratorio'),
      value: selectedLaboratory,
      items: laboratories.map((LaboratoryModel lab) {
        return DropdownMenuItem<LaboratoryModel>(
          value: lab,
          child: Text(lab.name, style: const TextStyle(color: textOnDarkSecondary, overflow: TextOverflow.ellipsis)),
        );
      }).toList(),
      onChanged: onChanged,
      style: const TextStyle(color: textOnDark),
      dropdownColor: secondaryDark,
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: accentPurple),
    );
  }
}
