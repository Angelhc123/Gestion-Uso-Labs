import 'package:controlusolab/models/lab_request_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';
import './request_status_chip.dart';

class UserRequestListItemWidget extends StatelessWidget {
  final LabRequestModel request;

  const UserRequestListItemWidget({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final requestedDate = DateFormat.yMd('es_ES').format(request.requestDate.toDate().toLocal());
    final entryTime = DateFormat.Hm('es_ES').format(request.entryTime.toDate().toLocal());
    final exitTime = DateFormat.Hm('es_ES').format(request.exitTime.toDate().toLocal());
    final creationDate = DateFormat.yMd('es_ES').add_Hm().format(request.createdAt!.toDate().toLocal());

    return Card(
      color: secondaryDark.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${request.laboratoryName} - ${request.courseOrTheme}',
                    style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                RequestStatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Fecha Solicitada: $requestedDate', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            Text('Horario: $entryTime - $exitTime', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            Text('Ciclo: ${request.cycle}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            Text('Profesor: ${request.professorName ?? "N/A"}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Text('Enviada el: $creationDate', style: TextStyle(color: textOnDarkSecondary.withOpacity(0.7), fontSize: 11)),
            if (request.status.toLowerCase() == 'rechazado' && request.supportComment != null && request.supportComment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  'Motivo del Rechazo: ${request.supportComment}',
                  style: TextStyle(color: errorColor.withOpacity(0.9), fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
