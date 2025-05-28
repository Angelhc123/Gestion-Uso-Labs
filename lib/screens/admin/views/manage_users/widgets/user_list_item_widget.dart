import 'package:controlusolab/models/user_model.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class UserListItemWidget extends StatelessWidget {
  final UserModel user;
  final Function(String userId, bool newIsActiveStatus) onToggleStatus;

  const UserListItemWidget({
    super.key,
    required this.user,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    bool isCurrentlyActive = user.isActive;

    return Card(
      color: secondaryDark.withOpacity(0.8),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          isCurrentlyActive ? Icons.person_outline : Icons.person_off_outlined,
          color: isCurrentlyActive ? accentPurple : textOnDarkSecondary.withOpacity(0.7),
        ),
        title: Text(
          user.displayName ?? user.email ?? 'Usuario sin nombre',
          style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Email: ${user.email ?? "No disponible"}\nRol: ${user.role}\nEstado: ${isCurrentlyActive ? "Habilitado" : "Deshabilitado"}',
          style: const TextStyle(color: textOnDarkSecondary, fontSize: 12),
        ),
        trailing: ElevatedButton(
          onPressed: () => onToggleStatus(user.uid, !isCurrentlyActive),
          style: ElevatedButton.styleFrom(
            backgroundColor: isCurrentlyActive
                ? errorColor.withOpacity(0.7)
                : successColor.withOpacity(0.7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(
            isCurrentlyActive ? 'Deshabilitar' : 'Habilitar',
            style: const TextStyle(color: textOnDark, fontSize: 12),
          ),
        ),
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
    );
  }
}
