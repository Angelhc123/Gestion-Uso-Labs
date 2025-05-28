import 'package:flutter/material.dart';
import 'package:controlusolab/utils/app_colors.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, size: 100, color: accentPurple),
            const SizedBox(height: 20),
            Text(
              'Perfil de Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textOnDark),
            ),
            const SizedBox(height: 20),
            if (user != null) ...[
              Text(
                'Nombre: ${user.displayName ?? "No disponible"}',
                style: const TextStyle(fontSize: 18, color: textOnDarkSecondary),
              ),
              const SizedBox(height: 10),
              Text(
                'Email: ${user.email ?? "No disponible"}',
                style: const TextStyle(fontSize: 18, color: textOnDarkSecondary),
              ),
              const SizedBox(height: 10),
              Text(
                'UID: ${user.uid}',
                style: const TextStyle(fontSize: 14, color: textOnDarkSecondary),
              ),
            ] else
              const Text(
                'No se pudo cargar la información del usuario.',
                style: TextStyle(fontSize: 18, color: errorColor),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: accentPurple),
              icon: const Icon(Icons.edit_outlined, color: primaryDarkPurple),
              label: const Text('Editar Perfil (Próximamente)', style: TextStyle(color: primaryDarkPurple)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad de editar perfil no implementada aún.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
