import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/services/auth_service.dart';
import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importar las vistas de usuario
import 'views/home_view.dart';
import 'views/request_lab_view.dart';
import 'views/lab_schedule_view.dart';
import 'views/coming_soon_view.dart';

// Paleta de colores (puede moverse a un archivo de tema/constantes global)
const Color primaryDarkPurple = Color(0xFF381E72);
const Color secondaryDark = Color(0xFF1C1B1F);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);

enum UserScreenView { home, solicitarAula, verSolicitudes, perfil, verHorario }

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  UserScreenView _currentView = UserScreenView.home;

  List<LaboratoryModel> _laboratories = [];
  bool _isLoadingLaboratories = true;
  List<CourseModel> _courses = [];
  bool _isLoadingCourses = true;
  
  // Para pasar el laboratorio seleccionado en el formulario de solicitud
  // a la vista de horario si el usuario navega allí.
  LaboratoryModel? _labSelectedInFormForSchedule;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _loadSharedData();
  }

  Future<void> _loadSharedData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLaboratories = true;
      _isLoadingCourses = true;
    });
    await _loadLaboratories();
    await _loadCourses();
    if (!mounted) return;
    // Una vez cargados los datos, podemos quitar el indicador de carga general
    // si isLoadingLaboratories y isLoadingCourses se manejan individualmente en las vistas.
    // O mantener un estado de carga general para UserScreen hasta que todo esté listo.
    // Por ahora, las vistas individuales pueden mostrar su propio CircularProgressIndicator
    // si sus datos específicos aún se están cargando (aunque aquí se cargan centralmente).
  }

  Future<void> _loadCourses() async {
    try {
      final coursesData = await _firestoreService.getCourses().first;
      if (!mounted) return;
      setState(() {
        _courses = coursesData;
        _isLoadingCourses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingCourses = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar cursos: $e', style: const TextStyle(color: textOnDark)), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _loadLaboratories() async {
    try {
      final labs = await _firestoreService.getLaboratories().first;
      if (!mounted) return;
      setState(() {
        _laboratories = labs;
        _isLoadingLaboratories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingLaboratories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar laboratorios: $e', style: const TextStyle(color: textOnDark)), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: secondaryDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: primaryDarkPurple,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.person_pin_circle, size: 48, color: accentPurple),
                const SizedBox(height: 8),
                const Text(
                  'Menú Usuario',
                  style: TextStyle(color: textOnDark, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _authService.currentUser?.email ?? 'Usuario',
                  style: const TextStyle(color: textOnDarkSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
          _buildDrawerItem(context, icon: Icons.home_outlined, text: 'Inicio', view: UserScreenView.home),
          _buildDrawerItem(context, icon: Icons.add_to_queue_outlined, text: 'Solicitar Aula', view: UserScreenView.solicitarAula),
          _buildDrawerItem(context, icon: Icons.calendar_today_outlined, text: 'Ver Horario', view: UserScreenView.verHorario),
          _buildDrawerItem(context, icon: Icons.list_alt_outlined, text: 'Mis Solicitudes', view: UserScreenView.verSolicitudes, boolComingSoon: true),
          _buildDrawerItem(context, icon: Icons.person_outline, text: 'Mi Perfil', view: UserScreenView.perfil, boolComingSoon: true),
          Divider(color: primaryDarkPurple.withOpacity(0.5)),
          ListTile(
            leading: const Icon(Icons.logout, color: accentPurple),
            title: const Text('Cerrar Sesión', style: TextStyle(color: textOnDark, fontSize: 16)),
            onTap: () async {
              Navigator.pop(context); // Cierra el Drawer primero
              await _authService.signOut();
              // No es necesario navegar explícitamente a /login aquí.
              // AuthWrapper se encargará de la redirección.
              // if (!mounted) return; // Esta verificación ya no es tan crítica aquí
              // Navigator.pushReplacementNamed(context, '/login'); // ELIMINAR ESTA LÍNEA
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String text, required UserScreenView view, bool boolComingSoon = false}) {
    bool isSelected = _currentView == view;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? accentPurple.withOpacity(0.2) : Colors.transparent,
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)), // Estilo visual para el item seleccionado
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? accentPurple : textOnDarkSecondary),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? accentPurple : textOnDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        trailing: boolComingSoon ? const Text("Pronto", style: TextStyle(color: Colors.amberAccent, fontSize: 10)) : null,
        onTap: () {
          Navigator.pop(context); // Cierra el Drawer
          if (mounted) {
            setState(() {
              _currentView = view;
            });
          }
        },
      ),
    );
  }

  String _getViewTitle() {
    switch (_currentView) {
      case UserScreenView.home:
        return 'Inicio';
      case UserScreenView.solicitarAula:
        return 'Solicitar Aula de Laboratorio';
      case UserScreenView.verHorario:
        return 'Ver Horario de Laboratorio';
      case UserScreenView.verSolicitudes:
        return 'Mis Solicitudes';
      case UserScreenView.perfil:
        return 'Mi Perfil';
      default:
        return 'Control de Laboratorios';
    }
  }

  Widget _buildCurrentView() {
    // Si los datos compartidos aún se están cargando, muestra un indicador general.
    // Las vistas individuales también pueden tener sus propios indicadores si cargan datos adicionales.
    if (_isLoadingLaboratories || _isLoadingCourses) {
      return const Center(child: CircularProgressIndicator(color: accentPurple));
    }

    switch (_currentView) {
      case UserScreenView.home:
        return const HomeView();
      case UserScreenView.solicitarAula:
        return RequestLabView(
          laboratories: _laboratories,
          isLoadingLaboratories: _isLoadingLaboratories, // Aunque cargado aquí, la vista podría usarlo
          courses: _courses,
          isLoadingCourses: _isLoadingCourses, // Igual que arriba
          onLaboratorySelected: (lab) {
            // Cuando un laboratorio es seleccionado en el formulario de RequestLabView,
            // actualizamos _labSelectedInFormForSchedule para que LabScheduleView
            // pueda usarlo si el usuario navega allí.
            if (mounted) {
              setState(() {
                _labSelectedInFormForSchedule = lab;
              });
            }
          },
          onRequestSubmitted: () {
            // Después de enviar una solicitud, volvemos a la vista de inicio.
            if (mounted) {
              setState(() {
                _currentView = UserScreenView.home;
                 // Opcional: Limpiar _labSelectedInFormForSchedule si ya no es relevante
                _labSelectedInFormForSchedule = null;
              });
            }
          },
        );
      case UserScreenView.verHorario:
        return LabScheduleView(
          laboratories: _laboratories,
          isLoadingLaboratories: _isLoadingLaboratories,
          initiallySelectedLab: _labSelectedInFormForSchedule, // Pasa el lab seleccionado en el form (si existe)
        );
      case UserScreenView.verSolicitudes:
        return ComingSoonView(title: _getViewTitle());
      case UserScreenView.perfil:
        return ComingSoonView(title: _getViewTitle());
      default:
        return const HomeView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryDark,
      appBar: AppBar(
        title: Text(_getViewTitle(), style: const TextStyle(color: textOnDark, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDarkPurple,
        elevation: 2,
        iconTheme: const IconThemeData(color: accentPurple),
      ),
      drawer: _buildDrawer(context),
      body: _buildCurrentView(),
    );
  }
}