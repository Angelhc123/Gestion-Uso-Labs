import 'package:controlusolab/models/user_model.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';

import '../../../../utils/app_colors.dart';
import './utils/admin_input_decoration.dart';
import './widgets/user_list_item_widget.dart';

class ManageSupportUsersView extends StatefulWidget {
  const ManageSupportUsersView({super.key});

  @override
  State<ManageSupportUsersView> createState() => _ManageSupportUsersViewState();
}

class _ManageSupportUsersViewState extends State<ManageSupportUsersView> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchIdController = TextEditingController();

  UserModel? _searchedUser;
  String? _feedbackMessage;
  String _filterStatus = 'todos'; // 'todos', 'habilitados', 'deshabilitados'

  InputDecoration _inputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentPurple.withOpacity(0.8)),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: accentPurple.withOpacity(0.7)) : null,
      filled: true,
      fillColor: primaryDarkPurple.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: accentPurple.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: accentPurple, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
      hintStyle: TextStyle(color: textOnDarkSecondary.withOpacity(0.7)),
    );
  }

  void _createSupportUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _feedbackMessage = null;
        _searchedUser = null; 
      });
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        final result = await _authService.createSupportUser(email, password);
        if (mounted) {
          if (result != null && !result.startsWith('Error')) {
            setState(() {
              _feedbackMessage = 'Usuario de soporte creado con UID: $result';
              _emailController.clear();
              _passwordController.clear();
            });
          } else {
            setState(() {
              _feedbackMessage = 'Error al crear usuario: ${result ?? "Error desconocido"}';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _feedbackMessage = 'Excepción al crear usuario: $e';
          });
        }
      }
    }
  }

  void _searchUserById() async {
    String uid = _searchIdController.text.trim();
    if (uid.isEmpty) {
      if (mounted) {
        setState(() {
          _feedbackMessage = 'Ingrese un UID para buscar.';
          _searchedUser = null;
        });
      }
      return;
    }
    if (mounted) {
      setState(() {
          _feedbackMessage = null;
          _searchedUser = null;
      });
    }
    try {
        final user = await _firestoreService.getSupportUserById(uid);
        if (mounted) {
          if (user != null) {
              setState(() {
                  _searchedUser = user;
                  _feedbackMessage = 'Usuario encontrado.';
              });
          } else {
              setState(() {
                  _feedbackMessage = 'Usuario de soporte no encontrado con ese UID.';
              });
          }
        }
    } catch (e) {
        if (mounted) {
          setState(() {
              _feedbackMessage = 'Error al buscar usuario: $e';
          });
        }
    }
  }

  Future<void> _toggleUserStatus(String uid, bool currentStatus) async {
    try {
      await _authService.setUserDisabledStatus(uid, !currentStatus);
      if (mounted) {
        setState(() {
          _feedbackMessage = 'Estado del usuario actualizado.';
          if (_searchedUser?.uid == uid) {
            _searchedUser!.isDisabled = !currentStatus;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _feedbackMessage = 'Error al cambiar estado: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crear Usuario de Soporte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textOnDark)),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: adminInputDecoration('Email de Soporte', prefixIcon: Icons.email_outlined),
                  style: const TextStyle(color: textOnDark),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese un email';
                    if (!value.contains('@') || !value.contains('.')) return 'Email no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: adminInputDecoration('Contraseña', prefixIcon: Icons.lock_outline),
                  obscureText: true,
                  style: const TextStyle(color: textOnDark),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese una contraseña';
                    if (value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add_alt_1, color: primaryDarkPurple),
                  label: const Text('Crear Usuario', style: TextStyle(color: primaryDarkPurple, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: accentPurple, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  onPressed: _createSupportUser,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text('Buscar y Gestionar Usuario por UID', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textOnDark)),
          const SizedBox(height: 10),
          Row(
              children: [
                  Expanded(
                      child: TextFormField(
                          controller: _searchIdController,
                          decoration: adminInputDecoration('UID del Usuario', prefixIcon: Icons.search),
                          style: const TextStyle(color: textOnDark),
                      ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(icon: const Icon(Icons.send_outlined, color: accentPurple), onPressed: _searchUserById, tooltip: 'Buscar')
              ],
          ),
          if (_searchedUser != null)
            Card(
              color: secondaryDark.withOpacity(0.8),
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                leading: Icon(_searchedUser!.isDisabled ? Icons.person_off_outlined : Icons.person_outline, color: accentPurple),
                title: Text(_searchedUser!.email, style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold)),
                subtitle: Text('UID: ${_searchedUser!.uid}\nRol: ${_searchedUser!.role}\nEstado: ${_searchedUser!.isDisabled ? "Deshabilitado" : "Habilitado"}', style: const TextStyle(color: textOnDarkSecondary)),
                trailing: ElevatedButton(
                  onPressed: () => _toggleUserStatus(_searchedUser!.uid, _searchedUser!.isDisabled),
                  style: ElevatedButton.styleFrom(backgroundColor: _searchedUser!.isDisabled ? successColor.withOpacity(0.7) : errorColor.withOpacity(0.7)),
                  child: Text(_searchedUser!.isDisabled ? 'Habilitar' : 'Deshabilitar', style: const TextStyle(color: textOnDark)),
                ),
                isThreeLine: true,
              ),
            ),
          const SizedBox(height: 10),
          if (_feedbackMessage != null) 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(_feedbackMessage!, 
                style: TextStyle(color: _feedbackMessage!.toLowerCase().contains('error') ? errorColor : successColor, fontWeight: FontWeight.bold)
              ),
            ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lista de Usuarios de Soporte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textOnDark)),
              DropdownButton<String>(
                value: _filterStatus,
                dropdownColor: secondaryDark,
                style: const TextStyle(color: textOnDarkSecondary),
                iconEnabledColor: accentPurple,
                items: const [
                  DropdownMenuItem(value: 'todos', child: Text('Todos')),
                  DropdownMenuItem(value: 'habilitados', child: Text('Habilitados')),
                  DropdownMenuItem(value: 'deshabilitados', child: Text('Deshabilitados')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null && mounted) {
                    setState(() {
                      _filterStatus = newValue;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<UserModel>>(
            stream: _firestoreService.getSupportUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: accentPurple));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar usuarios: ${snapshot.error}', style: const TextStyle(color: errorColor)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay usuarios de soporte.', style: TextStyle(color: textOnDarkSecondary)));
              }
              
              List<UserModel> supportUsers = snapshot.data!;
              if (_filterStatus == 'habilitados') {
                supportUsers = supportUsers.where((user) => !user.isDisabled).toList();
              } else if (_filterStatus == 'deshabilitados') {
                supportUsers = supportUsers.where((user) => user.isDisabled).toList();
              }

              if (supportUsers.isEmpty) {
                return Center(child: Text('No hay usuarios que coincidan con el filtro "$_filterStatus".', style: const TextStyle(color: textOnDarkSecondary)));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
        ],
      ),
    );
  }
}