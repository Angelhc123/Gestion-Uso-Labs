import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/schedule_view_definitions.dart';
import '../../../../../utils/app_colors.dart';

class ScheduleTableWidget extends StatelessWidget {
  final Map<String, List<ScheduleEvent>> scheduleEventsByDay;
  final List<String> daysOfWeek;
  final List<PedagogicalTimeSlotDefinition> pedagogicalTimeSlots;

  const ScheduleTableWidget({
    super.key,
    required this.scheduleEventsByDay,
    required this.daysOfWeek,
    required this.pedagogicalTimeSlots,
  });

  double _getEventTopPosition(ScheduleEvent event, BuildContext context) {
    double eventStartMinutesFromScheduleStart =
        ((event.startTime.hour * 60 + event.startTime.minute) - (kScheduleStartHour * 60)).toDouble();
    return eventStartMinutesFromScheduleStart * kPixelsPerMinute;
  }

  double _getEventHeight(ScheduleEvent event) {
    return event.durationInMinutes * kPixelsPerMinute;
  }

  @override
  Widget build(BuildContext context) {
    if (scheduleEventsByDay.isEmpty) {
      bool hasAnyEvent = false;
      scheduleEventsByDay.forEach((key, value) {
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
    const double timeColumnWidth = 70.0;

    // Constantes para el receso (ajustar si es necesario o hacerlo más dinámico)
    const int recessStartHour = 13;
    const int recessStartMinute = 50;

    // Calcular la altura total del cuerpo del horario basado en los bloques pedagógicos
    double totalScheduleBodyHeight = 0;
    for (var slot in pedagogicalTimeSlots) {
      totalScheduleBodyHeight += slot.durationInMinutes * kPixelsPerMinute;
    }

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
                  Container(height: dayHeaderHeight, width: timeColumnWidth, alignment: Alignment.center, child: const Text('Hora', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold))), 
                  ...pedagogicalTimeSlots.map((slot) { 
                    bool isRecess = slot.startTime.hour == recessStartHour && slot.startTime.minute == recessStartMinute;
                    // Altura dinámica para cada bloque de hora
                    final double slotHeight = slot.durationInMinutes * kPixelsPerMinute;
                    if (slotHeight <= 0) return const SizedBox.shrink(); // Evitar alturas negativas o cero

                    return Container(
                      width: timeColumnWidth, 
                      height: slotHeight, // Usar altura dinámica
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
              ...daysOfWeek.map((day) { 
                List<ScheduleEvent> eventsForDay = scheduleEventsByDay[day] ?? [];
                return Column(
                  children: [
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
                      child: Text(day.substring(0,3).toUpperCase(), style: const TextStyle(color: accentPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Container(
                      width: dayColumnWidth,
                      height: totalScheduleBodyHeight, // Usar altura total calculada
                      decoration: BoxDecoration(
                         border: Border(left: BorderSide(color: accentPurple.withOpacity(0.2))),
                      ),
                      child: Stack(
                        children: [
                          // Dibujar las líneas de división para cada bloque pedagógico
                          ...() {
                            List<Widget> lines = [];
                            double currentTop = 0;
                            for (var slot in pedagogicalTimeSlots) {
                              final double slotHeight = slot.durationInMinutes * kPixelsPerMinute;
                              if (slotHeight <= 0) continue;
                              lines.add(
                                Positioned(
                                  top: currentTop,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: slotHeight,
                                    decoration: BoxDecoration(
                                      border: Border(top: BorderSide(color: accentPurple.withOpacity(0.1))),
                                    ),
                                  ),
                                ),
                              );
                              currentTop += slotHeight;
                            }
                            return lines;
                          }(),
                          // Dibujar los eventos
                          ...eventsForDay.map((event) {
                            final finalTopPos = _getEventTopPosition(event, context);
                            final eventH = _getEventHeight(event).isFinite && _getEventHeight(event) > 0 
                                          ? _getEventHeight(event)
                                          : (kPedagogicalTimeSlotsForScheduleView.first.durationInMinutes * kPixelsPerMinute) / 5; // fallback height

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
                                  color: Colors.white.withOpacity(0.95),
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
                                          maxLines: (eventH / 12).floor().clamp(1, (eventH / 10).floor()), // Ajustar maxLines según altura
                                        ),
                                        if (eventH > 25) // Ajustar condición si es necesario
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
