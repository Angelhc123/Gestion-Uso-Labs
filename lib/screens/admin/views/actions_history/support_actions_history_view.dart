import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // No es necesario aquí si el widget lo maneja

import '../../../../utils/app_colors.dart';
import './widgets/history_list_item_widget.dart';

// Paleta de colores SE ELIMINA

class SupportActionsHistoryView extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  SupportActionsHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LabRequestModel>>(
      stream: _firestoreService.getProcessedLabRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: accentPurple)); // O adminAccentPurple
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error al cargar historial: ${snapshot.error}', style: const TextStyle(color: errorColor)));
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
            return HistoryListItemWidget(request: request); // Usar el nuevo widget
          },
        );
      },
    );
  }
}
