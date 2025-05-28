import 'package:cloud_firestore/cloud_firestore.dart'; // AÑADIDO para Timestamp
import 'package:controlusolab/models/user_model.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import './widgets/user_list_item_widget.dart';
import './widgets/add_support_user_dialog.dart'; // Necesitarás crear este diálogo

class ManageSupportUsersView extends StatefulWidget {
  const ManageSupportUsersView({super.key});

  @override
  State<ManageSupportUsersView> createState() => _ManageSupportUsersViewState();
}

class _ManageSupportUsersViewState extends State<ManageSupportUsersView> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService(); // Para crear usuarios

  void _showAddSupportUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddSupportUserDialog(authService: _authService);
      },
    ).then((_) {
      // Opcional: refrescar la lista o mostrar un mensaje si es necesario
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _toggleUserStatus(String userId, bool newIsActiveStatus) async {
    try {
      await _authService.setUserActiveStatus(userId, newIsActiveStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado del usuario actualizado con éxito.', style: const TextStyle(color: textOnDark)),
            backgroundColor: successColor,
          ),
        );
        // El StreamBuilder debería actualizar la UI automáticamente
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: ${e.toString()}', style: const TextStyle(color: textOnDark)),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Para que tome el color del TabBarView del AdminScreen
      body: StreamBuilder<List<UserModel>>(
        stream: _firestoreService.getUsersByRole('support'), // Obtener solo usuarios con rol 'support'
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accentPurple));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar usuarios de soporte: ${snapshot.error}', style: const TextStyle(color: errorColor)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay usuarios de soporte registrados.', style: TextStyle(color: textOnDarkSecondary)));
          }
          final supportUsers = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: supportUsers.length,
            itemBuilder: (context, index) {
              final user = supportUsers[index];
              return UserListItemWidget(
                user: user,
                onToggleStatus: _toggleUserStatus,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSupportUserDialog,
        label: const Text('Añadir Soporte', style: TextStyle(color: primaryDarkPurple)),
        icon: const Icon(Icons.add, color: primaryDarkPurple),
        backgroundColor: accentPurple,
        tooltip: 'Crear nuevo usuario de soporte',
      ),
    );
  }
}