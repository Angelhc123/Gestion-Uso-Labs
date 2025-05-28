import 'package:controlusolab/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'views/manage_users/manage_support_users_view.dart';
import 'views/support_actions_history_view.dart'; // La que está directamente en views

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDarkPurple,
      appBar: AppBar(
        title: const Text('Panel de Administrador', style: TextStyle(color: textOnDark)),
        backgroundColor: primaryDarkPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: accentPurple),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentPurple,
          labelColor: accentPurple,
          unselectedLabelColor: textOnDarkSecondary.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.manage_accounts_outlined), text: 'Gestionar Soporte'),
            Tab(icon: Icon(Icons.history_outlined), text: 'Historial Acciones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ManageSupportUsersView(), 
          SupportActionsHistoryView(), 
        ],
      ),
    );
  }
}