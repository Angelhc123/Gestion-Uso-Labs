import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/models/occupied_slot_model.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Paleta de colores
const Color primaryDarkPurple = Color(0xFF381E72);
const Color secondaryDark = Color(0xFF1C1B1F);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);

enum ScheduleEventType { fixedSlot, labRequest }

class ScheduleEvent {
  final String id;
  final String title;
  final String dayOfWeek; // LUNES, MARTES, etc.
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ScheduleEventType type;
  final String? originalId; // ID del documento original en Firestore
  final Color color;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.originalId,
    this.color = Colors.blue, // Color por defecto
  });

  int get durationInMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }

  // Asumiendo que el horario visual empieza a las 8:00 AM
  // Esta constante ahora se tomará de LabScheduleView.scheduleStartHour
  // static const int scheduleStartHour = 8; // Eliminar de aquí

  double get topPosition {
    const double currentPixelsPerMinute = _LabScheduleViewState.pixelsPerMinute; // Acceder a través del estado
    double eventStartMinutesFromScheduleStart =
        ((startTime.hour * 60 + startTime.minute) - (LabScheduleView.scheduleStartHour * 60)).toDouble();
    return eventStartMinutesFromScheduleStart * currentPixelsPerMinute;
  }

  double get eventHeight {
    const double currentPixelsPerMinute = _LabScheduleViewState.pixelsPerMinute; // Acceder a través del estado
    return durationInMinutes * currentPixelsPerMinute;
  }
}

class LabScheduleView extends StatefulWidget {
  final List<LaboratoryModel> laboratories;
  final bool isLoadingLaboratories;
  final LaboratoryModel? initiallySelectedLab;

  // Definir la constante aquí para que sea accesible por ScheduleEvent y el State
  static const int scheduleStartHour = 8;

  const LabScheduleView({
    super.key,
    required this.laboratories,
    required this.isLoadingLaboratories,
    this.initiallySelectedLab,
  });

  @override
  State<LabScheduleView> createState() => _LabScheduleViewState();
}

class PedagogicalTimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String displayTimeStart;
  final String displayTimeEnd;

  PedagogicalTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.displayTimeStart,
    required this.displayTimeEnd,
  });

  String get displayRange => "$displayTimeStart - $displayTimeEnd";
}

class _LabScheduleViewState extends State<LabScheduleView> {
  final FirestoreService _firestoreService = FirestoreService();
  LaboratoryModel? _selectedLaboratoryForSchedule;
  bool _isLoadingScheduleData = false;
  Map<String, List<ScheduleEvent>> _scheduleEventsByDay = {}; // Eventos agrupados por día
  
  // Horas para mostrar en la columna de tiempo (bloques pedagógicos)
  final List<PedagogicalTimeSlot> _pedagogicalTimeSlots = [
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 8, minute: 0), endTime: const TimeOfDay(hour: 8, minute: 50), displayTimeStart: "08:00", displayTimeEnd: "08:50"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 8, minute: 50), endTime: const TimeOfDay(hour: 9, minute: 40), displayTimeStart: "08:50", displayTimeEnd: "09:40"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 9, minute: 40), endTime: const TimeOfDay(hour: 10, minute: 30), displayTimeStart: "09:40", displayTimeEnd: "10:30"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 10, minute: 30), endTime: const TimeOfDay(hour: 11, minute: 20), displayTimeStart: "10:30", displayTimeEnd: "11:20"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 11, minute: 20), endTime: const TimeOfDay(hour: 12, minute: 10), displayTimeStart: "11:20", displayTimeEnd: "12:10"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 12, minute: 10), endTime: const TimeOfDay(hour: 13, minute: 0), displayTimeStart: "12:10", displayTimeEnd: "13:00"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 13, minute: 0), endTime: const TimeOfDay(hour: 13, minute: 50), displayTimeStart: "13:00", displayTimeEnd: "13:50"),
    // RECESO
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 13, minute: 50), endTime: const TimeOfDay(hour: 14, minute: 10), displayTimeStart: "13:50", displayTimeEnd: "14:10"), 
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 14, minute: 10), endTime: const TimeOfDay(hour: 15, minute: 0), displayTimeStart: "14:10", displayTimeEnd: "15:00"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 15, minute: 0), endTime: const TimeOfDay(hour: 15, minute: 50), displayTimeStart: "15:00", displayTimeEnd: "15:50"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 15, minute: 50), endTime: const TimeOfDay(hour: 16, minute: 40), displayTimeStart: "15:50", displayTimeEnd: "16:40"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 16, minute: 40), endTime: const TimeOfDay(hour: 17, minute: 30), displayTimeStart: "16:40", displayTimeEnd: "17:30"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 17, minute: 30), endTime: const TimeOfDay(hour: 18, minute: 20), displayTimeStart: "17:30", displayTimeEnd: "18:20"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 18, minute: 20), endTime: const TimeOfDay(hour: 19, minute: 10), displayTimeStart: "18:20", displayTimeEnd: "19:10"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 19, minute: 10), endTime: const TimeOfDay(hour: 20, minute: 0), displayTimeStart: "19:10", displayTimeEnd: "20:00"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 20, minute: 0), endTime: const TimeOfDay(hour: 20, minute: 50), displayTimeStart: "20:00", displayTimeEnd: "20:50"),
    PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 20, minute: 50), endTime: const TimeOfDay(hour: 21, minute: 40), displayTimeStart: "20:50", displayTimeEnd: "21:40"),
  ];

  final List<String> _daysOfWeek = ['LUNES', 'MARTES', 'MIÉRCOLES', 'JUEVES', 'VIERNES', 'SÁBADO'];
  
  final Map<String, Color> _eventColorsCache = {};
  int _nextColorIndex = 0;
  final List<Color> _eventPalette = [
    Colors.blue.shade300, Colors.green.shade300, Colors.orange.shade300, Colors.purple.shade300,
    Colors.red.shade300, Colors.teal.shade300, Colors.pink.shade300, Colors.amber.shade300,
    Colors.indigo.shade300, Colors.cyan.shade300, Colors.brown.shade300, Colors.lime.shade300
  ];

  static const double heightPerTimeSlotLabel = 60.0; // Renombrado de pixelsPerHour para claridad
  static const double pixelsPerMinute = 1.0; // 1 minuto de evento = 1 pixel de altura

  // Para que un evento de 50 minutos ocupe la altura de una etiqueta de bloque pedagógico:
  static const double pedagogicalBlockDisplayHeight = 50.0; // Altura visual de cada fila de hora pedagógica
  // pixelsPerMinute se mantiene en 1.0, lo que significa que un evento de 50 minutos tendrá 50px de alto.

  @override
  void initState() {
    super.initState();
    if (widget.initiallySelectedLab != null) {
      _selectedLaboratoryForSchedule = widget.initiallySelectedLab;
      _loadScheduleDataForLab(_selectedLaboratoryForSchedule);
    } else if (widget.laboratories.isNotEmpty) {
      // Opcional: seleccionar el primero si no hay selección inicial de UserScreen
      // _selectedLaboratoryForSchedule = widget.laboratories.first;
      // _loadScheduleDataForLab(_selectedLaboratoryForSchedule);
    }
  }
  
  @override
  void didUpdateWidget(covariant LabScheduleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallySelectedLab != oldWidget.initiallySelectedLab && widget.initiallySelectedLab != null) {
      // Solo actualizar y recargar si el ID del laboratorio realmente cambió
      if (_selectedLaboratoryForSchedule?.id != widget.initiallySelectedLab!.id) {
         if (mounted) { // Verificar mounted antes de setState
            setState(() {
              _selectedLaboratoryForSchedule = widget.initiallySelectedLab;
              _loadScheduleDataForLab(_selectedLaboratoryForSchedule);
            });
         }
      }
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentPurple.withOpacity(0.8)),
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
      hintStyle: TextStyle(color: textOnDarkSecondary.withOpacity(0.7)),
    );
  }
  
  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Color _getColorForEventTitle(String eventTitle) {
    if (_eventColorsCache.containsKey(eventTitle)) {
      return _eventColorsCache[eventTitle]!;
    }
    final color = _eventPalette[_nextColorIndex % _eventPalette.length];
    _nextColorIndex++;
    _eventColorsCache[eventTitle] = color;
    return color;
  }

  Future<void> _loadScheduleDataForLab(LaboratoryModel? lab) async {
    if (lab == null) {
      if (mounted) {
        setState(() {
          _scheduleEventsByDay = {};
          _isLoadingScheduleData = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingScheduleData = true;
        _scheduleEventsByDay = {}; 
        _eventColorsCache.clear(); 
        _nextColorIndex = 0;
      });
    }

    Map<String, List<ScheduleEvent>> eventsMap = {};
    for (String day in _daysOfWeek) {
      eventsMap[day] = [];
    }

    try {
      String labIdentifierForFixedSlots = lab.name.replaceAll(' ', '_').replaceAll('(', '').replaceAll(')', '').toUpperCase();
      // Cargar horarios fijos
      for (String dayKey in _daysOfWeek) {
        final fixedSlotsData = await _firestoreService.getOccupiedSlotsByLaboratoryAndDay(labIdentifierForFixedSlots, dayKey).first;
        for (var slot in fixedSlotsData) {
          final eventTitle = slot.courseName ?? 'Clase Fija';
          eventsMap[dayKey]!.add(ScheduleEvent(
            id: 'fixed_${slot.slotId}',
            title: eventTitle,
            dayOfWeek: slot.dayOfWeek.toUpperCase(),
            startTime: _parseTimeOfDay(slot.startTime),
            endTime: _parseTimeOfDay(slot.endTime),
            type: ScheduleEventType.fixedSlot,
            originalId: slot.slotId,
            color: _getColorForEventTitle(eventTitle),
          ));
        }
      }

      // Cargar solicitudes aprobadas
      final labRequestsData = await _firestoreService.getLabRequestsByLaboratoryId(lab.id).first;
      for (var req in labRequestsData) {
        if (req.status == 'approved') {
          String dayOfWeek = DateFormat('EEEE', 'es_ES').format(req.entryTime.toLocal()).toUpperCase();
          if (eventsMap.containsKey(dayOfWeek)) {
             final eventTitle = req.courseOrTheme;
            eventsMap[dayOfWeek]!.add(ScheduleEvent(
              id: 'request_${req.id}',
              title: eventTitle,
              dayOfWeek: dayOfWeek,
              startTime: TimeOfDay.fromDateTime(req.entryTime.toLocal()),
              endTime: TimeOfDay.fromDateTime(req.exitTime.toLocal()),
              type: ScheduleEventType.labRequest,
              originalId: req.id,
              color: _getColorForEventTitle(eventTitle),
            ));
          }
        }
      }
      if (!mounted) return; // Verificar mounted después de operaciones asíncronas
      setState(() {
        _scheduleEventsByDay = eventsMap;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos del horario: $e', style: const TextStyle(color: textOnDark)), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) { // Verificar mounted antes de setState
        setState(() {
          _isLoadingScheduleData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (widget.isLoadingLaboratories)
            const Center(child: CircularProgressIndicator(color: accentPurple))
          else
            DropdownButtonFormField<LaboratoryModel>(
              decoration: _inputDecoration('Seleccionar Laboratorio'),
              value: _selectedLaboratoryForSchedule,
              items: widget.laboratories.map((LaboratoryModel lab) {
                return DropdownMenuItem<LaboratoryModel>(
                  value: lab,
                  child: Text(lab.name, style: const TextStyle(color: textOnDarkSecondary, overflow: TextOverflow.ellipsis)),
                );
              }).toList(),
              onChanged: (LaboratoryModel? newValue) {
                setState(() {
                  _selectedLaboratoryForSchedule = newValue;
                  _loadScheduleDataForLab(newValue); 
                });
              },
              style: const TextStyle(color: textOnDark),
              dropdownColor: secondaryDark,
              isExpanded: true,
            ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoadingScheduleData
                ? const Center(child: CircularProgressIndicator(color: accentPurple))
                : _selectedLaboratoryForSchedule == null
                    ? const Center(child: Text('Por favor, seleccione un laboratorio para ver su horario.', style: TextStyle(color: textOnDarkSecondary, fontSize: 16), textAlign: TextAlign.center,))
                    : _buildScheduleTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTable() {
    if (_scheduleEventsByDay.isEmpty && !_isLoadingScheduleData) {
      bool hasAnyEvent = false;
      _scheduleEventsByDay.forEach((key, value) {
        if (value.isNotEmpty) hasAnyEvent = true;
      });
      if (!hasAnyEvent) {
        return const Center(
          child: Text(
            'No hay eventos programados para este laboratorio.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textOnDarkSecondary, fontSize: 16),
          ),
        );
      }
    }
    
    const double dayColumnWidth = 150.0; 
    const double dayHeaderHeight = 30.0;

    // Constantes para el receso
    const int recessStartHour = 13;
    const int recessStartMinute = 50;
    const int recessEndHour = 14;
    const int recessEndMinute = 10;
    final recessStartTimeInMinutes = recessStartHour * 60 + recessStartMinute;
    final recessEndTimeInMinutes = recessEndHour * 60 + recessEndMinute;
    final durationOfRecessInMinutes = recessEndTimeInMinutes - recessStartTimeInMinutes; // 20 min
    final double visualHeightOfRecessBlock = _LabScheduleViewState.pedagogicalBlockDisplayHeight; // Usar nombre completo
    final double actualTimeHeightOfRecess = durationOfRecessInMinutes * _LabScheduleViewState.pixelsPerMinute; // Usar nombre completo para pixelsPerMinute también por consistencia
    final double recessVisualAdjustment = (visualHeightOfRecessBlock - actualTimeHeightOfRecess > 0) 
                                          ? visualHeightOfRecessBlock - actualTimeHeightOfRecess 
                                          : 0; 

    return SingleChildScrollView( 
      child: SingleChildScrollView( 
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: accentPurple.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna de Horas
              Column(
                children: [
                  Container(height: dayHeaderHeight, width: 70, alignment: Alignment.center, child: Text('Hora', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold))), 
                  ..._pedagogicalTimeSlots.map((slot) { 
                    bool isRecess = slot.startTime.hour == recessStartHour && slot.startTime.minute == recessStartMinute;
                    return Container(
                      width: 70, 
                      height: _LabScheduleViewState.pedagogicalBlockDisplayHeight, // Usar nombre completo
                      alignment: Alignment.center, 
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2), 
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: accentPurple.withOpacity(0.2)),
                          right: BorderSide(color: accentPurple.withOpacity(0.3)),
                        ),
                        color: isRecess ? accentPurple.withOpacity(0.15) : primaryDarkPurple.withOpacity(0.1), 
                      ),
                      child: Column( 
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot.displayTimeStart,
                            style: TextStyle(fontSize: 10, color: isRecess ? accentPurple : textOnDarkSecondary),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            slot.displayTimeEnd,
                            style: TextStyle(fontSize: 10, color: isRecess ? accentPurple : textOnDarkSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
              // Columnas de Días
              ..._daysOfWeek.map((day) { 
                List<ScheduleEvent> eventsForDay = _scheduleEventsByDay[day] ?? [];
                return Column(
                  children: [
                    // Cabecera del Día
                    Container(
                      width: dayColumnWidth,
                      height: dayHeaderHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                         color: primaryDarkPurple.withOpacity(0.3),
                         border: Border(
                           bottom: BorderSide(color: accentPurple.withOpacity(0.3)),
                           left: BorderSide(color: accentPurple.withOpacity(0.2)), 
                          ),
                      ),
                      child: Text(day.substring(0,3).toUpperCase(), style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    // Contenedor para los eventos del día (Stack)
                    Container(
                      width: dayColumnWidth,
                      height: _pedagogicalTimeSlots.length * _LabScheduleViewState.pedagogicalBlockDisplayHeight, // Usar nombre completo
                      decoration: BoxDecoration(
                         border: Border(left: BorderSide(color: accentPurple.withOpacity(0.2))),
                      ),
                      child: Stack(
                        children: [
                          // Líneas de división horaria
                          ..._pedagogicalTimeSlots.asMap().entries.map((entry) { 
                            return Positioned(
                              top: entry.key * _LabScheduleViewState.pedagogicalBlockDisplayHeight, // Usar nombre completo
                              left: 0,
                              right: 0,
                              child: Container(
                                height: _LabScheduleViewState.pedagogicalBlockDisplayHeight, // Usar nombre completo
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: accentPurple.withOpacity(0.1))),
                                ),
                              ),
                            );
                          }).toList(),
                          // Eventos
                          ...eventsForDay.map((event) {
                            final scheduleStartHourInMinutes = LabScheduleView.scheduleStartHour * 60;
                            final eventStartTimeInMinutes = event.startTime.hour * 60 + event.startTime.minute;
                            
                            double baseTop = (eventStartTimeInMinutes - scheduleStartHourInMinutes) * _LabScheduleViewState.pixelsPerMinute; // Usar nombre completo
                            double finalTopPos = baseTop;

                            if (eventStartTimeInMinutes >= recessEndTimeInMinutes && recessVisualAdjustment > 0) {
                                finalTopPos += recessVisualAdjustment;
                            } 
                            else if (eventStartTimeInMinutes >= recessStartTimeInMinutes && 
                                     eventStartTimeInMinutes < recessEndTimeInMinutes && 
                                     recessVisualAdjustment > 0) {
                                finalTopPos += recessVisualAdjustment;
                            }

                            final eventH = event.eventHeight.isFinite && event.eventHeight > 0 
                                          ? event.eventHeight 
                                          : _LabScheduleViewState.pedagogicalBlockDisplayHeight / 5; // Usar nombre completo

                            return Positioned(
                              top: finalTopPos, 
                              left: 2, 
                              width: dayColumnWidth - 4, 
                              height: eventH,
                              child: Tooltip(
                                message: '${event.title}\n${event.startTime.format(context)} - ${event.endTime.format(context)}',
                                preferBelow: false,
                                textStyle: const TextStyle(color: Colors.black, fontSize: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95), // Más opaco
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    )
                                  ]
                                ),
                                child: Card(
                                  color: event.color.withOpacity(0.9),
                                  elevation: 1,
                                  margin: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 0.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0), 
                                    child: Column( 
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start, 
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            color: Colors.black87, 
                                            fontSize: 10, 
                                            fontWeight: FontWeight.w600 
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: (eventH / 12).floor().clamp(1, 3), 
                                        ),
                                        if (eventH > 25) 
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Text(
                                              "${event.startTime.format(context)} - ${event.endTime.format(context)}",
                                              style: TextStyle(
                                                color: Colors.black.withOpacity(0.7), 
                                                fontSize: 8, 
                                                fontWeight: FontWeight.normal,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                )
                              );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
