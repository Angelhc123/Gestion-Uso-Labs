import 'package:controlusolab/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Paleta de colores (asegúrate de que estas constantes estén disponibles o defínelas)
const Color primaryDarkPurple = Color(0xFF381E72);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("SupportScreen: Build method called.");
    }
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Soporte', style: TextStyle(color: textOnDark)),
        backgroundColor: primaryDarkPurple,
        iconTheme: const IconThemeData(color: accentPurple),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              if (kDebugMode) {
                print("SupportScreen: Logout button pressed.");
              }
              await authService.signOut();
              // AuthWrapper se encargará de la navegación a LoginScreen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.support_agent, size: 80, color: accentPurple),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido, Soporte!',
              style: TextStyle(fontSize: 24, color: textOnDark),
            ),
            const SizedBox(height: 10),
            Text(
              'Usuario: ${authService.currentUser?.email ?? "No disponible"}',
              style: const TextStyle(fontSize: 16, color: textOnDark),
            ),
          ],
        ),
      ),
    );
  }
}