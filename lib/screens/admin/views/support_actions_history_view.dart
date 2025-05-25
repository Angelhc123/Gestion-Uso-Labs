import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Paleta de colores
const Color secondaryDark = Color(0xFF1C1B1F);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);

class SupportActionsHistoryView extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  SupportActionsHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LabRequestModel>>(
      stream: _firestoreService.getProcessedLabRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: accentPurple));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar historial: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay acciones de soporte registradas.', style: TextStyle(color: textOnDarkSecondary)));
        }
        final processedRequests = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: processedRequests.length,
          itemBuilder: (context, index) {
            final request = processedRequests[index];
            final actionDate = request.actionTimestamp != null 
                               ? DateFormat.yMd('es_ES').add_jm().format(request.actionTimestamp!.toLocal()) 
                               : 'N/A';
            final requestDate = DateFormat.yMd('es_ES').add_jm().format(request.requestTime.toLocal());

            return Card(
              color: secondaryDark.withOpacity(0.85),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              elevation: 2,
              child: ListTile(
                leading: Icon(
                  request.status == 'approved' ? Icons.check_circle_outline : Icons.highlight_off_outlined,
                  color: request.status == 'approved' ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
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
                isThreeLine: false, // ListTile ajustará la altura automáticamente
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            );
          },
        );
      },
    );
  }
}
