import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importar las vistas de soporte

import 'views/pending_requests/pending_lab_requests_view.dart';
// import 'views/processed_requests/processed_requests_view.dart'; // Si tienes una vista para el historial de soporte

enum SupportScreenView {
  home, // Opcional, si se quiere mantener accesible
  pendingRequests,
  // processedRequests, // Si se implementa
  profile, // Placeholder
}

// Placeholder para ComingSoonView si no existe en este contexto
class ComingSoonView extends StatelessWidget {
  final String title;
  const ComingSoonView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: accentPurple.withOpacity(0.7)),
          const SizedBox(height: 20),
          Text(
            '$title\n(Próximamente)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: textOnDarkSecondary.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  SupportScreenView _currentView = SupportScreenView.pendingRequests; // VISTA INICIAL CAMBIADA

  String _getViewTitle() {
    switch (_currentView) {
      case SupportScreenView.home:
        return 'Panel de Soporte';
      case SupportScreenView.pendingRequests:
        return 'Solicitudes Pendientes';
      // case SupportScreenView.processedRequests:
      //   return 'Historial de Solicitudes';
      case SupportScreenView.profile:
        return 'Mi Perfil (Soporte)';
      default:
        return 'Panel de Soporte';
    }
  }

  Widget _buildDrawerListTile(SupportScreenView view, String title, IconData icon) {
    bool isSelected = _currentView == view;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? accentPurple.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? accentPurple : textOnDarkSecondary),
        title: Text(title, style: TextStyle(color: isSelected ? accentPurple : textOnDark, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        onTap: () {
          if (mounted) {
            setState(() {
              _currentView = view;
            });
          }
          Navigator.pop(context); // Cerrar el drawer
        },
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case SupportScreenView.pendingRequests:
        return const PendingLabRequestsView();
      // case SupportScreenView.processedRequests:
      //   return const ProcessedRequestsView(); // Si la implementas
      case SupportScreenView.profile:
        return ComingSoonView(title: _getViewTitle());
      default:
        return const PendingLabRequestsView(); // Vista por defecto
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getViewTitle()),
        backgroundColor: primaryDarkPurple, // O el color que uses para el AppBar de Soporte
      ),
      drawer: Drawer(
        backgroundColor: secondaryDark,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryDarkPurple.withOpacity(0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.support_agent_outlined, size: 50, color: accentPurple),
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUser?.displayName ?? authService.currentUser?.email ?? 'Soporte',
                    style: const TextStyle(color: textOnDark, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    authService.currentUser?.email ?? 'No disponible',
                    style: const TextStyle(color: textOnDarkSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Opcional: Si quieres mantener el acceso a la vista Home de Soporte
                  // _buildDrawerListTile(SupportScreenView.home, 'Inicio Soporte', Icons.home_outlined),
                  _buildDrawerListTile(SupportScreenView.pendingRequests, 'Solicitudes Pendientes', Icons.pending_actions_outlined),
                  // _buildDrawerListTile(SupportScreenView.processedRequests, 'Historial de Solicitudes', Icons.history_outlined),
                  const Divider(color: accentPurple),
                  _buildDrawerListTile(SupportScreenView.profile, 'Mi Perfil', Icons.person_outline),
                  ListTile(
                    leading: const Icon(Icons.logout, color: textOnDarkSecondary),
                    title: const Text('Cerrar Sesión', style: TextStyle(color: textOnDark)),
                    onTap: () async {
                      Navigator.pop(context); // Cerrar drawer primero
                      await authService.signOut();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _buildCurrentView(),
      backgroundColor: secondaryDark,
    );
  }
}