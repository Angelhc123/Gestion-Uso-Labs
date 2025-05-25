import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
// Asumiendo que tienes un modelo para los slots ocupados, por ejemplo:
// import 'package:controlusolab/models/occupied_slot_model.dart'; 
// Si no es así, necesitarás el tipo correcto para fixedSlotsData.
// Por ahora, usaré 'dynamic' y luego puedes ajustarlo.
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import './utils/schedule_definitions.dart'; 
import './widgets/time_slot_selector_grid.dart';
import '../../../../utils/app_colors.dart';
// Importar los widgets y utilidades de esta feature
import './utils/form_decorations.dart';
import './widgets/laboratory_selector_dropdown.dart';
import './widgets/date_selector_form_field.dart';
import './widgets/request_text_form_field.dart';
import './widgets/submit_request_button.dart';
import './widgets/cycle_selector_dropdown.dart';
import './widgets/course_selector_dropdown.dart'; // Importar el nuevo widget

class RequestLabView extends StatefulWidget {
  final List<LaboratoryModel> laboratories;
  final bool isLoadingLaboratories;
  final List<CourseModel> courses;
  final bool isLoadingCourses;
  final Function(LaboratoryModel?) onLaboratorySelected;
  final Function() onRequestSubmitted;

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

  LaboratoryModel? _selectedLaboratoryInForm;
  DateTime? _selectedDate;
  CourseModel? _selectedCourse;
  // String? _courseOrTheme; // Este se derivará de _selectedCourse o un campo "Otro" si se implementa
  String? _cycle;
  String? _professorName;
  String? _justification; // Nuevo estado para la justificación
  bool _isSubmitting = false;

  Set<int> _selectedSlotIndices = {};
  List<TimeRange> _occupiedTimeRanges = [];
  bool _isLoadingSchedule = false;
  TimeOfDay? _finalSelectedEntryTime;
  TimeOfDay? _finalSelectedExitTime;

  @override
  void initState() {
    super.initState();
    _professorName = _authService.currentUser?.displayName ?? _authService.currentUser?.email;
    _selectedDate = DateTime.now();
    if (_selectedLaboratoryInForm != null && _selectedDate != null) {
      _loadOccupiedTimesForSelectedDayAndLab();
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _loadOccupiedTimesForSelectedDayAndLab() async {
    if (_selectedLaboratoryInForm == null || _selectedDate == null) return;

    setState(() {
      _isLoadingSchedule = true;
      _occupiedTimeRanges = [];
      _selectedSlotIndices = {};
      _finalSelectedEntryTime = null;
      _finalSelectedExitTime = null;
    });

    try {
      final lab = _selectedLaboratoryInForm!;
      final date = _selectedDate!;
      final dayOfWeek = DateFormat('EEEE', 'es_ES').format(date).toUpperCase();
      String labIdentifierForFixedSlots = lab.name.replaceAll(' ', '_').replaceAll('(', '').replaceAll(')', '').toUpperCase();

      // Ejecutar ambas consultas en paralelo
      final List<dynamic> results = await Future.wait([
        _firestoreService.getOccupiedSlotsByLaboratoryAndDay(labIdentifierForFixedSlots, dayOfWeek).first,
        _firestoreService.getLabRequestsByLaboratoryAndDate(lab.id, date).first,
      ]);

      // Asignar los resultados a sus respectivas variables
      // TODO: Reemplaza 'dynamic' con el tipo correcto de tu OccupiedSlotModel si lo tienes.
      // Ejemplo: final List<OccupiedSlotModel> fixedSlotsData = results[0] as List<OccupiedSlotModel>;
      final List<dynamic> fixedSlotsData = results[0] as List<dynamic>; // Ajusta este tipo
      final List<LabRequestModel> labRequestsData = results[1] as List<LabRequestModel>;

      List<TimeRange> occupied = [];

      // Asegúrate de que 'slot.startTime' y 'slot.endTime' existan en los objetos de fixedSlotsData
      for (var slot in fixedSlotsData) {
        // Si fixedSlotsData es List<OccupiedSlotModel>, esto sería slot.startTime, slot.endTime
        // Si es List<Map<String, dynamic>> directamente de Firestore, sería slot['startTime'], slot['endTime']
        // Ajusta el acceso a las propiedades según la estructura real de 'slot'
        occupied.add(TimeRange(_parseTimeOfDay(slot.startTime as String), _parseTimeOfDay(slot.endTime as String)));
      }

      for (var req in labRequestsData) {
        if (req.status == 'approved') {
          occupied.add(TimeRange(
            TimeOfDay.fromDateTime(req.entryTime.toLocal()),
            TimeOfDay.fromDateTime(req.exitTime.toLocal()),
          ));
        }
      }
      if (!mounted) return;
      setState(() {
        _occupiedTimeRanges = occupied;
        _isLoadingSchedule = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingSchedule = false;
      });
      if (kDebugMode) print("Error cargando horarios ocupados: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar disponibilidad: $e', style: const TextStyle(color: textOnDark)), backgroundColor: errorColor),
      );
    }
  }

  // _isSlotOccupied se mueve a TimeSlotSelectorGrid

  void _handleSlotSelection(int slotIndex) {
    // La lógica de si está ocupado ya la maneja el widget TimeSlotSelectorGrid
    // al no llamar a onSlotSelected si está ocupado.

    setState(() {
      Set<int> newSelection = Set.from(_selectedSlotIndices);

      if (newSelection.contains(slotIndex)) { 
        newSelection.remove(slotIndex);
      } else { 
        if (newSelection.isEmpty) {
          newSelection.add(slotIndex);
        } else if (newSelection.length == 1) {
          int existingIndex = newSelection.first;
          // Usar kPedagogicalTimeSlotsList de schedule_definitions.dart
          if ((slotIndex == existingIndex + 1 && !kPedagogicalTimeSlotsList[existingIndex].isRecess) || 
              (slotIndex == existingIndex - 1 && !kPedagogicalTimeSlotsList[slotIndex].isRecess)) {
            newSelection.add(slotIndex);
          } else { 
            newSelection.clear();
            newSelection.add(slotIndex);
          }
        } else { 
          newSelection.clear();
          newSelection.add(slotIndex);
        }
      }
      _selectedSlotIndices = newSelection;
      _updateSelectedTimesFromIndices();
    });
  }
  
  void _updateSelectedTimesFromIndices() {
    if (_selectedSlotIndices.isEmpty) {
      _finalSelectedEntryTime = null;
      _finalSelectedExitTime = null;
    } else {
      List<int> sortedIndices = _selectedSlotIndices.toList()..sort();
      // Usar kPedagogicalTimeSlotsList de schedule_definitions.dart
      _finalSelectedEntryTime = kPedagogicalTimeSlotsList[sortedIndices.first].startTime;
      _finalSelectedExitTime = kPedagogicalTimeSlotsList[sortedIndices.last].endTime;
    }
     if (kDebugMode) {
      print("Horas seleccionadas actualizadas: Entrada: $_finalSelectedEntryTime, Salida: $_finalSelectedExitTime");
    }
  }


  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrija los errores del formulario.', style: TextStyle(color: textOnDark)), backgroundColor: warningColor),
      );
      return;
    }
    
    _formKey.currentState!.save(); 
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    // Validar que se haya seleccionado un curso
    if (_selectedCourse == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un curso.', style: TextStyle(color: textOnDark)), backgroundColor: warningColor),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    
    // Validar que se haya ingresado una justificación
    if (_justification == null || _justification!.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese una justificación.', style: TextStyle(color: textOnDark)), backgroundColor: warningColor),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final String courseOrThemeValue = _selectedCourse!.name; // Usar el nombre del curso seleccionado

    if (_finalSelectedEntryTime == null || _finalSelectedExitTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione un bloque horario.', style: TextStyle(color: textOnDark)), backgroundColor: warningColor),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    
    if (_selectedDate == null || _selectedLaboratoryInForm == null || _cycle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos requeridos.', style: TextStyle(color: textOnDark)), backgroundColor: warningColor),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado.', style: TextStyle(color: textOnDark)), backgroundColor: errorColor),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    DateTime entryDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _finalSelectedEntryTime!.hour, _finalSelectedEntryTime!.minute);
    DateTime exitDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _finalSelectedExitTime!.hour, _finalSelectedExitTime!.minute);

    if (exitDateTime.isBefore(entryDateTime) || exitDateTime.isAtSameMomentAs(entryDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La hora de salida debe ser posterior a la hora de entrada.', style: TextStyle(color: textOnDark)), backgroundColor: warningColor),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    
    // La validación de conflicto con horarios fijos y otras solicitudes ahora se maneja visualmente
    // al no permitir seleccionar bloques ocupados. Se podría añadir una doble verificación aquí por si acaso.
    // Por simplicidad, la omitiremos por ahora, confiando en la UI.

    LabRequestModel newRequest = LabRequestModel(
      id: '', 
      userId: userId,
      cycle: _cycle!,
      courseOrTheme: courseOrThemeValue, // Usar el nombre del curso
      laboratory: _selectedLaboratoryInForm!.name,
      laboratoryId: _selectedLaboratoryInForm!.id,
      entryTime: entryDateTime,
      exitTime: exitDateTime,
      requestTime: DateTime.now(),
      status: 'pending',
      justification: _justification, // Añadir justificación
    );

    await _firestoreService.addLabRequest(newRequest);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud enviada con éxito.', style: TextStyle(color: textOnDark)), backgroundColor: successColor),
    );
    _formKey.currentState!.reset();
    setState(() {
      _cycle = null;
      _selectedCourse = null;
      // _courseOrTheme = null; // Ya no se usa directamente
      _justification = null; // Resetear justificación
      _selectedDate = DateTime.now(); 
      _selectedSlotIndices = {};
      _finalSelectedEntryTime = null;
      _finalSelectedExitTime = null;
      
      if (_selectedLaboratoryInForm != null) {
        _loadOccupiedTimesForSelectedDayAndLab();
      } else {
         _occupiedTimeRanges = [];
      }
    });
    widget.onRequestSubmitted(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              LaboratorySelectorDropdown(
                selectedLaboratory: _selectedLaboratoryInForm,
                laboratories: widget.laboratories,
                onChanged: (LaboratoryModel? newValue) {
                  setState(() {
                    _selectedLaboratoryInForm = newValue;
                    widget.onLaboratorySelected(newValue); 
                  });
                  _loadOccupiedTimesForSelectedDayAndLab(); 
                },
                validator: (value) => value == null ? 'Seleccione un laboratorio' : null,
              ),
              const SizedBox(height: 16),

              DateSelectorFormField(
                selectedDate: _selectedDate,
                onDatePicked: (pickedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                  _loadOccupiedTimesForSelectedDayAndLab();
                },
                validator: (value) => (_selectedDate == null || value == null || value.isEmpty) ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 16),

              if (_selectedLaboratoryInForm != null && _selectedDate != null)
                TimeSlotSelectorGrid(
                  selectedIndices: _selectedSlotIndices,
                  occupiedTimeRanges: _occupiedTimeRanges,
                  onSlotSelected: _handleSlotSelection,
                  isLoading: _isLoadingSchedule,
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Seleccione un laboratorio y una fecha para ver los horarios disponibles.", style: TextStyle(color: textOnDarkSecondary)),
                ),
              const SizedBox(height: 16),
              
              CourseSelectorDropdown(
                selectedCourse: _selectedCourse,
                courses: widget.courses,
                isLoading: widget.isLoadingCourses,
                onChanged: (CourseModel? newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                  });
                },
                validator: (value) => value == null ? 'Seleccione un curso' : null,
              ),
              const SizedBox(height: 16),

              RequestTextFormField(
                label: 'Justificación de la Solicitud*',
                prefixIconData: Icons.comment_outlined,
                onSaved: (value) => _justification = value,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese una justificación' : null,
                maxLines: 3, 
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),

              CycleSelectorDropdown(
                selectedCycle: _cycle,
                onChanged: (String? newValue) {
                  setState(() {
                    _cycle = newValue;
                  });
                },
                validator: (value) => (value == null || value.isEmpty) ? 'Seleccione el ciclo' : null,
              ),
              const SizedBox(height: 16),

              RequestTextFormField(
                label: 'Nombre del Docente*',
                prefixIconData: Icons.person_outline,
                initialValue: _professorName, 
                onSaved: (value) => _professorName = value,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Ingrese el nombre del docente' : null,
              ),
              const SizedBox(height: 24),

              SubmitRequestButton(
                isSubmitting: _isSubmitting,
                onPressed: _submitRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}