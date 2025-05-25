import 'package:controlusolab/models/lab_request_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';

class HistoryListItemWidget extends StatelessWidget {
  final LabRequestModel request;

  const HistoryListItemWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final actionDate = request.actionTimestamp != null 
                       ? DateFormat.yMd('es_ES').add_jm().format(request.actionTimestamp!.toLocal()) 
                       : 'N/A';
    final requestDate = DateFormat.yMd('es_ES').add_jm().format(request.requestTime.toLocal());

    return Card(
      color: secondaryDark.withOpacity(0.85), // O adminSecondaryDark
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          request.status == 'approved' ? Icons.check_circle_outline : Icons.highlight_off_outlined,
          // Corregido: Usar colores base con shades específicos
          color: request.status == 'approved' ? Colors.green.shade400 : Colors.red.shade400,
          size: 30,
        ),
        title: Text('${request.laboratory} - ${request.courseOrTheme}', style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Acción: ${request.status == 'approved' ? 'Aprobada' : 'Rechazada'}\n'
          'Solicitud: $requestDate\n'
          'Acción: $actionDate\n'
          'Por (ID): ${request.processedBySupportUserId ?? 'N/A'}\n'
          'Comentario: ${request.supportComment?.isNotEmpty == true ? request.supportComment : 'Sin comentario'}',
          style: const TextStyle(color: textOnDarkSecondary, fontSize: 13),
        ),
        isThreeLine: false, 
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }
}
