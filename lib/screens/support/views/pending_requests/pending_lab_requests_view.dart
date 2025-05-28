import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/app_colors.dart';
import './widgets/request_list_item_widget.dart';

class PendingLabRequestsView extends StatefulWidget {
  const PendingLabRequestsView({super.key});

  @override
  State<PendingLabRequestsView> createState() => _PendingLabRequestsViewState();
}

class _PendingLabRequestsViewState extends State<PendingLabRequestsView> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
  }

  Future<void> _processRequest(LabRequestModel request, String newStatus) async {
    String? supportComment;
    final commentController = TextEditingController();

    bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: secondaryDark,
          title: Text('Procesar Solicitud (${newStatus == 'approved' ? 'Aprobar' : 'Rechazar'})', style: const TextStyle(color: accentPurple)),
          content: TextField(
            controller: commentController,
            style: const TextStyle(color: textOnDark),
            decoration: InputDecoration(
              hintText: "Comentario (obligatorio para rechazar)",
              hintStyle: TextStyle(color: textOnDarkSecondary.withOpacity(0.7)),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentPurple.withOpacity(0.5))),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accentPurple)),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: accentPurple)),
            ),
            TextButton(
              onPressed: () {
                if (newStatus == 'rejected' && commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El comentario es obligatorio al rechazar.', style: TextStyle(color: textOnDark)), backgroundColor: warningColor),
                  );
                  return;
                }
                supportComment = commentController.text.trim();
                Navigator.pop(context, true);
              },
              child: const Text('Confirmar', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (_currentUser?.uid != null) {
        try {
          await _firestoreService.updateLabRequestStatus(
            request.id,
            newStatus.toUpperCase(), // Asegurar que el estado se guarde en mayúsculas
            supportComment ?? "", 
            _currentUser!.uid,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar( 
              SnackBar(content: Text('Solicitud ${newStatus == 'approved' ? 'aprobada' : 'rechazada'} con éxito.', style: const TextStyle(color: textOnDark)), backgroundColor: successColor),
            );
          }
        } catch (e) { 
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar( 
              SnackBar(content: Text('Error al procesar la solicitud: $e', style: const TextStyle(color: textOnDark)), backgroundColor: errorColor),
            );
          }
        }
      } else { 
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Usuario de soporte no identificado.', style: TextStyle(color: textOnDark)), backgroundColor: errorColor), 
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<DateTime, List<LabRequestModel>>>(
      stream: _firestoreService.getGroupedAndSortedPendingLabRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: accentPurple));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: errorColor)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay solicitudes pendientes.', style: TextStyle(color: textOnDarkSecondary)));
        }

        final groupedRequests = snapshot.data!;
        final sortedDates = groupedRequests.keys.toList()..sort((a, b) => a.compareTo(b));

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final requestsForDay = groupedRequests[date]!;
            
            return Card(
              color: primaryDarkPurple.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ExpansionTile(
                collapsedIconColor: accentPurple,
                iconColor: accentPurple,
                title: Text(
                  'Solicitudes para ${DateFormat.yMMMEd('es_ES').format(date)} (${requestsForDay.length})',
                  style: const TextStyle(color: accentPurple, fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: index == 0, 
                children: requestsForDay.map((request) {
                  return RequestListItemWidget( 
                    request: request,
                    onProcessRequest: _processRequest, 
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
