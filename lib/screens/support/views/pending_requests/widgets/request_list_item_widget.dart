import 'package:controlusolab/models/lab_request_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors.dart';

class RequestListItemWidget extends StatelessWidget {
  final LabRequestModel request;
  final Function(LabRequestModel, String) onProcessRequest;

  const RequestListItemWidget({
    super.key,
    required this.request,
    required this.onProcessRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: secondaryDark.withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      child: ListTile(
        title: Text('${request.laboratory} - ${request.courseOrTheme}', style: const TextStyle(color: textOnDark, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuario ID: ${request.userId}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 12)), 
            Text('Ciclo: ${request.cycle}', style: const TextStyle(color: textOnDarkSecondary)),
            Text('Horario: ${DateFormat.Hm('es_ES').format(request.entryTime.toLocal())} - ${DateFormat.Hm('es_ES').format(request.exitTime.toLocal())}', style: const TextStyle(color: textOnDarkSecondary)),
            Text('Solicitado: ${DateFormat.yMd('es_ES').add_Hm().format(request.requestTime.toLocal())}', style: const TextStyle(color: textOnDarkSecondary, fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: successColor),
              onPressed: () => onProcessRequest(request, 'approved'),
              tooltip: 'Aprobar',
            ),
            IconButton(
              icon: const Icon(Icons.highlight_off_outlined, color: errorColor),
              onPressed: () => onProcessRequest(request, 'rejected'),
              tooltip: 'Rechazar',
            ),
          ],
        ),
      ),
    );
  }
}
