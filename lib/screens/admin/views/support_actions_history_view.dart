import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:controlusolab/utils/app_colors.dart';

class SupportActionsHistoryView extends StatefulWidget {
  const SupportActionsHistoryView({super.key});

  @override
  State<SupportActionsHistoryView> createState() => _SupportActionsHistoryViewState();
}

class _SupportActionsHistoryViewState extends State<SupportActionsHistoryView> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LabRequestModel>>(
      stream: _firestoreService.getProcessedLabRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: accentPurple));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar historial: ${snapshot.error}', style: const TextStyle(color: errorColor)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay acciones de soporte registradas.', style: TextStyle(color: textOnDarkSecondary)));
        }
        final processedRequests = snapshot.data!;
        // Ordenar por fecha de procesamiento descendente (más reciente primero)
        processedRequests.sort((a, b) {
          final aTimestamp = a.processedTimestamp;
          final bTimestamp = b.processedTimestamp;
          if (aTimestamp == null && bTimestamp == null) return 0;
          if (aTimestamp == null) return 1; // nulls al final
          if (bTimestamp == null) return -1; // nulls al final
          return bTimestamp.compareTo(aTimestamp); // Descendente
        });

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: processedRequests.length,
          itemBuilder: (context, index) {
            final request = processedRequests[index];
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
          },
        );
      },
    );
  }
}
