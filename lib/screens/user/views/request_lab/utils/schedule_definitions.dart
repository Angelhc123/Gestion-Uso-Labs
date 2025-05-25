import 'package:flutter/material.dart';

// --- Definiciones Auxiliares de Horarios ---

class PedagogicalTimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String displayTimeStart;
  final String displayTimeEnd;
  final bool isRecess;

  PedagogicalTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.displayTimeStart,
    required this.displayTimeEnd,
    this.isRecess = false,
  });

  String get displayRange => "$displayTimeStart - $displayTimeEnd";

  int get startMinutesSinceMidnight => startTime.hour * 60 + startTime.minute;
  int get endMinutesSinceMidnight => endTime.hour * 60 + endTime.minute;
}

// Lista de bloques pedagógicos (exportada para ser usada en otros archivos)
final List<PedagogicalTimeSlot> kPedagogicalTimeSlotsList = [
  PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 8, minute: 0), endTime: const TimeOfDay(hour: 8, minute: 50), displayTimeStart: "08:00", displayTimeEnd: "08:50"),
  PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 8, minute: 50), endTime: const TimeOfDay(hour: 9, minute: 40), displayTimeStart: "08:50", displayTimeEnd: "09:40"),
  PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 9, minute: 40), endTime: const TimeOfDay(hour: 10, minute: 30), displayTimeStart: "09:40", displayTimeEnd: "10:30"),
  PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 10, minute: 30), endTime: const TimeOfDay(hour: 11, minute: 20), displayTimeStart: "10:30", displayTimeEnd: "11:20"),
  PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 11, minute: 20), endTime: const TimeOfDay(hour: 12, minute: 10), displayTimeStart: "11:20", displayTimeEnd: "12:10"),
  PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 12, minute: 10), endTime: const TimeOfDay(hour: 13, minute: 0), displayTimeStart: "12:10", displayTimeEnd: "13:00"),
  PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 13, minute: 0), endTime: const TimeOfDay(hour: 13, minute: 50), displayTimeStart: "13:00", displayTimeEnd: "13:50"),
  PedagogicalTimeSlot(startTime: const TimeOfDay(hour: 13, minute: 50), endTime: const TimeOfDay(hour: 14, minute: 10), displayTimeStart: "13:50", displayTimeEnd: "14:10", isRecess: true), // RECESO
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

class TimeRange {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeRange(this.startTime, this.endTime);

  int get startMinutesSinceMidnight => startTime.hour * 60 + startTime.minute;
  int get endMinutesSinceMidnight => endTime.hour * 60 + endTime.minute;

  bool overlapsWith(PedagogicalTimeSlot slot) {
    return startMinutesSinceMidnight < slot.endMinutesSinceMidnight &&
           endMinutesSinceMidnight > slot.startMinutesSinceMidnight;
  }
}
