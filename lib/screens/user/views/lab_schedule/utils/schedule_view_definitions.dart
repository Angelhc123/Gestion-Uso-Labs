import 'package:flutter/material.dart';

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
    this.color = Colors.blue,
  });

  int get durationInMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }
}

class PedagogicalTimeSlotDefinition { // Renombrado para evitar conflicto con el de request_lab
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String displayTimeStart;
  final String displayTimeEnd;

  PedagogicalTimeSlotDefinition({
    required this.startTime,
    required this.endTime,
    required this.displayTimeStart,
    required this.displayTimeEnd,
  });

  String get displayRange => "$displayTimeStart - $displayTimeEnd";

  // Nuevo getter para la duración
  int get durationInMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }
}

final List<PedagogicalTimeSlotDefinition> kPedagogicalTimeSlotsForScheduleView = [
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 8, minute: 0), endTime: const TimeOfDay(hour: 8, minute: 50), displayTimeStart: "08:00", displayTimeEnd: "08:50"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 8, minute: 50), endTime: const TimeOfDay(hour: 9, minute: 40), displayTimeStart: "08:50", displayTimeEnd: "09:40"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 9, minute: 40), endTime: const TimeOfDay(hour: 10, minute: 30), displayTimeStart: "09:40", displayTimeEnd: "10:30"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 10, minute: 30), endTime: const TimeOfDay(hour: 11, minute: 20), displayTimeStart: "10:30", displayTimeEnd: "11:20"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 11, minute: 20), endTime: const TimeOfDay(hour: 12, minute: 10), displayTimeStart: "11:20", displayTimeEnd: "12:10"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 12, minute: 10), endTime: const TimeOfDay(hour: 13, minute: 0), displayTimeStart: "12:10", displayTimeEnd: "13:00"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 13, minute: 0), endTime: const TimeOfDay(hour: 13, minute: 50), displayTimeStart: "13:00", displayTimeEnd: "13:50"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 13, minute: 50), endTime: const TimeOfDay(hour: 14, minute: 10), displayTimeStart: "13:50", displayTimeEnd: "14:10"), // RECESO
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 14, minute: 10), endTime: const TimeOfDay(hour: 15, minute: 0), displayTimeStart: "14:10", displayTimeEnd: "15:00"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 15, minute: 0), endTime: const TimeOfDay(hour: 15, minute: 50), displayTimeStart: "15:00", displayTimeEnd: "15:50"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 15, minute: 50), endTime: const TimeOfDay(hour: 16, minute: 40), displayTimeStart: "15:50", displayTimeEnd: "16:40"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 16, minute: 40), endTime: const TimeOfDay(hour: 17, minute: 30), displayTimeStart: "16:40", displayTimeEnd: "17:30"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 17, minute: 30), endTime: const TimeOfDay(hour: 18, minute: 20), displayTimeStart: "17:30", displayTimeEnd: "18:20"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 18, minute: 20), endTime: const TimeOfDay(hour: 19, minute: 10), displayTimeStart: "18:20", displayTimeEnd: "19:10"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 19, minute: 10), endTime: const TimeOfDay(hour: 20, minute: 0), displayTimeStart: "19:10", displayTimeEnd: "20:00"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 20, minute: 0), endTime: const TimeOfDay(hour: 20, minute: 50), displayTimeStart: "20:00", displayTimeEnd: "20:50"),
  PedagogicalTimeSlotDefinition(startTime: const TimeOfDay(hour: 20, minute: 50), endTime: const TimeOfDay(hour: 21, minute: 40), displayTimeStart: "20:50", displayTimeEnd: "21:40"),
];

const int kScheduleStartHour = 8; // Hora de inicio del horario visual
const double kPixelsPerMinute = 1.65; // Ajustado para dar más espacio vertical a las etiquetas de hora
