import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/models/occupied_slot_model.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Paleta de colores (puede importarse de un archivo común)
const Color primaryDarkPurple = Color(0xFF381E72);
const Color secondaryDark = Color(0xFF1C1B1F);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);

class RequestLabView extends StatefulWidget {
  final List<LaboratoryModel> laboratories;
  final bool isLoadingLaboratories; // Puede usarse para mostrar un loader si es true
  final List<CourseModel> courses;
  final bool isLoadingCourses; // Puede usarse para mostrar un loader si es true
  final Function(LaboratoryModel?) onLaboratorySelected; // Callback para UserScreen
  final Function() onRequestSubmitted; // Callback para UserScreen

  const RequestLabView({
    super.key,
    required this.laboratories,
    required this.isLoadingLaboratories,
    required this.courses,
    required this.isLoadingCourses,
    required this.onLaboratorySelected,
    required this.onRequestSubmitted,
  });

  @override
  State<RequestLabView> createState() => _RequestLabViewState();
}

class _RequestLabViewState extends State<RequestLabView> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  String? _cycle;
  String? _courseOrTheme; 
  DateTime? _selectedDate;
  LaboratoryModel? _selectedLaboratoryInForm; // Estado local para el lab seleccionado en este formulario
  TimeOfDay? _selectedEntrySlot;
  TimeOfDay? _selectedExitSlot;
  CourseModel? _selectedCourse;
  bool _isSubmitting = false;
  // Para el campo de texto del tema, si no se selecciona curso
  final TextEditingController _themeController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Si hay laboratorios y ninguno está seleccionado, y UserScreen no pasó uno,
    // podríamos seleccionar el primero por defecto o dejarlo vacío.
    // _selectedLaboratoryInForm = widget.laboratories.isNotEmpty ? widget.laboratories.first : null;
    // widget.onLaboratorySelected(_selectedLaboratoryInForm); // Notificar a UserScreen
  }
  
  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentPurple.withOpacity(0.8)),
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
      errorStyle: const TextStyle(color: Colors.redAccent),
      hintStyle: TextStyle(color: textOnDarkSecondary.withOpacity(0.7)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      if (!mounted) return;
      setState(() {
        _selectedDate = picked;
        _selectedEntrySlot = null; 
        _selectedExitSlot = null;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isEntryTime) async {
    if (_selectedLaboratoryInForm == null || _selectedDate == null) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un laboratorio y una fecha primero.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    TimeOfDay? initialTime = isEntryTime ? _selectedEntrySlot : _selectedExitSlot;
    initialTime ??= const TimeOfDay(hour: 8, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accentPurple,
              onPrimary: secondaryDark,
              surface: primaryDarkPurple,
              onSurface: textOnDark,
              secondary: accentPurple, 
            ),
            dialogBackgroundColor: secondaryDark,
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: secondaryDark,
              hourMinuteTextColor: textOnDark,
              dialHandColor: accentPurple,
              dialTextColor: textOnDark,
              entryModeIconColor: accentPurple,
              helpTextStyle: TextStyle(color: accentPurple),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;
      setState(() {
        if (isEntryTime) {
          _selectedEntrySlot = picked;
          if (_selectedExitSlot != null &&
              (picked.hour > _selectedExitSlot!.hour ||
               (picked.hour == _selectedExitSlot!.hour && picked.minute >= _selectedExitSlot!.minute))) {
            _selectedExitSlot = null;
          }
        } else {
          if (_selectedEntrySlot != null &&
              (picked.hour < _selectedEntrySlot!.hour ||
               (picked.hour == _selectedEntrySlot!.hour && picked.minute <= _selectedEntrySlot!.minute))) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('La hora de salida debe ser posterior a la hora de entrada.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.orangeAccent),
            );
            return; 
          }
          _selectedExitSlot = picked;
        }
      });
    }
  }
  
  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrija los errores del formulario.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.orangeAccent),
      );
      return;
    }
    
    _formKey.currentState!.save(); 
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    if (_selectedCourse == null && (_courseOrTheme == null || _courseOrTheme!.trim().isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un curso o ingrese un tema.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.orangeAccent),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    
    final String courseOrThemeValue = _selectedCourse?.name ?? _courseOrTheme!;

    if (_selectedDate == null || _selectedEntrySlot == null || _selectedExitSlot == null || _selectedLaboratoryInForm == null || _cycle == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos requeridos.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.orangeAccent),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.redAccent),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    DateTime entryDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedEntrySlot!.hour, _selectedEntrySlot!.minute);
    DateTime exitDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedExitSlot!.hour, _selectedExitSlot!.minute);

    if (exitDateTime.isBefore(entryDateTime) || exitDateTime.isAtSameMomentAs(entryDateTime)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La hora de salida debe ser posterior a la hora de entrada.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.orangeAccent),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    
    final String selectedDayOfWeek = DateFormat('EEEE', 'es_ES').format(_selectedDate!).toUpperCase();
    String occupiedSlotsQueryLabId = _selectedLaboratoryInForm!.name.replaceAll(' ', '_').replaceAll('(', '').replaceAll(')', '').toUpperCase();

    try {
      final List<OccupiedSlotModel> fixedSlotsForDay = await _firestoreService.getOccupiedSlotsByLaboratoryAndDay(occupiedSlotsQueryLabId, selectedDayOfWeek).first;
      for (var fixedSlot in fixedSlotsForDay) {
        TimeOfDay fixedStartTimeOfDay = _parseTimeOfDay(fixedSlot.startTime);
        TimeOfDay fixedEndTimeOfDay = _parseTimeOfDay(fixedSlot.endTime);
        DateTime fixedStartDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, fixedStartTimeOfDay.hour, fixedStartTimeOfDay.minute);
        DateTime fixedEndDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, fixedEndTimeOfDay.hour, fixedEndTimeOfDay.minute);

        if (entryDateTime.isBefore(fixedEndDateTime) && exitDateTime.isAfter(fixedStartDateTime)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Conflicto con clase fija: ${fixedSlot.courseName ?? "Clase"} (${fixedSlot.startTime} - ${fixedSlot.endTime})', style: const TextStyle(color: textOnDark)), backgroundColor: Colors.orangeAccent),
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }

      // Corregir aquí: usar .first para obtener una lista de un stream
      final List<LabRequestModel> existingRequestsList = await _firestoreService.getLabRequestsByLaboratoryAndDate(_selectedLaboratoryInForm!.id, _selectedDate!).first;
      for (var req in existingRequestsList) { // Iterar sobre la lista
        if (req.status == 'rejected') continue;
        DateTime reqStartDateTime = req.entryTime;
        DateTime reqEndDateTime = req.exitTime;
        if (entryDateTime.isBefore(reqEndDateTime) && exitDateTime.isAfter(reqStartDateTime)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conflicto con otra solicitud existente en ese horario.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.orangeAccent),
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }

      LabRequestModel newRequest = LabRequestModel(
        id: '', 
        userId: userId,
        cycle: _cycle!,
        courseOrTheme: courseOrThemeValue,
        laboratory: _selectedLaboratoryInForm!.name,
        laboratoryId: _selectedLaboratoryInForm!.id,
        entryTime: entryDateTime,
        exitTime: exitDateTime,
        requestTime: DateTime.now(),
        status: 'pending',
      );

      await _firestoreService.addLabRequest(newRequest);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada con éxito.', style: TextStyle(color: textOnDark)), backgroundColor: Colors.green),
      );
      _formKey.currentState!.reset();
      _themeController.clear(); // Limpiar el controlador del tema
      setState(() {
        _cycle = null;
        _selectedCourse = null;
        _courseOrTheme = null; // Limpiar el tema
        _selectedDate = DateTime.now();
        _selectedEntrySlot = null;
        _selectedExitSlot = null;
        _selectedLaboratoryInForm = null; 
        widget.onLaboratorySelected(null); // Notificar a UserScreen que no hay lab seleccionado
      });
      widget.onRequestSubmitted(); // Notificar a UserScreen para cambiar de vista
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar solicitud: $e', style: const TextStyle(color: textOnDark)), backgroundColor: Colors.redAccent),
      );
    } finally {
      if(mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingLaboratories || widget.isLoadingCourses) {
      return const Center(child: CircularProgressIndicator(color: accentPurple));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Ciclo Académico', prefixIcon: Icons.school_outlined),
                items: ['2024-I', '2024-II', '2025-I', '2025-II', 'Otro'] 
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label, style: const TextStyle(color: textOnDarkSecondary)),
                        ))
                    .toList(),
                value: _cycle,
                onChanged: (value) {
                  setState(() {
                    _cycle = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Seleccione un ciclo' : null,
                style: const TextStyle(color: textOnDark),
                dropdownColor: secondaryDark,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<CourseModel>(
                decoration: _inputDecoration('Curso (Opcional)', prefixIcon: Icons.book_outlined),
                value: _selectedCourse,
                items: widget.courses.map((CourseModel course) {
                  return DropdownMenuItem<CourseModel>(
                    value: course,
                    child: Text(course.name, style: const TextStyle(color: textOnDarkSecondary, overflow: TextOverflow.ellipsis)),
                  );
                }).toList(),
                onChanged: (CourseModel? newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                    if (newValue != null) {
                      _courseOrTheme = null; 
                      _themeController.clear(); // Limpiar tema si se selecciona curso
                    }
                  });
                },
                style: const TextStyle(color: textOnDark),
                dropdownColor: secondaryDark,
                isExpanded: true,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _themeController,
                style: const TextStyle(color: textOnDark),
                decoration: _inputDecoration('Tema (Si no seleccionó curso)', prefixIcon: Icons.topic_outlined),
                onChanged: (value) {
                  setState(() {
                    _courseOrTheme = value.trim();
                     if (value.trim().isNotEmpty) {
                        _selectedCourse = null; 
                     }
                  });
                },
                // No se necesita validator aquí si la validación combinada se hace en _submitRequest
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<LaboratoryModel>(
                decoration: _inputDecoration('Laboratorio', prefixIcon: Icons.computer_outlined),
                value: _selectedLaboratoryInForm,
                items: widget.laboratories.map((LaboratoryModel lab) {
                  return DropdownMenuItem<LaboratoryModel>(
                    value: lab,
                    child: Text(lab.name, style: const TextStyle(color: textOnDarkSecondary, overflow: TextOverflow.ellipsis)),
                  );
                }).toList(),
                onChanged: (LaboratoryModel? newValue) {
                  setState(() {
                    _selectedLaboratoryInForm = newValue;
                  });
                  widget.onLaboratorySelected(newValue); // Notificar a UserScreen
                },
                validator: (value) => value == null ? 'Seleccione un laboratorio' : null,
                style: const TextStyle(color: textOnDark),
                dropdownColor: secondaryDark,
                isExpanded: true,
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today, color: secondaryDark),
                label: Text(
                  _selectedDate == null ? 'Seleccionar Fecha' : 'Fecha: ${DateFormat.yMd('es_ES').format(_selectedDate!)}',
                  style: const TextStyle(color: secondaryDark, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.access_time, color: secondaryDark, size: 20),
                      label: Text(
                        _selectedEntrySlot == null ? 'Entrada' : _selectedEntrySlot!.format(context),
                        style: const TextStyle(color: secondaryDark, fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: accentPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.access_time_filled, color: secondaryDark, size: 20),
                      label: Text(
                        _selectedExitSlot == null ? 'Salida' : _selectedExitSlot!.format(context),
                        style: const TextStyle(color: secondaryDark, fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: accentPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _isSubmitting
                  ? const Center(child: CircularProgressIndicator(color: accentPurple))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.send, color: primaryDarkPurple),
                      label: const Text('Enviar Solicitud', style: TextStyle(color: primaryDarkPurple, fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPurple,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _submitRequest,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
