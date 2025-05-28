import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para Timestamp
import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/models/occupied_slot_model.dart'; // AÑADIDO
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

// Nueva clase para información detallada de slots ocupados
class OccupiedSlotInfo {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String eventName; // Nombre del curso o tema de la solicitud
  final bool isFixedSchedule; // Para diferenciar horarios fijos de solicitudes

  OccupiedSlotInfo({
    required this.startTime,
    required this.endTime,
    required this.eventName,
    required this.isFixedSchedule,
  });
}

class RequestLabView extends StatefulWidget {
  final List<LaboratoryModel> laboratories;
  final bool isLoadingLaboratories;
  final List<CourseModel> courses;
  final bool isLoadingCourses;
  // final Function(LaboratoryModel?) onLaboratorySelected; // ELIMINADA ESTA LÍNEA
  final Function() onRequestSubmitted;

  const RequestLabView({
    super.key,
    required this.laboratories,
    required this.isLoadingLaboratories,
    required this.courses,
    required this.isLoadingCourses,
    // required this.onLaboratorySelected, // ELIMINADA ESTA LÍNEA
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

  Set<int> _selectedSlotIndices = {}; // RESTAURADO: para manejar la selección del usuario
  List<OccupiedSlotInfo> _detailedOccupiedSlots = [];
  bool _isLoadingSchedule = false;
  TimeOfDay? _finalSelectedEntryTime;
  TimeOfDay? _finalSelectedExitTime;

  @override
  void initState() {
    super.initState();
    _professorName = _authService.currentUser?.displayName ?? _authService.currentUser?.email;
    _selectedDate = DateTime.now(); // Seleccionar hoy por defecto
    // No llamar a _loadOccupiedTimesForSelectedDayAndLab aquí si _selectedLaboratoryInForm es null
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _loadOccupiedTimesForSelectedDayAndLab() async {
    if (_selectedLaboratoryInForm == null || _selectedDate == null) {
      // Si no hay laboratorio o fecha, limpiar los slots y no cargar nada.
      setState(() {
        _isLoadingSchedule = false;
        _detailedOccupiedSlots = [];
        _selectedSlotIndices = {};
        _finalSelectedEntryTime = null;
        _finalSelectedExitTime = null;
      });
      return;
    }

    setState(() {
      _isLoadingSchedule = true;
      _detailedOccupiedSlots = []; // CAMBIADO
      _selectedSlotIndices = {};
      _finalSelectedEntryTime = null;
      _finalSelectedExitTime = null;
    });

    try {
      final lab = _selectedLaboratoryInForm!;
      final date = _selectedDate!;
      final dayOfWeek = DateFormat('EEEE', 'es_ES').format(date).toUpperCase();
      // El identificador para slots fijos debe coincidir con cómo se guardó en Firestore.
      // Si en Firestore se guarda el ID del laboratorio para OccupiedSlotModel, usa lab.id.
      // Si se guarda el nombre (como parece en temporal_data_upload), usa lab.name.
      // Por consistencia, es mejor usar lab.id si OccupiedSlotModel tiene laboratoryId.
      // Asumiendo que OccupiedSlotModel.laboratoryId es el NOMBRE del laboratorio:
      String labIdentifierForFixedSlots = lab.name; // CORREGIDO: Usar lab.name


      final List<dynamic> results = await Future.wait([
        _firestoreService.getOccupiedSlotsByLaboratoryAndDay(labIdentifierForFixedSlots, dayOfWeek).first, // CORREGIDO y usando labIdentifierForFixedSlots
        _firestoreService.getLabRequestsByLaboratoryAndDate(lab.id, date).first, // Para solicitudes, el ID del lab es correcto
      ]);

      final List<OccupiedSlotModel> fixedSlotsData = results[0] as List<OccupiedSlotModel>;
      final List<LabRequestModel> labRequestsData = results[1] as List<LabRequestModel>;

      List<OccupiedSlotInfo> newOccupiedSlotsInfo = []; // CAMBIADO

      for (var slot in fixedSlotsData) {
        newOccupiedSlotsInfo.add(OccupiedSlotInfo( // CAMBIADO
          startTime: _parseTimeOfDay(slot.startTime),
          endTime: _parseTimeOfDay(slot.endTime),
          eventName: slot.courseName ?? 'Horario Fijo',
          isFixedSchedule: true,
        ));
      }

      for (var req in labRequestsData) {
        if (req.status.toUpperCase() == 'APROBADO') {
          newOccupiedSlotsInfo.add(OccupiedSlotInfo( // CAMBIADO
            startTime: TimeOfDay.fromDateTime(req.entryTime.toDate().toLocal()),
            endTime: TimeOfDay.fromDateTime(req.exitTime.toDate().toLocal()),
            eventName: req.courseOrTheme,
            isFixedSchedule: false,
          ));
        }
      }
      if (!mounted) return;
      setState(() {
        _detailedOccupiedSlots = newOccupiedSlotsInfo; // CAMBIADO
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
    // if (_justification == null || _justification!.trim().isEmpty) { // Esta validación ya está en el TextFormField
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Por favor, ingrese una justificación.', style: TextStyle(color: textOnDark)), backgroundColor: warningColor),
    //   );
    //   setState(() => _isSubmitting = false);
    //   return;
    // }

    final String courseOrThemeValue = _selectedCourse!.name; 

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
      userName: _authService.currentUser?.displayName ?? _authService.currentUser?.email, 
      cycle: _cycle!,
      courseOrTheme: courseOrThemeValue,
      laboratoryId: _selectedLaboratoryInForm!.id,
      laboratoryName: _selectedLaboratoryInForm!.name, 
      entryTime: Timestamp.fromDate(entryDateTime),
      exitTime: Timestamp.fromDate(exitDateTime),
      requestDate: Timestamp.fromDate(_selectedDate!),
      status: 'PENDIENTE',
      professorName: _professorName,
      justification: _justification, // AÑADIDO: Guardar la justificación
      createdAt: Timestamp.now(),
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
         _detailedOccupiedSlots = []; // CAMBIADO
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
                    // Ya no se llama a widget.onLaboratorySelected para cambiar de vista.
                    // Solo se actualiza el estado local y se cargan los horarios.
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
                  // occupiedTimeRanges: _occupiedTimeRanges, // YA NO SE USA
                  detailedOccupiedSlots: _detailedOccupiedSlots, // AÑADIDO
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