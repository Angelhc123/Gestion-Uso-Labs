import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/app_colors.dart';
import './utils/schedule_view_definitions.dart';
import './widgets/schedule_table_widget.dart';
import './widgets/laboratory_schedule_selector.dart';

class LabScheduleView extends StatefulWidget {
  final List<LaboratoryModel> laboratories;
  final bool isLoadingLaboratories;
  final LaboratoryModel? initiallySelectedLab;

  const LabScheduleView({
    super.key,
    required this.laboratories,
    required this.isLoadingLaboratories,
    this.initiallySelectedLab,
  });

  @override
  State<LabScheduleView> createState() => _LabScheduleViewState();
}

class _LabScheduleViewState extends State<LabScheduleView> {
  final FirestoreService _firestoreService = FirestoreService();
  LaboratoryModel? _selectedLaboratoryForSchedule;
  bool _isLoadingScheduleData = false;
  Map<String, List<ScheduleEvent>> _scheduleEventsByDay = {};

  final List<String> _daysOfWeek = [
    'LUNES',
    'MARTES',
    'MIÉRCOLES',
    'JUEVES',
    'VIERNES',
    'SÁBADO'
  ];

  final Map<String, Color> _eventColorsCache = {};
  int _nextColorIndex = 0;
  final List<Color> _eventPalette = [
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.orange.shade300,
    Colors.purple.shade300,
    Colors.red.shade300,
    Colors.teal.shade300,
    Colors.pink.shade300,
    Colors.amber.shade300,
    Colors.indigo.shade300,
    Colors.cyan.shade300,
    Colors.brown.shade300,
    Colors.lime.shade300
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initiallySelectedLab != null) {
      _selectedLaboratoryForSchedule = widget.initiallySelectedLab;
      _loadScheduleDataForLab(_selectedLaboratoryForSchedule);
    } else if (widget.laboratories.isNotEmpty) {
      // Opcional: seleccionar el primero
      // _selectedLaboratoryForSchedule = widget.laboratories.first;
      // _loadScheduleDataForLab(_selectedLaboratoryForSchedule);
    }
  }

  @override
  void didUpdateWidget(covariant LabScheduleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallySelectedLab != oldWidget.initiallySelectedLab &&
        widget.initiallySelectedLab != null) {
      if (_selectedLaboratoryForSchedule?.id !=
          widget.initiallySelectedLab!.id) {
        if (mounted) {
          setState(() {
            _selectedLaboratoryForSchedule = widget.initiallySelectedLab;
            _loadScheduleDataForLab(_selectedLaboratoryForSchedule);
          });
        }
      }
    }
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
      String labIdentifierForFixedSlots = lab.name
          .replaceAll(' ', '_')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .toUpperCase();
      for (String dayKey in _daysOfWeek) {
        final fixedSlotsData = await _firestoreService
            .getOccupiedSlotsByLaboratoryAndDay(labIdentifierForFixedSlots, dayKey)
            .first;
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

      final labRequestsData = await _firestoreService
          .getLabRequestsByLaboratoryId(lab.id)
          .first;
      for (var req in labRequestsData) {
        if (req.status == 'approved') {
          String dayOfWeek = DateFormat('EEEE', 'es_ES')
              .format(req.entryTime.toLocal())
              .toUpperCase();
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
      if (!mounted) return;
      setState(() {
        _scheduleEventsByDay = eventsMap;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos del horario: $e',
              style: const TextStyle(color: textOnDark)),
          backgroundColor: errorColor,
        ),
      );
    } finally {
      if (mounted) {
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
          LaboratoryScheduleSelector(
            selectedLaboratory: _selectedLaboratoryForSchedule,
            laboratories: widget.laboratories,
            isLoadingLaboratories: widget.isLoadingLaboratories,
            onChanged: (LaboratoryModel? newValue) {
              setState(() {
                _selectedLaboratoryForSchedule = newValue;
                _loadScheduleDataForLab(newValue); 
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoadingScheduleData
                ? const Center(child: CircularProgressIndicator(color: accentPurple))
                : _selectedLaboratoryForSchedule == null
                    ? const Center(
                        child: Text(
                          'Por favor, seleccione un laboratorio para ver su horario.',
                          style: TextStyle(
                              color: textOnDarkSecondary, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ScheduleTableWidget(
                        scheduleEventsByDay: _scheduleEventsByDay,
                        daysOfWeek: _daysOfWeek,
                        pedagogicalTimeSlots: kPedagogicalTimeSlotsForScheduleView,
                      ),
          ),
        ],
      ),
    );
  }
}
