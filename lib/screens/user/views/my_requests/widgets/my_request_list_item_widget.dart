import 'package:controlusolab/models/lab_request_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart'; // Ajusta la ruta si es necesario

class MyRequestListItemWidget extends StatelessWidget {
  final LabRequestModel request;

  const MyRequestListItemWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat.yMd('es_ES');
    final DateFormat timeFormat = DateFormat.Hm('es_ES');

    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (request.status.toLowerCase()) {
      case 'aprobado':
      case 'approved':
        statusText = 'Aprobada';
        statusColor = successColor;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rechazado':
      case 'rejected':
        statusText = 'Rechazada';
        statusColor = errorColor;
        statusIcon = Icons.highlight_off_outlined;
        break;
      case 'pendiente':
      default:
        statusText = 'Pendiente';
        statusColor = warningColor; // Asegúrate de tener warningColor en app_colors.dart
        statusIcon = Icons.hourglass_empty_outlined;
        break;
    }

    return Card(
      color: secondaryDark.withOpacity(0.85),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 30),
        title: Text(
          '${request.laboratoryName} - ${request.courseOrTheme}',
          style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha Solicitada: ${dateFormat.format(request.requestDate.toDate().toLocal())}',
              style: const TextStyle(color: textOnDarkSecondary, fontSize: 13),
            ),
            Text(
              'Horario: ${timeFormat.format(request.entryTime.toDate().toLocal())} - ${timeFormat.format(request.exitTime.toDate().toLocal())}',
              style: const TextStyle(color: textOnDarkSecondary, fontSize: 13),
            ),
            Text(
              'Estado: $statusText',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            if (request.justification != null && request.justification!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  'Tu Justificación: ${request.justification}',
                  style: TextStyle(color: textOnDarkSecondary.withOpacity(0.9), fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            if (request.supportComment != null && request.supportComment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  'Comentario de Soporte: ${request.supportComment}',
                  style: TextStyle(color: textOnDarkSecondary.withOpacity(0.9), fontSize: 12),
                ),
              ),
            if (request.processedTimestamp != null)
              Text(
                'Procesada el: ${DateFormat.yMd('es_ES').add_jm().format(request.processedTimestamp!.toDate().toLocal())}',
                style: const TextStyle(color: textOnDarkSecondary, fontSize: 11),
              ),
          ],
        ),
        isThreeLine: true, // Puede necesitar ser true si hay muchos detalles
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }
}
