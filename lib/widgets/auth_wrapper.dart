import 'package:controlusolab/screens/admin/admin_screen.dart';
import 'package:controlusolab/screens/auth/login_screen.dart';
import 'package:controlusolab/screens/support/support_screen.dart';
import 'package:controlusolab/screens/user/user_screen.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          if (kDebugMode) print("AuthWrapper: authStateChanges waiting...");
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          if (kDebugMode) print("AuthWrapper: No Firebase user (authStateChanges emitted null). Showing LoginScreen.");
          return const LoginScreen();
        }

        // Usuario autenticado, ahora obtener y escuchar el rol del usuario
        if (kDebugMode) print("AuthWrapper: Firebase user ${firebaseUser.uid} detected via authStateChanges. Fetching role via userRoleStream...");
        return StreamBuilder<String?>(
          // Importante: userRoleStream se basa en authStateChanges internamente.
          // Cuando authStateChanges emite un nuevo usuario, userRoleStream debería reactivarse.
          stream: authService.userRoleStream, 
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              if (kDebugMode) print("AuthWrapper: User ${firebaseUser.uid} authenticated. Waiting for role from userRoleStream...");
              return const Scaffold(body: Center(child: CircularProgressIndicator(backgroundColor: Colors.orangeAccent,))); 
            }

            if (roleSnapshot.hasError) {
                if (kDebugMode) print("AuthWrapper: Error in userRoleStream for ${firebaseUser.uid}: ${roleSnapshot.error}. Defaulting to UserScreen.");
                // Podrías mostrar un mensaje de error específico o intentar recargar.
                return const UserScreen(); // Fallback
            }

            if (!roleSnapshot.hasData || roleSnapshot.data == null) {
              if (kDebugMode) print("AuthWrapper: User ${firebaseUser.uid} authenticated, but role is null or no data from userRoleStream. Defaulting to UserScreen for safety.");
              return const UserScreen(); 
            }

            final role = roleSnapshot.data!; 
            if (kDebugMode) print("AuthWrapper: User ${firebaseUser.uid} - Role from userRoleStream: '$role'. Navigating...");

            final normalizedRole = role.toLowerCase();

            if (normalizedRole == 'admin') {
              if (kDebugMode) print("AuthWrapper: Navigating to AdminScreen.");
              return const AdminScreen();
            } else if (normalizedRole == 'support') {
              if (kDebugMode) print("AuthWrapper: Navigating to SupportScreen."); // Log específico
              return const SupportScreen();
            } else if (normalizedRole == 'user') {
              if (kDebugMode) print("AuthWrapper: Navigating to UserScreen.");
              return const UserScreen();
            } else {
              if (kDebugMode) print("AuthWrapper: Unknown role '$role' for user ${firebaseUser.uid}. Defaulting to UserScreen.");
              return const UserScreen();
            }
          },
        );
      },
    );
  }
}
