import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/form_decorations.dart';
import '../../../../../utils/app_colors.dart';

class DateSelectorFormField extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDatePicked; // Callback para cuando se selecciona una fecha
  final String? Function(String?)? validator;

  const DateSelectorFormField({
    super.key,
    required this.selectedDate,
    required this.onDatePicked,
    this.validator,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)), 
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accentPurple,
              onPrimary: secondaryDark,
              surface: primaryDarkPurple,
              onSurface: textOnDark,
            ),
            dialogBackgroundColor: secondaryDark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      onDatePicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: buildInputDecoration(
        'Fecha de Solicitud*',
        prefixIconData: Icons.calendar_today_outlined,
      ),
      style: const TextStyle(color: textOnDark),
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate == null ? '' : DateFormat('dd/MM/yyyy (EEEE)', 'es_ES').format(selectedDate!),
      ),
      onTap: () => _selectDate(context),
      validator: validator,
    );
  }
}
