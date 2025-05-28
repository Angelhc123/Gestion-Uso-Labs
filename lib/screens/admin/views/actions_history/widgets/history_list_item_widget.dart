import 'package:controlusolab/models/lab_request_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';

class HistoryListItemWidget extends StatelessWidget {
  final LabRequestModel request;

  const HistoryListItemWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final actionDate = request.processedTimestamp != null
                       ? DateFormat.yMd('es_ES').add_jm().format(request.processedTimestamp!.toDate().toLocal())
                       : 'N/A';
    final requestCreationDate = request.createdAt != null
                                ? DateFormat.yMd('es_ES').add_jm().format(request.createdAt!.toDate().toLocal())
                                : 'N/A';
    final requestedDateForLab = DateFormat.yMd('es_ES').format(request.requestDate.toDate().toLocal());
    final bool isApproved = request.status.toLowerCase() == 'approved' || request.status.toLowerCase() == 'aprobado';

    return Card(
      color: secondaryDark.withOpacity(0.85),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      child: ListTile(
        leading: Icon(
          isApproved ? Icons.check_circle_outline : Icons.highlight_off_outlined,
          color: isApproved ? successColor : errorColor,
          size: 30,
        ),
        title: Text('${request.laboratoryName} - ${request.courseOrTheme}', style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Solicitante: ${request.userName ?? request.userId}\n'
          'Fecha Solicitada: $requestedDateForLab (${DateFormat.Hm('es_ES').format(request.entryTime.toDate().toLocal())} - ${DateFormat.Hm('es_ES').format(request.exitTime.toDate().toLocal())})\n'
          'Creación Solicitud: $requestCreationDate\n'
          'Acción: ${isApproved ? 'Aprobada' : 'Rechazada'} el $actionDate\n'
          'Por (Soporte ID): ${request.processedBySupportUserId ?? 'N/A'}\n'
          'Justificación Usuario: ${request.justification?.isNotEmpty == true ? request.justification : 'No proporcionada'}\n'
          'Comentario Soporte: ${request.supportComment?.isNotEmpty == true ? request.supportComment : 'Sin comentario'}',
          style: const TextStyle(color: textOnDarkSecondary, fontSize: 13),
        ),
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }
}
