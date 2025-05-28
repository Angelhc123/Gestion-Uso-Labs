import 'package:controlusolab/models/lab_request_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';

class RequestListItemWidget extends StatelessWidget {
  final LabRequestModel request;
  final Function(LabRequestModel request, String newStatus) onProcessRequest;

  const RequestListItemWidget({
    super.key,
    required this.request,
    required this.onProcessRequest,
  });

  @override
  Widget build(BuildContext context) {
    final entryTime = DateFormat.Hm('es_ES').format(request.entryTime.toDate().toLocal());
    final exitTime = DateFormat.Hm('es_ES').format(request.exitTime.toDate().toLocal());
    final createdAtTime = DateFormat.yMd('es_ES').add_jm().format(request.createdAt!.toDate().toLocal());


    return Card(
      color: secondaryDark.withOpacity(0.85),
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.laboratoryName} - ${request.courseOrTheme}',
              style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text('Solicitante: ${request.userName ?? request.userId}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            Text('Docente: ${request.professorName ?? "No especificado"}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            Text('Ciclo: ${request.cycle}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Fecha Solicitada: ${DateFormat.yMd('es_ES').format(request.requestDate.toDate().toLocal())}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            Text('Horario: $entryTime - $exitTime', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            const SizedBox(height: 4),
             if (request.justification != null && request.justification!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top:4.0),
                child: Text('Justificación: ${request.justification}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13, fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 4),
            Text('Solicitud creada el: $createdAtTime', style: TextStyle(color: textOnDarkSecondary.withOpacity(0.7), fontSize: 11)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.close_rounded, color: errorColor),
                  label: const Text('Rechazar', style: TextStyle(color: errorColor)),
                  onPressed: () => onProcessRequest(request, 'rejected'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_rounded, color: primaryDarkPurple),
                  label: const Text('Aprobar', style: TextStyle(color: primaryDarkPurple)),
                  onPressed: () => onProcessRequest(request, 'approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
