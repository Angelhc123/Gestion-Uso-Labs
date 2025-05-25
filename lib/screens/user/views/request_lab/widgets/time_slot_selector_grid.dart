import 'package:flutter/material.dart';
import '../utils/schedule_definitions.dart';
import '../../../../../utils/app_colors.dart'; // Importar colores globales

class TimeSlotSelectorGrid extends StatelessWidget {
  final Set<int> selectedIndices;
  final List<TimeRange> occupiedTimeRanges;
  final Function(int) onSlotSelected;
  final bool isLoading;

  const TimeSlotSelectorGrid({
    super.key,
    required this.selectedIndices,
    required this.occupiedTimeRanges,
    required this.onSlotSelected,
    this.isLoading = false,
  });

  bool _isSlotOccupied(PedagogicalTimeSlot slot) {
    if (slot.isRecess) return true;
    for (var occupiedRange in occupiedTimeRanges) {
      if (occupiedRange.overlapsWith(slot)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // El CircularProgressIndicator se muestra en request_lab_view.dart
      // cuando _isLoadingSchedule es true. Aquí, si isLoading es true,
      // podríamos mostrar un loader más pequeño o simplemente un contenedor vacío
      // si el loader principal ya está visible.
      // Por coherencia, si este widget se llama con isLoading = true,
      // mostramos su propio loader.
      return const Center(child: CircularProgressIndicator(color: accentPurple));
    }

    if (kPedagogicalTimeSlotsList.isEmpty) {
      return const Center(child: Text("No hay bloques horarios definidos.", style: TextStyle(color: textOnDarkSecondary)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Seleccione el/los bloque(s) horario(s): (Máx. 2 contiguos)",
            style: TextStyle(color: textOnDark, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        SizedBox(
          height: 85, // Altura para la lista horizontal de slots. Ajusta según el contenido.
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: kPedagogicalTimeSlotsList.length,
            itemBuilder: (context, index) {
              final slot = kPedagogicalTimeSlotsList[index];
              final bool isOccupied = _isSlotOccupied(slot);
              final bool isSelected = selectedIndices.contains(index);

              Color tileColor = secondaryDark.withOpacity(0.8);
              Color textColor = textOnDarkSecondary;
              FontWeight fontWeight = FontWeight.normal;

              if (isOccupied) {
                tileColor = slot.isRecess ? Colors.blueGrey.shade700 : errorColor.withOpacity(0.7);
                textColor = slot.isRecess ? Colors.blueGrey.shade300 : Colors.red.shade200;
              } else if (isSelected) {
                tileColor = accentPurple.withOpacity(0.8);
                textColor = primaryDarkPurple;
                fontWeight = FontWeight.bold;
              }

              return GestureDetector(
                onTap: isOccupied ? null : () => onSlotSelected(index),
                child: Container(
                  width: 80, // Ancho de cada item en la lista horizontal. Ajusta según el contenido.
                  margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? accentPurple : primaryDarkPurple.withOpacity(0.5))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        slot.displayTimeStart,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontSize: 10, fontWeight: fontWeight),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        slot.displayTimeEnd,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textColor, fontSize: 10, fontWeight: fontWeight),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isOccupied && !slot.isRecess)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text("Ocupado", style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 8)),
                        ),
                      if (slot.isRecess)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text("Receso", style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 8)),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
