import 'package:flutter/material.dart';
import '../utils/schedule_definitions.dart'; // Para kPedagogicalTimeSlotsList y PedagogicalTimeSlot
import '../../../../../utils/app_colors.dart';
import '../request_lab_view.dart'; // Para OccupiedSlotInfo

class TimeSlotSelectorGrid extends StatelessWidget {
  final Set<int> selectedIndices;
  // final List<TimeRange> occupiedTimeRanges; // YA NO SE USA
  final List<OccupiedSlotInfo> detailedOccupiedSlots; // AÑADIDO
  final Function(int) onSlotSelected;
  final bool isLoading;

  const TimeSlotSelectorGrid({
    super.key,
    required this.selectedIndices,
    // required this.occupiedTimeRanges, // YA NO SE USA
    required this.detailedOccupiedSlots, // AÑADIDO
    required this.onSlotSelected,
    this.isLoading = false,
  });

  // Helper para convertir TimeOfDay a un valor comparable (minutos desde medianoche)
  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  // Helper para formatear TimeOfDay a HH:MM
  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hour.toString().padLeft(2, '0');
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  OccupiedSlotInfo? _getOccupyingInfo(TimeOfDay slotStartTime, TimeOfDay slotEndTime) {
    final slotStartMinutes = _timeOfDayToMinutes(slotStartTime);
    final slotEndMinutes = _timeOfDayToMinutes(slotEndTime);

    for (var occupiedInfo in detailedOccupiedSlots) {
      final occupiedStartMinutes = _timeOfDayToMinutes(occupiedInfo.startTime);
      final occupiedEndMinutes = _timeOfDayToMinutes(occupiedInfo.endTime);

      // Comprobar superposición
      if (slotStartMinutes < occupiedEndMinutes && slotEndMinutes > occupiedStartMinutes) {
        return occupiedInfo;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: accentPurple));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // Ajusta según sea necesario
        childAspectRatio: 2.5, // Ajusta para el tamaño de los botones
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: kPedagogicalTimeSlotsList.length,
      itemBuilder: (context, index) {
        final slot = kPedagogicalTimeSlotsList[index];
        // Construir la etiqueta de tiempo directamente
        final String timeLabel = '${_formatTimeOfDay(slot.startTime)} - ${_formatTimeOfDay(slot.endTime)}';

        if (slot.isRecess) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade800, // Color para recesos
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              // slot.recessLabel ?? timeLabel, // CORREGIDO: recessLabel no existe
              "Descanso", // O usar timeLabel si se prefiere mostrar la hora del receso
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
            ),
          );
        }

        final occupyingInfo = _getOccupyingInfo(slot.startTime, slot.endTime);
        final bool isOccupied = occupyingInfo != null;
        final bool isSelected = selectedIndices.contains(index);

        Color buttonColor = primaryDarkPurple.withOpacity(0.8);
        Color textColor = accentPurple;
        String eventText = timeLabel; // Usar la etiqueta de tiempo generada
        FontWeight fontWeight = FontWeight.normal;

        if (isOccupied) {
          buttonColor = Colors.grey.shade700; // Color para slots ocupados
          textColor = Colors.grey.shade400;
          eventText = "$timeLabel\n${occupyingInfo!.eventName}"; // Usar la etiqueta de tiempo generada
          fontWeight = FontWeight.bold;
        } else if (isSelected) {
          buttonColor = accentPurple; // Color para slots seleccionados
          textColor = primaryDarkPurple;
          fontWeight = FontWeight.bold;
        }

        return ElevatedButton(
          onPressed: isOccupied ? null : () => onSlotSelected(index),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            textStyle: TextStyle(fontSize: 10, fontWeight: fontWeight), // Reducido para más texto
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: isSelected ? 1.5 : 0,
              ),
            ),
            elevation: isOccupied ? 0 : 2,
          ),
          child: Text(
            eventText,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Para nombres de curso largos
            maxLines: 2, // Permitir dos líneas para el nombre del curso
          ),
        );
      },
    );
  }
}
