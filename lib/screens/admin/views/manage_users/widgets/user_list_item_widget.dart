import 'package:controlusolab/models/user_model.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class UserListItemWidget extends StatelessWidget {
  final UserModel user;
  final Function(String, bool) onToggleStatus;

  const UserListItemWidget({
    super.key,
    required this.user,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: secondaryDark.withOpacity(0.8), // O adminSecondaryDark
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(user.isDisabled ? Icons.person_off_outlined : Icons.person_outline, color: accentPurple), // O adminAccentPurple
        title: Text(user.email, style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold)),
        subtitle: Text('UID: ${user.uid}\nEstado: ${user.isDisabled ? "Deshabilitado" : "Habilitado"}', style: const TextStyle(color: textOnDarkSecondary)),
        trailing: ElevatedButton(
          onPressed: () => onToggleStatus(user.uid, user.isDisabled),
          style: ElevatedButton.styleFrom(backgroundColor: user.isDisabled ? successColor.withOpacity(0.7) : errorColor.withOpacity(0.7)),
          child: Text(user.isDisabled ? 'Habilitar' : 'Deshabilitar', style: const TextStyle(color: textOnDark)),
        ),
        isThreeLine: true,
      ),
    );
  }
}
