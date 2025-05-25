import 'package:controlusolab/services/auth_service.dart';
import 'package:flutter/material.dart';

// Importar las vistas y ReportsScreen usando rutas relativas correctas
import 'views/manage_support_users_view.dart';
import 'views/support_actions_history_view.dart';
import 'reports/reports_screen.dart';

// Paleta de colores
const Color primaryDarkPurple = Color(0xFF381E72);
const Color secondaryDark = Color(0xFF242424);
const Color accentPurple = Color(0xFF9B59B6);
const Color textOnDark = Color(0xFFFFFFFF);

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
      backgroundColor: secondaryDark,
      appBar: AppBar(
        title: const Text('Panel de Administrador', style: TextStyle(color: textOnDark, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDarkPurple,
        iconTheme: const IconThemeData(color: accentPurple),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: accentPurple),
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
          indicatorColor: accentPurple,
          labelColor: accentPurple,
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
          SupportActionsHistoryView(), // Si es StatefulWidget y no tiene constructor const, está bien
          const ReportsScreen(), // Añadir const si ReportsScreen es StatelessWidget
        ],
      ),
    );
  }
}