import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'views/request_lab/request_lab_view.dart';
import 'views/lab_schedule/lab_schedule_view.dart';
import 'views/my_requests/my_requests_view.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  List<LaboratoryModel> _laboratories = [];
  bool _isLoadingLaboratories = true;
  List<CourseModel> _courses = [];
  bool _isLoadingCourses = true;
  LaboratoryModel? _selectedLabForScheduleView; 

  int _currentViewIndex = 0; 
  String _currentTitle = 'Solicitar Laboratorio';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _updateTitle();
  }

  void _updateTitle() {
    switch (_currentViewIndex) {
      case 0:
        _currentTitle = 'Solicitar Laboratorio';
        break;
      case 1:
        _currentTitle = 'Horarios de Laboratorios';
        break;
      case 2:
        _currentTitle = 'Mis Solicitudes';
        break;
      default:
        _currentTitle = 'Portal de Usuario';
    }
  }

  Future<void> _loadInitialData() async {
    await _loadLaboratories();
    await _loadCourses();
  }

  Future<void> _loadLaboratories() async {
    if (!mounted) return;
    setState(() => _isLoadingLaboratories = true);
    try {
      final labs = await _firestoreService.getLaboratories();
      if (mounted) {
        setState(() {
          _laboratories = labs;
          _isLoadingLaboratories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLaboratories = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar laboratorios: $e', style: const TextStyle(color: textOnDark)), backgroundColor: errorColor),
        );
      }
    }
  }
  
  Future<void> _loadCourses() async {
    if (!mounted) return;
    setState(() => _isLoadingCourses = true);
    try {
      final coursesData = await _firestoreService.getCourses();
      if (mounted) {
        setState(() {
          _courses = coursesData;
          _isLoadingCourses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCourses = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar cursos: $e', style: const TextStyle(color: textOnDark)), backgroundColor: errorColor),
        );
      }
    }
  }

  void _navigateToView(int index, {LaboratoryModel? labToPass}) { // Añadido labToPass opcional
    if (mounted) {
      setState(() {
        _currentViewIndex = index;
        _selectedLabForScheduleView = labToPass; // Guardar el lab si se pasa
        _updateTitle();
      });
      Navigator.pop(context); 
    }
  }
  
  // Esta función ya NO se pasará a RequestLabView para cambiar de vista.
  // RequestLabView manejará su propia lógica de carga de horarios.
  // void _handleLaboratorySelectedForScheduleView(LaboratoryModel? lab) {
  //   if (mounted) {
  //     setState(() {
  //       _selectedLabForScheduleView = lab;
  //       _currentViewIndex = 1; 
  //       _updateTitle();
  //     });
  //   }
  // }
  
  void _handleRequestSubmitted() {
     if (mounted) {
      setState(() {
        _currentViewIndex = 2; 
        _updateTitle();
      });
    }
  }

  Widget _buildCurrentView() {
    switch (_currentViewIndex) {
      case 0:
        return RequestLabView(
          laboratories: _laboratories,
          isLoadingLaboratories: _isLoadingLaboratories,
          courses: _courses,
          isLoadingCourses: _isLoadingCourses,
          // Ya no se pasa onLaboratorySelected para cambiar de vista.
          // RequestLabView se encarga de mostrar sus horarios.
          // onLaboratorySelected: _handleLaboratorySelectedForScheduleView, 
          onRequestSubmitted: _handleRequestSubmitted, 
        );
      case 1:
        return LabScheduleView(
          laboratories: _laboratories,
          isLoadingLaboratories: _isLoadingLaboratories,
          initiallySelectedLab: _selectedLabForScheduleView, 
        );
      case 2:
        return const MyRequestsView();
      default:
        return Container(); // No debería ocurrir
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    return Scaffold(
      backgroundColor: primaryDarkPurple,
      appBar: AppBar(
        title: Text(_currentTitle, style: const TextStyle(color: textOnDark)), // Título dinámico
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
        // Eliminada la TabBar de aquí
      ),
      drawer: Drawer(
        backgroundColor: secondaryDark,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                currentUser?.displayName ?? 'Usuario',
                style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                currentUser?.email ?? 'email@example.com',
                style: const TextStyle(color: textOnDarkSecondary),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: accentPurple,
                child: Text(
                  currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 40.0, color: primaryDarkPurple),
                ),
              ),
              decoration: const BoxDecoration(
                color: primaryDarkPurple,
              ),
            ),
            ListTile( 
              leading: const Icon(Icons.add_to_queue_outlined, color: accentPurple),
              title: const Text('Solicitar Laboratorio', style: TextStyle(color: textOnDark)),
              selected: _currentViewIndex == 0,
              selectedTileColor: primaryDarkPurple.withOpacity(0.5),
              onTap: () => _navigateToView(0),
            ),
            ListTile( 
              leading: const Icon(Icons.calendar_today_outlined, color: accentPurple),
              title: const Text('Horarios', style: TextStyle(color: textOnDark)),
              selected: _currentViewIndex == 1,
              selectedTileColor: primaryDarkPurple.withOpacity(0.5),
              onTap: () => _navigateToView(1), // Aquí se podría pasar un lab si fuera necesario
            ),
            ListTile( 
              leading: const Icon(Icons.list_alt_outlined, color: accentPurple),
              title: const Text('Mis Solicitudes', style: TextStyle(color: textOnDark)),
              selected: _currentViewIndex == 2,
              selectedTileColor: primaryDarkPurple.withOpacity(0.5),
              onTap: () => _navigateToView(2),
            ),
            const Divider(color: accentPurple),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: accentPurple),
              title: const Text('Configuración', style: TextStyle(color: textOnDark)),
              onTap: () {
                Navigator.pop(context);
                // Implementar navegación a Configuración si es necesario
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: accentPurple),
              title: const Text('Acerca de', style: TextStyle(color: textOnDark)),
              onTap: () {
                Navigator.pop(context);
                // Implementar diálogo "Acerca de"
              },
            ),
            const Divider(color: accentPurple),
            ListTile(
              leading: const Icon(Icons.logout, color: errorColor),
              title: const Text('Cerrar Sesión', style: TextStyle(color: textOnDark)),
              onTap: () async {
                Navigator.pop(context);
                await _authService.signOut();
              },
            ),
          ],
        ),
      ),
      body: _buildCurrentView(), // El cuerpo ahora muestra la vista actual
    );
  }
}