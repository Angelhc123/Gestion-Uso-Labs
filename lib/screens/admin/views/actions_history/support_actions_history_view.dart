import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:controlusolab/utils/app_colors.dart';
import './widgets/history_list_item_widget.dart'; // Usando el widget de esta carpeta

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
        final historyItems = snapshot.data!;
        historyItems.sort((a, b) {
          final aTimestamp = a.processedTimestamp;
          final bTimestamp = b.processedTimestamp;
          if (aTimestamp == null && bTimestamp == null) return 0;
          if (aTimestamp == null) return 1;
          if (bTimestamp == null) return -1;
          return bTimestamp.compareTo(aTimestamp); 
        });

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: historyItems.length,
          itemBuilder: (context, index) {
            final request = historyItems[index];
            return HistoryListItemWidget(request: request); // Usando el widget
          },
        );
      },
    );
  }
}
