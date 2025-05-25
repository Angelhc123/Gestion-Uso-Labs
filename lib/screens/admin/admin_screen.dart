import 'package:controlusolab/services/auth_service.dart';
import 'package:flutter/material.dart';

// Importar las vistas desde sus nuevas ubicaciones
import 'views/manage_users/manage_support_users_view.dart';
import 'views/actions_history/support_actions_history_view.dart';
import 'views/reports/reports_screen.dart'; // Actualizar ruta
import '../../utils/app_colors.dart'; // Importar colores globales

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminViewSecondaryDark, // Usar color específico de admin o secondaryDark
      appBar: AppBar(
        title: const Text('Panel de Administrador', style: TextStyle(color: textOnDark, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDarkPurple, // O un color primario específico de admin
        iconTheme: const IconThemeData(color: adminViewAccentPurple), // O accentPurple
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: adminViewAccentPurple), // O accentPurple
            tooltip: "Cerrar Sesión",
            onPressed: () async {
              await _authService.signOut();
              // ignore: use_build_context_synchronously
              if (!context.mounted) return; // Check mounted before navigating
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: adminViewAccentPurple, // O accentPurple
          labelColor: adminViewAccentPurple, // O accentPurple
          unselectedLabelColor: textOnDark.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.people_alt_outlined), text: 'Usuarios Soporte'),
            Tab(icon: Icon(Icons.history_edu_outlined), text: 'Historial Acciones'),
            Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Reportes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const ManageSupportUsersView(),
          SupportActionsHistoryView(), 
          const ReportsScreen(),
        ],
      ),
    );
  }
}