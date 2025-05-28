import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/app_colors.dart';
import './widgets/user_request_list_item_widget.dart';

class MyRequestsView extends StatefulWidget {
  const MyRequestsView({super.key});

  @override
  State<MyRequestsView> createState() => _MyRequestsViewState();
}

class _MyRequestsViewState extends State<MyRequestsView> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedStatusFilter = 'TODOS'; // Opciones: TODOS, PENDIENTE, APROBADO, RECHAZADO

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("Usuario no autenticado.", style: TextStyle(color: textOnDarkSecondary)));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: DropdownButtonFormField<String>(
            value: _selectedStatusFilter,
            decoration: InputDecoration(
              labelText: 'Filtrar por Estado',
              labelStyle: const TextStyle(color: accentPurple),
              filled: true,
              fillColor: primaryDarkPurple.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
            dropdownColor: secondaryDark,
            iconEnabledColor: accentPurple,
            style: const TextStyle(color: textOnDark),
            items: ['TODOS', 'PENDIENTE', 'APROBADO', 'RECHAZADO']
                .map((label) => DropdownMenuItem(
                      value: label,
                      child: Text(label, style: const TextStyle(color: textOnDark)),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatusFilter = value;
                });
              }
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<LabRequestModel>>(
            stream: _firestoreService.getLabRequestsByUserId(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: accentPurple));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: errorColor)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No tienes solicitudes registradas.', style: TextStyle(color: textOnDarkSecondary)));
              }

              List<LabRequestModel> allRequests = snapshot.data!;
              List<LabRequestModel> filteredRequests;

              if (_selectedStatusFilter == 'TODOS') {
                filteredRequests = allRequests;
              } else {
                filteredRequests = allRequests.where((req) {
                  // Normalizar el estado del filtro y de la solicitud para comparación insensible a mayúsculas
                  String filterStatusNormalized = _selectedStatusFilter.toLowerCase();
                  String requestStatusNormalized = req.status.toLowerCase();
                  
                  // Manejar casos especiales como 'approved' vs 'aprobado'
                  if (filterStatusNormalized == 'aprobado') filterStatusNormalized = 'approved';
                  if (requestStatusNormalized == 'aprobado') requestStatusNormalized = 'approved';
                  if (filterStatusNormalized == 'rechazado') filterStatusNormalized = 'rejected';
                  if (requestStatusNormalized == 'rechazado') requestStatusNormalized = 'rejected';
                  if (filterStatusNormalized == 'pendiente') filterStatusNormalized = 'pending';
                  if (requestStatusNormalized == 'pendiente') requestStatusNormalized = 'pending';

                  return requestStatusNormalized == filterStatusNormalized;
                }).toList();
              }
              
              if (filteredRequests.isEmpty) {
                return Center(child: Text('No hay solicitudes con el estado "$_selectedStatusFilter".', style: const TextStyle(color: textOnDarkSecondary)));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  return UserRequestListItemWidget(request: request);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
