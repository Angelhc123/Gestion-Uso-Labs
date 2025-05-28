import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/models/occupied_slot_model.dart';
import 'package:controlusolab/models/professor_model.dart';

// Paleta de colores (puedes ajustarla según tu app)
const Color primaryDarkPurple = Color(0xFF381E72);
const Color secondaryDark = Color(0xFF1C1B1F);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);

class TemporalDataUploadScreen extends StatefulWidget {
  const TemporalDataUploadScreen({super.key});

  @override
  State<TemporalDataUploadScreen> createState() => _TemporalDataUploadScreenState();
}

class _TemporalDataUploadScreenState extends State<TemporalDataUploadScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isUploading = false;
  String _uploadStatus = '';
  final List<String> _uploadLog = [];

  void _log(String message) {
    if (mounted) {
      setState(() {
        _uploadLog.add(message);
        _uploadStatus = message; 
      });
      // print(message); // Descomenta para ver logs en la consola de depuración
    }
  }

  Future<void> _uploadStructuredData() async {
    if (!mounted) return;
    setState(() {
      _isUploading = true;
      _uploadLog.clear();
    });
    _log('Iniciando carga de datos estructurados...');

    try {
      // 1. Definir y Cargar Cursos con Ciclo/Semestre
      _log('Procesando cursos...');
      final List<CourseModel> courses = [
        // I CICLO
        CourseModel(id: '', name: "Comunicación I", semester: 1),
        CourseModel(id: '', name: "Matemática Básica", semester: 1),
        CourseModel(id: '', name: "Estrategia para el Aprendizaje Autónomo", semester: 1),
        CourseModel(id: '', name: "Desarrollo Personal y Liderazgo", semester: 1),
        CourseModel(id: '', name: "Desarrollo Competencias Digitales", semester: 1),
        CourseModel(id: '', name: "Matemática I", semester: 1),
        CourseModel(id: '', name: "REFORZAMIENTO MATEMATICA I", semester: 1), // Actualizado
        
        // II CICLO
        CourseModel(id: '', name: "Comunicación II", semester: 2),
        CourseModel(id: '', name: "Territorio Peruano Defensa y seguridad Nacional", semester: 2),
        CourseModel(id: '', name: "Filosofia", semester: 2),
        CourseModel(id: '', name: "Técnicas de Programación", semester: 2),
        CourseModel(id: '', name: "Fisica I", semester: 2),
        CourseModel(id: '', name: "Matemática II", semester: 2),
        CourseModel(id: '', name: "REFORZAMIENTO FISICA I", semester: 2), // Actualizado

        // III CICLO
        CourseModel(id: '', name: "INE-321 ECONOMIA", semester: 3), // Asumiendo que es "Economía"
        CourseModel(id: '', name: "EG-322 ETICA", semester: 3), // Asumiendo que es "Ética"
        CourseModel(id: '', name: "INE-323 Estadistica y Prob", semester: 3), // Asumiendo que es "Estadística y Probabilidades"
        CourseModel(id: '', name: "Estructura de Datos", semester: 3),
        CourseModel(id: '', name: "Sistemas de Información", semester: 3),
        CourseModel(id: '', name: "Matemática Discreta", semester: 3),

        // IV CICLO
        CourseModel(id: '', name: "Modelamiento de Procesos", semester: 4),
        CourseModel(id: '', name: "Ingeniería econ. y Financiera", semester: 4), // Asumiendo "Ingeniería Económica y Financiera"
        CourseModel(id: '', name: "Interacción y Diseño de Interfaces", semester: 4),
        CourseModel(id: '', name: "Diseño en Ingenieria", semester: 4), // Asumiendo "Diseño en Ingeniería"
        CourseModel(id: '', name: "Sistemas Elect. Digitales", semester: 4), // Asumiendo "Sistemas Electrónicos Digitales"
        CourseModel(id: '', name: "Programación I", semester: 4),
        CourseModel(id: '', name: "REFORZAMIENTO PROGRAMACION COMPETITIVA", semester: 4), // Actualizado

        // V CICLO
        CourseModel(id: '', name: "Arquitectura de Computadoras", semester: 5),
        CourseModel(id: '', name: "Diseño de Base de Datos", semester: 5),
        CourseModel(id: '', name: "Diseño y Modelamiento Virtual", semester: 5),
        CourseModel(id: '', name: "Ingeniería de Requerimientos", semester: 5),
        CourseModel(id: '', name: "Ingeniería de Software", semester: 5),
        CourseModel(id: '', name: "Programación II", semester: 5),

        // VI CICLO
        CourseModel(id: '', name: "Ecologia y desarrollo sostenible", semester: 6), // Asumiendo "Ecología y Desarrollo Sostenible"
        CourseModel(id: '', name: "Sistemas Operativos I", semester: 6),
        CourseModel(id: '', name: "Base de Datos I", semester: 6),
        CourseModel(id: '', name: "Investigación de Operaciones", semester: 6),
        CourseModel(id: '', name: "Diseño y Arq de Software", semester: 6), // Asumiendo "Diseño y Arquitectura de Software"
        CourseModel(id: '', name: "Programación III", semester: 6),

        // VII CICLO
        CourseModel(id: '', name: "Problemas y Desafios del Peru", semester: 7), // Asumiendo "Problemas y Desafíos del Perú en un Mundo Global"
        CourseModel(id: '', name: "Sistemas Operativos II", semester: 7),
        CourseModel(id: '', name: "Base de Datos II", semester: 7),
        CourseModel(id: '', name: "Calidad y Pruebas de Software", semester: 7),
        CourseModel(id: '', name: "Gestión de Proyectos", semester: 7), // Asumiendo "Gestión de Proyectos de TI"
        CourseModel(id: '', name: "Programación Web I", semester: 7),
        
        // VIII CICLO
        CourseModel(id: '', name: "Inteligencia Artificial", semester: 8),
        CourseModel(id: '', name: "Redes y Comunic. de datos I", semester: 8), // Asumiendo "Redes y Comunicación de Datos I"
        CourseModel(id: '', name: "Soluciones Móviles I", semester: 8),
        CourseModel(id: '', name: "Estadistica Inferencial y Analisis de Datos", semester: 8), // Asumiendo "Estadística Inferencial y Análisis de Datos"
        CourseModel(id: '', name: "Inteligencia de Negocios", semester: 8),
        CourseModel(id: '', name: "Planeamiento Estrategico de TI", semester: 8), // Asumiendo "Planeamiento Estratégico de TI"
        CourseModel(id: '', name: "Patrones de Software", semester: 8), // Añadido por solicitud del usuario

        // IX CICLO
        CourseModel(id: '', name: "Taller de Tesis I", semester: 9),
        CourseModel(id: '', name: "Programación Web II", semester: 9),
        CourseModel(id: '', name: "Construcción de Software I", semester: 9),
        CourseModel(id: '', name: "Redes y Comunic. de datos II", semester: 9), // Asumiendo "Redes y Comunicación de Datos II"
        CourseModel(id: '', name: "Gestión de la Configuración y Adm. De SW", semester: 9), // Asumiendo "Gestión de la Configuración de Software"
        CourseModel(id: '', name: "Inglés Técnico", semester: 9),
        CourseModel(id: '', name: "Soluciones Moviles II", semester: 9), // Añadido por solicitud del usuario
        
        // X CICLO
        CourseModel(id: '', name: "Seguridad de TI", semester: 10), // Asumiendo "Seguridad de Tecnología de Información"
        CourseModel(id: '', name: "Construcción de Software II", semester: 10),
        CourseModel(id: '', name: "Auditoria de Sistemas", semester: 10), // Asumiendo "Auditoría de Sistemas"
        CourseModel(id: '', name: "Taller de liderazgo y emprendimiento", semester: 10), // Asumiendo "Taller de Emprendimiento y Liderazgo"
        CourseModel(id: '', name: "Gerencia de TI", semester: 10), // Asumiendo "Gerencia de Tecnologías de Información"
        CourseModel(id: '', name: "Taller de Tesis II / Trabajo de Investigación", semester: 10),
        CourseModel(id: '', name: "Infraestructura de TI", semester: 10), // Añadido por solicitud del usuario

        // Cursos sin ciclo definido en las imágenes (o de reforzamiento) - YA MOVIDOS
      ];
      int coursesAdded = 0;
      for (var course in courses) {
        bool exists = await _firestoreService.checkCourseExists(course.name);
        if (!exists) {
          await _firestoreService.addCourse(course);
          coursesAdded++;
        }
      }
      _log('$coursesAdded cursos nuevos añadidos.');

      // 2. Definir y Cargar Profesores
      _log('Procesando profesores...');
      final List<ProfessorModel> professors = [
        ProfessorModel(id: '', name: "A. Alca", department: ''),
        ProfessorModel(id: '', name: "A. Crisosto", department: ''),
        ProfessorModel(id: '', name: "A. Flor", department: ''),
        ProfessorModel(id: '', name: "A. Montero", department: ''),
        ProfessorModel(id: '', name: "Alex Yanqui", department: ''),
        ProfessorModel(id: '', name: "Carlos Nuñez", department: ''),
        ProfessorModel(id: '', name: "D. Huanca", department: ''),
        ProfessorModel(id: '', name: "D. Rubira", department: ''),
        ProfessorModel(id: '', name: "E. Lanchipa", department: ''),
        ProfessorModel(id: '', name: "E. Lopez", department: ''),
        ProfessorModel(id: '', name: "E. Valencia", department: ''),
        ProfessorModel(id: '', name: "E. Vilela", department: ''),
        ProfessorModel(id: '', name: "Elard Rodriguez", department: ''),
        ProfessorModel(id: '', name: "Elizabeth Merma", department: ''),
        ProfessorModel(id: '', name: "German Mamani", department: ''),
        ProfessorModel(id: '', name: "H. Sisa", department: ''),
        ProfessorModel(id: '', name: "ING. J. ROMAINA", department: ''),
        ProfessorModel(id: '', name: "Israel Chaparro", department: ''),
        ProfessorModel(id: '', name: "J. Alca", department: ''),
        ProfessorModel(id: '', name: "Juan Choque", department: ''),
        ProfessorModel(id: '', name: "J. Huayta", department: ''), // Añadido desde asd.txt
        ProfessorModel(id: '', name: "L. Fernandez", department: ''),
        ProfessorModel(id: '', name: "Liliana Vega", department: ''),
        ProfessorModel(id: '', name: "Luis Fernandez", department: ''),
        ProfessorModel(id: '', name: "Manuel Aguilar", department: ''),
        ProfessorModel(id: '', name: "Mariella Ibarra", department: ''),
        ProfessorModel(id: '', name: "Martha Paredes", department: ''),
        ProfessorModel(id: '', name: "Martin Alcantara", department: ''),
        ProfessorModel(id: '', name: "N. Castro", department: ''),
        ProfessorModel(id: '', name: "N.Quispe", department: ''),
        ProfessorModel(id: '', name: "Natividad", department: ''),
        ProfessorModel(id: '', name: "O. Arce", department: ''),
        ProfessorModel(id: '', name: "O. Flores", department: ''),
        ProfessorModel(id: '', name: "O. Jimenez", department: ''),
        ProfessorModel(id: '', name: "P. Cuadros", department: ''),
        ProfessorModel(id: '', name: "Renzo Taco", department: ''),
        ProfessorModel(id: '', name: "Ricardo Valcarcel", department: ''),
        ProfessorModel(id: '', name: "Roberto Montesinos", department: ''),
        ProfessorModel(id: '', name: "Silvia Centella", department: ''),
        ProfessorModel(id: '', name: "Teresa Lanchipa", department: ''),
        ProfessorModel(id: '', name: "Tito Ale", department: ''),
        ProfessorModel(id: '', name: "POR ASIGNAR", department: 'General'), // Asegurarse que POR ASIGNAR esté en la lista
      ];
      int professorsAdded = 0;
      for (var prof in professors) {
        bool exists = await _firestoreService.checkProfessorExists(prof.name);
        if (!exists) {
          await _firestoreService.addProfessor(prof);
          professorsAdded++;
        }
      }
      _log('$professorsAdded profesores nuevos añadidos.');

      // 3. Definir y Cargar Laboratorios/Salones
      _log('Procesando laboratorios/salones...');
      final List<LaboratoryModel> laboratories = [
        LaboratoryModel(id: '', name: "LABORATORIO A", capacity: 20, resources: ['Computadoras', 'Proyector']),
        LaboratoryModel(id: '', name: "LABORATORIO B", capacity: 20, resources: ['Computadoras', 'Proyector']),
        LaboratoryModel(id: '', name: "LABORATORIO C", capacity: 20, resources: ['Computadoras', 'Proyector']),
        LaboratoryModel(id: '', name: "LABORATORIO D", capacity: 20, resources: ['Computadoras', 'Proyector']),
        LaboratoryModel(id: '', name: "LABORATORIO E", capacity: 20, resources: ['Computadoras', 'Proyector']),
        LaboratoryModel(id: '', name: "LABORATORIO F", capacity: 20, resources: ['Computadoras', 'Proyector']),
        LaboratoryModel(id: '', name: "SALON P-301", capacity: 20, resources: ['Proyector', 'Pizarra']),
        LaboratoryModel(id: '', name: "SALON P-307", capacity: 20, resources: ['Proyector', 'Pizarra']),
        LaboratoryModel(id: '', name: "SALON Q-312", capacity: 20, resources: ['Proyector', 'Pizarra']),
      ];
      int labsAdded = 0;
      for (var lab in laboratories) {
        bool exists = await _firestoreService.checkLaboratoryExists(lab.name);
        if (!exists) {
          await _firestoreService.addLaboratory(lab);
          labsAdded++;
        }
      }
      _log('$labsAdded laboratorios/salones nuevos añadidos.');

      // 4. Definir y Cargar Horarios Ocupados
      _log('Procesando horarios fijos...');
      final List<OccupiedSlotModel> occupiedSlots = [
        // LABORATORIO A
        // Horarios actualizados para LABORATORIO A - LUNES
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "LUNES", startTime: "09:40", endTime: "11:20", courseName: "Programación I", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "LUNES", startTime: "11:20", endTime: "13:00", courseName: "Estructura de Datos", professorName: "H. Sisa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "LUNES", startTime: "15:50", endTime: "17:30", courseName: "Gestión de Proyectos", professorName: "Martha Paredes"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "LUNES", startTime: "17:30", endTime: "19:10", courseName: "Ingeniería de Software", professorName: "Martha Paredes"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "LUNES", startTime: "20:00", endTime: "21:40", courseName: "Construcción de Software I", professorName: "A. Flor"),
        // Fin de horarios actualizados para LABORATORIO A - LUNES
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MARTES", startTime: "08:00", endTime: "09:40", courseName: "Sistemas Elect. Digitales", professorName: "Alex Yanqui"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MARTES", startTime: "11:20", endTime: "13:00", courseName: "Diseño de Base de Datos", professorName: "H. Sisa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MARTES", startTime: "15:00", endTime: "16:40", courseName: "Estructura de Datos", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MARTES", startTime: "16:40", endTime: "18:20", courseName: "Soluciones Móviles I", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MARTES", startTime: "18:20", endTime: "21:40", courseName: "Inteligencia de Negocios", professorName: "P. Cuadros"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MIÉRCOLES", startTime: "08:00", endTime: "09:40", courseName: "Diseño y Modelamiento Virtual", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MIÉRCOLES", startTime: "09:40", endTime: "11:20", courseName: "Programación I", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MIÉRCOLES", startTime: "11:20", endTime: "13:00", courseName: "Estructura de Datos", professorName: "H. Sisa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MIÉRCOLES", startTime: "15:50", endTime: "18:20", courseName: "Taller de Tesis II / Trabajo de Investigación", professorName: "Luis Fernandez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MIÉRCOLES", startTime: "18:20", endTime: "20:00", courseName: "Soluciones Móviles I", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "MIÉRCOLES", startTime: "20:00", endTime: "21:40", courseName: "Construcción de Software I", professorName: "Ricardo Valcarcel"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "JUEVES", startTime: "09:40", endTime: "11:20", courseName: "Diseño de Base de Datos", professorName: "H. Sisa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "JUEVES", startTime: "11:20", endTime: "13:00", courseName: "Estructura de Datos", professorName: "H. Sisa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "JUEVES", startTime: "15:00", endTime: "16:40", courseName: "Estructura de Datos", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "JUEVES", startTime: "16:40", endTime: "18:20", courseName: "Ingeniería de Requerimientos", professorName: "Mariella Ibarra"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "JUEVES", startTime: "18:20", endTime: "20:00", courseName: "Gestión de la Configuración y Adm. De SW", professorName: "Ricardo Valcarcel"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "JUEVES", startTime: "20:00", endTime: "21:40", courseName: "Construcción de Software I", professorName: "A. Flor"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "VIERNES", startTime: "09:40", endTime: "11:20", courseName: "Programación I", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "VIERNES", startTime: "12:10", endTime: "13:00", courseName: "Diseño de Base de Datos", professorName: "H. Sisa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "VIERNES", startTime: "15:00", endTime: "16:40", courseName: "Estructura de Datos", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "VIERNES", startTime: "16:40", endTime: "18:20", courseName: "Soluciones Móviles I", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "SÁBADO", startTime: "08:00", endTime: "09:40", courseName: "Calidad y Pruebas de Software", professorName: "P. Cuadros"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "SÁBADO", startTime: "09:40", endTime: "11:20", courseName: "Inteligencia de Negocios", professorName: "P. Cuadros"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO A", dayOfWeek: "SÁBADO", startTime: "11:20", endTime: "13:00", courseName: "Patrones de Software", professorName: "P. Cuadros"),

        // LABORATORIO B
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "LUNES", startTime: "08:00", endTime: "09:40", courseName: "Sistemas Elect. Digitales", professorName: "Alex Yanqui"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "LUNES", startTime: "11:20", endTime: "13:00", courseName: "Modelamiento de Procesos", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "LUNES", startTime: "15:00", endTime: "16:40", courseName: "Taller de liderazgo y emprendimiento", professorName: "Liliana Vega"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "LUNES", startTime: "18:20", endTime: "20:00", courseName: "Redes y Comunic. de datos II", professorName: "Martin Alcantara"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "LUNES", startTime: "20:00", endTime: "21:40", courseName: "Redes y Comunic. de datos I", professorName: "Martin Alcantara"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MARTES", startTime: "08:00", endTime: "09:40", courseName: "Sistemas de Información", professorName: "Liliana Vega"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MARTES", startTime: "09:40", endTime: "11:20", courseName: "Arquitectura de Computadoras", professorName: "Alex Yanqui"), // Corregido "Coomputadoras"
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MARTES", startTime: "11:20", endTime: "13:00", courseName: "Modelamiento de Procesos", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MARTES", startTime: "13:50", endTime: "16:20", courseName: "Diseño en Ingenieria", professorName: "Elizabeth Merma"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MIÉRCOLES", startTime: "08:00", endTime: "09:40", courseName: "Sistemas de Información", professorName: "Liliana Vega"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MIÉRCOLES", startTime: "11:20", endTime: "13:00", courseName: "Arquitectura de Computadoras", professorName: "Alex Yanqui"), // Corregido "Coomputadoras"
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MIÉRCOLES", startTime: "15:00", endTime: "16:40", courseName: "Inteligencia Artificial", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MIÉRCOLES", startTime: "16:40", endTime: "18:20", courseName: "Planeamiento Estrategico de TI", professorName: "O. Jimenez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "MIÉRCOLES", startTime: "18:20", endTime: "20:00", courseName: "Infraestructura de TI", professorName: "Martin Alcantara"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "JUEVES", startTime: "09:40", endTime: "11:20", courseName: "Arquitectura de Computadoras", professorName: "Alex Yanqui"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "JUEVES", startTime: "11:20", endTime: "13:00", courseName: "Sistemas Elect. Digitales", professorName: "Alex Yanqui"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "JUEVES", startTime: "13:50", endTime: "16:20", courseName: "Diseño en Ingenieria", professorName: "Elizabeth Merma"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "JUEVES", startTime: "18:20", endTime: "20:00", courseName: "Patrones de Software", professorName: "P. Cuadros"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "JUEVES", startTime: "20:00", endTime: "21:40", courseName: "Redes y Comunic. de datos I", professorName: "Martin Alcantara"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "VIERNES", startTime: "08:00", endTime: "09:40", courseName: "Modelamiento de Procesos", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "VIERNES", startTime: "11:20", endTime: "13:00", courseName: "Sistemas Elect. Digitales", professorName: "Alex Yanqui"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "VIERNES", startTime: "16:40", endTime: "18:20", courseName: "Auditoria de Sistemas", professorName: "O. Jimenez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "VIERNES", startTime: "20:00", endTime: "21:40", courseName: "Redes y Comunic. de datos II", professorName: "Martin Alcantara"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO B", dayOfWeek: "SÁBADO", startTime: "09:40", endTime: "11:20", courseName: "Infraestructura de TI", professorName: "Martin Alcantara"),

        // LABORATORIO C
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "LUNES", startTime: "09:40", endTime: "11:20", courseName: "Programación II", professorName: "E. Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "LUNES", startTime: "11:20", endTime: "13:00", courseName: "Arquitectura de Computadoras", professorName: "Alex Yanqui"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "LUNES", startTime: "15:00", endTime: "16:40", courseName: "Inteligencia Artificial", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "LUNES", startTime: "16:40", endTime: "18:20", courseName: "Programación Web II", professorName: "E. Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "LUNES", startTime: "18:20", endTime: "20:00", courseName: "Base de Datos II", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "MARTES", startTime: "09:40", endTime: "11:20", courseName: "Interacción y Diseño de Interfaces", professorName: "Tito Ale"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "MARTES", startTime: "18:20", endTime: "20:00", courseName: "Seguridad de TI", professorName: "Renzo Taco"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "MARTES", startTime: "20:00", endTime: "21:40", courseName: "Construcción de Software II", professorName: "Ricardo Valcarcel"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "MIÉRCOLES", startTime: "09:40", endTime: "11:20", courseName: "Programación II", professorName: "E. Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "MIÉRCOLES", startTime: "16:40", endTime: "20:00", courseName: "Programación Web II", professorName: "E. Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "JUEVES", startTime: "08:00", endTime: "09:40", courseName: "Interacción y Diseño de Interfaces", professorName: "Tito Ale"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "JUEVES", startTime: "18:20", endTime: "20:00", courseName: "Seguridad de TI", professorName: "Renzo Taco"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "JUEVES", startTime: "20:00", endTime: "21:40", courseName: "Construcción de Software II", professorName: "Ricardo Valcarcel"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "VIERNES", startTime: "08:00", endTime: "09:40", courseName: "Arquitectura de Computadoras", professorName: "Alex Yanqui"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "VIERNES", startTime: "09:40", endTime: "11:20", courseName: "Programación II", professorName: "E. Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "VIERNES", startTime: "15:50", endTime: "18:20", courseName: "Taller de Tesis I", professorName: "Luis Fernandez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "VIERNES", startTime: "18:20", endTime: "20:00", courseName: "Base de Datos II", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "VIERNES", startTime: "20:00", endTime: "21:40", courseName: "Gerencia de TI", professorName: "Ricardo Valcarcel"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "SÁBADO", startTime: "08:00", endTime: "09:40", courseName: "Construcción de Software II", professorName: "Ricardo Valcarcel"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO C", dayOfWeek: "SÁBADO", startTime: "09:40", endTime: "13:00", courseName: "Construcción de Software I", professorName: "Ricardo Valcarcel"),

        // LABORATORIO D
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "LUNES", startTime: "09:40", endTime: "11:20", courseName: "Programación II", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "LUNES", startTime: "16:40", endTime: "18:20", courseName: "Estadistica Inferencial y Analisis de Datos", professorName: "L. Fernandez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "LUNES", startTime: "18:20", endTime: "20:00", courseName: "Sistemas Operativos I", professorName: "Renzo Taco"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "LUNES", startTime: "20:00", endTime: "21:40", courseName: "Investigación de Operaciones", professorName: "Silvia Centella"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "MARTES", startTime: "10:30", endTime: "13:00", courseName: "Técnicas de Programación", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "MARTES", startTime: "15:00", endTime: "16:40", courseName: "Programación III", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "MARTES", startTime: "16:40", endTime: "18:20", courseName: "Ingeniería de Requerimientos", professorName: "Mariella Ibarra"), // "Ingenieria" vs "Ingeniería"
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "MARTES", startTime: "18:20", endTime: "20:00", courseName: "Gestión de la Configuración y Adm. De SW", professorName: "Ricardo Valcarcel"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "MARTES", startTime: "20:00", endTime: "21:40", courseName: "Construcción de Software I", professorName: "A. Flor"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "MIÉRCOLES", startTime: "08:00", endTime: "09:40", courseName: "Sistemas Elect. Digitales", professorName: "Alex Yanqui"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "MIÉRCOLES", startTime: "15:00", endTime: "16:40", courseName: "Soluciones Moviles II", professorName: "O. Jimenez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "JUEVES", startTime: "15:00", endTime: "16:40", courseName: "Programación III", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "JUEVES", startTime: "16:40", endTime: "18:20", courseName: "Base de Datos I", professorName: "E. Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "JUEVES", startTime: "20:00", endTime: "21:40", courseName: "Sistemas Operativos I", professorName: "Renzo Taco"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "VIERNES", startTime: "15:00", endTime: "16:40", courseName: "Programación III", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "VIERNES", startTime: "16:40", endTime: "18:20", courseName: "Base de Datos I", professorName: "E. Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "VIERNES", startTime: "18:20", endTime: "20:00", courseName: "Sistemas Operativos I", professorName: "Renzo Taco"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO D", dayOfWeek: "VIERNES", startTime: "20:00", endTime: "21:40", courseName: "Diseño y Arq de Software", professorName: "A. Flor"),
        
        // LABORATORIO E
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "LUNES", startTime: "08:00", endTime: "09:40", courseName: "Diseño de Base de Datos", professorName: "E. Valencia"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "LUNES", startTime: "11:20", endTime: "13:00", courseName: "Modelamiento de Procesos", professorName: "Natividad"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "LUNES", startTime: "15:50", endTime: "17:30", courseName: "Ingeniería de Requerimientos", professorName: ""), // Profesor vacío
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "LUNES", startTime: "20:00", endTime: "21:40", courseName: "Sistemas Operativos II", professorName: "Renzo Taco"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "MARTES", startTime: "11:20", endTime: "13:00", courseName: "Modelamiento de Procesos", professorName: "Natividad"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "MARTES", startTime: "16:40", endTime: "18:20", courseName: "Programación Web I", professorName: "Tito Ale"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "MARTES", startTime: "18:20", endTime: "20:00", courseName: "Base de Datos I", professorName: "E. Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "MARTES", startTime: "20:00", endTime: "21:40", courseName: "Sistemas Operativos II", professorName: "Renzo Taco"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "MIÉRCOLES", startTime: "08:00", endTime: "09:40", courseName: "Diseño de Base de Datos", professorName: "E. Valencia"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "MIÉRCOLES", startTime: "09:40", endTime: "11:20", courseName: "Programación II", professorName: "N.Quispe"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "MIÉRCOLES", startTime: "15:50", endTime: "17:30", courseName: "Gestión de Proyectos", professorName: "Martha Paredes"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "JUEVES", startTime: "08:00", endTime: "09:40", courseName: "Diseño y Modelamiento Virtual", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "JUEVES", startTime: "15:00", endTime: "16:40", courseName: "Auditoria de Sistemas", professorName: "O. Jimenez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "JUEVES", startTime: "16:40", endTime: "18:20", courseName: "Gestión de Proyectos", professorName: "Martha Paredes"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "JUEVES", startTime: "18:20", endTime: "20:00", courseName: "Programación Web I", professorName: "Tito Ale"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "JUEVES", startTime: "20:00", endTime: "21:40", courseName: "Calidad y Pruebas de Software", professorName: "P. Cuadros"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "VIERNES", startTime: "08:00", endTime: "09:40", courseName: "Modelamiento de Procesos", professorName: "Natividad"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "VIERNES", startTime: "09:40", endTime: "11:20", courseName: "Programación II", professorName: "N.Quispe"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "VIERNES", startTime: "15:00", endTime: "16:40", courseName: "Diseño de Base de Datos", professorName: "E. Valencia"), // Profesor añadido (antes vacío)
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "VIERNES", startTime: "16:40", endTime: "18:20", courseName: "Programación Web I", professorName: "Tito Ale"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "VIERNES", startTime: "18:20", endTime: "20:00", courseName: "Soluciones Moviles II", professorName: "O. Jimenez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "VIERNES", startTime: "20:00", endTime: "21:40", courseName: "Sistemas Operativos II", professorName: "Renzo Taco"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO E", dayOfWeek: "SÁBADO", startTime: "09:00", endTime: "11:30", courseName: "REFORZAMIENTO PROGRAMACION COMPETITIVA", professorName: "Israel Chaparro"),

        // LABORATORIO F
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "LUNES", startTime: "08:00", endTime: "09:40", courseName: "INE-323 Estadistica y Prob", professorName: "ING. J. ROMAINA"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "LUNES", startTime: "15:50", endTime: "17:30", courseName: "Programación I", professorName: "E. Valencia"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "LUNES", startTime: "17:30", endTime: "19:10", courseName: "Ingeniería de Software", professorName: "Liliana Vega"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "MARTES", startTime: "08:00", endTime: "09:40", courseName: "Diseño y Modelamiento Virtual", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "MARTES", startTime: "16:40", endTime: "18:20", courseName: "Ingeniería de Requerimientos", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "MARTES", startTime: "18:20", endTime: "20:00", courseName: "Base de Datos II", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "MIÉRCOLES", startTime: "09:40", endTime: "11:20", courseName: "Programación I", professorName: "Israel Chaparro"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "MIÉRCOLES", startTime: "18:20", endTime: "20:00", courseName: "Diseño y Arq de Software", professorName: "A. Flor"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "JUEVES", startTime: "09:40", endTime: "11:20", courseName: "Ingeniería econ. y Financiera", professorName: "Liliana Vega"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "JUEVES", startTime: "16:40", endTime: "18:20", courseName: "Ingeniería de Requerimientos", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "VIERNES", startTime: "11:20", endTime: "13:00", courseName: "INE-323 Estadistica y Prob", professorName: "ING. J. ROMAINA"),
        OccupiedSlotModel(id: '', laboratoryId: "LABORATORIO F", dayOfWeek: "VIERNES", startTime: "16:40", endTime: "18:20", courseName: "Programación I", professorName: "E. Valencia"),

        // SALON P-301
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "LUNES", startTime: "08:00", endTime: "10:30", courseName: "Matemática Básica", professorName: "O. Arce"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "LUNES", startTime: "10:30", endTime: "12:10", courseName: "Desarrollo Competencias Digitales", professorName: "J. Alca"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "LUNES", startTime: "13:00", endTime: "15:50", courseName: "Ecologia y desarrollo sostenible", professorName: "Teresa Lanchipa"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "MARTES", startTime: "08:00", endTime: "10:30", courseName: "Matemática I", professorName: "German Mamani"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "MARTES", startTime: "10:30", endTime: "13:00", courseName: "Estrategia para el Aprendizaje Autónomo", professorName: "E. Vilela"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "MARTES", startTime: "15:00", endTime: "16:40", courseName: "Inglés Técnico", professorName: "N. Castro"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "MIÉRCOLES", startTime: "08:00", endTime: "10:30", courseName: "Matemática Básica", professorName: "O. Arce"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "MIÉRCOLES", startTime: "10:30", endTime: "12:10", courseName: "Comunicación I", professorName: "A. Alca"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "MIÉRCOLES", startTime: "14:00", endTime: "16:30", courseName: "REFORZAMIENTO FISICA I", professorName: "Manuel Aguilar"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "MIÉRCOLES", startTime: "17:30", endTime: "19:10", courseName: "Ingeniería de Software", professorName: "Martha Paredes"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "JUEVES", startTime: "08:00", endTime: "10:30", courseName: "Matemática I", professorName: "German Mamani"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "JUEVES", startTime: "10:30", endTime: "13:00", courseName: "Desarrollo Personal y Liderazgo", professorName: "D. Huanca"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "JUEVES", startTime: "15:00", endTime: "16:40", courseName: "Inglés Técnico", professorName: "N. Castro"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "JUEVES", startTime: "16:40", endTime: "18:20", courseName: "Planeamiento Estrategico de TI", professorName: "O. Jimenez"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "JUEVES", startTime: "18:20", endTime: "20:00", courseName: "Diseño y Arq de Software", professorName: "A. Flor"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "VIERNES", startTime: "08:50", endTime: "10:30", courseName: "Desarrollo Competencias Digitales", professorName: "J. Alca"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "VIERNES", startTime: "10:30", endTime: "12:10", courseName: "Comunicación I", professorName: "A. Alca"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-301", dayOfWeek: "VIERNES", startTime: "18:20", endTime: "20:00", courseName: "Estadistica Inferencial y Analisis de Datos", professorName: "L. Fernandez"),

        // SALON P-307
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "LUNES", startTime: "08:50", endTime: "10:30", courseName: "Comunicación II", professorName: "E. Lopez"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "LUNES", startTime: "10:30", endTime: "13:00", courseName: "Fisica I", professorName: "J. Huayta"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "LUNES", startTime: "20:00", endTime: "21:40", courseName: "Gerencia de TI", professorName: "Ricardo Valcarcel"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "MARTES", startTime: "08:00", endTime: "10:30", courseName: "Territorio Peruano Defensa y seguridad Nacional", professorName: "E. Lopez"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "MARTES", startTime: "10:30", endTime: "13:00", courseName: "Técnicas de Programación", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "MARTES", startTime: "13:50", endTime: "16:20", courseName: "Diseño en Ingenieria", professorName: "Elizabeth Merma"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "MIÉRCOLES", startTime: "08:00", endTime: "10:30", courseName: "Técnicas de Programación", professorName: "Juan Choque"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "MIÉRCOLES", startTime: "10:30", endTime: "13:00", courseName: "Fisica I", professorName: "J. Huayta"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "MIÉRCOLES", startTime: "13:50", endTime: "16:20", courseName: "Problemas y Desafios del Peru", professorName: "Carlos Nuñez"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "MIÉRCOLES", startTime: "17:30", endTime: "19:10", courseName: "Ingeniería de Software", professorName: "Liliana Vega"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "MIÉRCOLES", startTime: "20:00", endTime: "21:40", courseName: "Investigación de Operaciones", professorName: "Silvia Centella"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "JUEVES", startTime: "08:00", endTime: "10:30", courseName: "Matemática II", professorName: "O. Flores"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "JUEVES", startTime: "10:30", endTime: "12:10", courseName: "Comunicación II", professorName: "E. Lopez"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "VIERNES", startTime: "08:00", endTime: "10:30", courseName: "Filosofia", professorName: "A. Montero"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "VIERNES", startTime: "10:30", endTime: "13:00", courseName: "Matemática II", professorName: "O. Flores"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "VIERNES", startTime: "15:50", endTime: "18:20", courseName: "REFORZAMIENTO MATEMATICA I", professorName: "Roberto Montesinos"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON P-307", dayOfWeek: "SÁBADO", startTime: "09:00", endTime: "11:30", courseName: "REFORZAMIENTO PROGRAMACION COMPETITIVA", professorName: ""), // PROGRAMACION COMPETITIVA - [Profesor no especificado]

        // SALON Q-312
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "LUNES", startTime: "08:00", endTime: "09:40", courseName: "Matemática Discreta", professorName: "Silvia Centella"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "LUNES", startTime: "09:40", endTime: "11:20", courseName: "Matemática Discreta", professorName: "Silvia Centella"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "LUNES", startTime: "11:20", endTime: "13:00", courseName: "Modelamiento de Procesos", professorName: "Elard Rodriguez"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MARTES", startTime: "08:00", endTime: "09:40", courseName: "Matemática Discreta", professorName: "Silvia Centella"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MARTES", startTime: "09:40", endTime: "11:20", courseName: "Matemática Discreta", professorName: "Silvia Centella"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MARTES", startTime: "11:20", endTime: "13:00", courseName: "INE-323 Estadistica y Prob", professorName: ""), // Profesor vacío
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MARTES", startTime: "15:00", endTime: "16:40", courseName: "Taller de liderazgo y emprendimiento", professorName: "Liliana Vega"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MIÉRCOLES", startTime: "08:00", endTime: "09:40", courseName: "Matemática Discreta", professorName: "Silvia Centella"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MIÉRCOLES", startTime: "09:40", endTime: "11:20", courseName: "Matemática Discreta", professorName: "Silvia Centella"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MIÉRCOLES", startTime: "11:20", endTime: "13:00", courseName: "Ingeniería econ. y Financiera", professorName: "Liliana Vega"), // L. Vega -> Liliana Vega
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MIÉRCOLES", startTime: "15:50", endTime: "17:30", courseName: "Ingeniería de Requerimientos", professorName: "Mariella Ibarra"), // Mibarra -> Mariella Ibarra
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "MIÉRCOLES", startTime: "17:30", endTime: "19:10", courseName: "Ingeniería de Software", professorName: "Martha Paredes"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "JUEVES", startTime: "08:00", endTime: "10:30", courseName: "EG-322 ETICA", professorName: "A. Crisosto"),
        OccupiedSlotModel(id: '', laboratoryId: "SALON Q-312", dayOfWeek: "VIERNES", startTime: "08:00", endTime: "10:30", courseName: "INE-321 ECONOMIA", professorName: "D. Rubira"),
      ];

      int slotsAdded = 0;
      for (var slotData in occupiedSlots) { 
        String? currentCourseName = slotData.courseName; // Usar una variable local para el nombre del curso

        // Validación de Curso
        bool courseExists = courses.any((c) => c.name == currentCourseName);
        if (currentCourseName != null && currentCourseName.isNotEmpty) {
            if (!courseExists) {
                bool flexibleMatch = courses.any((c) => c.name.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u') == currentCourseName?.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u'));
                if (flexibleMatch) {
                    currentCourseName = courses.firstWhere((c) => c.name.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u') == currentCourseName?.toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u')).name;
                    _log('Info (Curso): "${currentCourseName}" ajustado por coincidencia flexible.');
                } else {
                    _log('Advertencia (Curso): "${currentCourseName}" para ${slotData.laboratoryId} ${slotData.dayOfWeek} ${slotData.startTime}-${slotData.endTime} NO ENCONTRADO en la lista de cursos definidos. Omitiendo slot.');
                    continue;
                }
            }
        } else if (currentCourseName == null || currentCourseName.isEmpty) {
             _log('Advertencia (Curso): Nombre de curso vacío o nulo para ${slotData.laboratoryId} ${slotData.dayOfWeek} ${slotData.startTime}-${slotData.endTime}. Omitiendo slot.');
            continue;
        }


        // Validación de Laboratorio
        bool labExists = laboratories.any((l) => l.name == slotData.laboratoryId);
        if (!labExists) {
          _log('Advertencia (Lab): "${slotData.laboratoryId}" para ${currentCourseName} ${slotData.dayOfWeek} ${slotData.startTime}-${slotData.endTime} NO ENCONTRADO. Omitiendo slot.');
          continue;
        }

        // Nueva lógica de validación y asignación de profesor
        String? finalProfessorName = slotData.professorName; 

        if (finalProfessorName == null || finalProfessorName.isEmpty) { 
            finalProfessorName = "POR ASIGNAR";
            _log('Info (Profesor): Nombre de profesor vacío para el curso "${currentCourseName}" en ${slotData.laboratoryId} (${slotData.dayOfWeek} ${slotData.startTime}-${slotData.endTime}). Se usará "POR ASIGNAR".');
        } else {
            bool profExistsInList = professors.any((p) => p.name == finalProfessorName);
            if (!profExistsInList) {
                List<String> profsInSlotName = finalProfessorName.split('/').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
                if (profsInSlotName.length > 1) { 
                    bool allProfsInListNameExist = true;
                    for (String pNamePart in profsInSlotName) {
                        if (!professors.any((p) => p.name == pNamePart)) {
                            allProfsInListNameExist = false;
                            break;
                        }
                    }
                    if (!allProfsInListNameExist) {
                        _log('Advertencia (Profesor): Al menos un profesor en "${finalProfessorName}" (curso "${currentCourseName}", lab: ${slotData.laboratoryId}, ${slotData.dayOfWeek} ${slotData.startTime}-${slotData.endTime}) NO ENCONTRADO en la lista. Se usará "POR ASIGNAR".');
                        finalProfessorName = "POR ASIGNAR";
                    }
                } else { 
                     _log('Advertencia (Profesor): "${finalProfessorName}" (curso "${currentCourseName}", lab: ${slotData.laboratoryId}, ${slotData.dayOfWeek} ${slotData.startTime}-${slotData.endTime}) NO ENCONTRADO en la lista. Se usará "POR ASIGNAR".');
                     finalProfessorName = "POR ASIGNAR";
                }
            }
        }
        
        OccupiedSlotModel slotToUpload = OccupiedSlotModel(
            id: '', // Añadido ID placeholder
            laboratoryId: slotData.laboratoryId,
            dayOfWeek: slotData.dayOfWeek,
            startTime: slotData.startTime,
            endTime: slotData.endTime,
            courseName: currentCourseName, // Usar el nombre del curso validado/ajustado
            professorName: finalProfessorName 
        );

        bool slotExistsFs = await _firestoreService.checkOccupiedSlotExists(slotToUpload.laboratoryId, slotToUpload.dayOfWeek.toUpperCase(), slotToUpload.startTime);
        if (!slotExistsFs) {
          await _firestoreService.addOccupiedSlot(slotToUpload);
          slotsAdded++;
        } else {
          _log('Horario ya existente omitido en Firestore: ${slotToUpload.laboratoryId}, ${slotToUpload.dayOfWeek}, ${slotToUpload.startTime}');
        }
      }
      _log('$slotsAdded horarios fijos nuevos añadidos.');

      _log('¡Proceso de carga de datos estructurados completado!');
    } catch (e, s) {
      _log('Error durante la carga: ${e.toString()}');
      _log('Stack trace: ${s.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryDark,
      appBar: AppBar(
        title: const Text('Carga de Datos Estructurados', style: TextStyle(color: textOnDark)),
        backgroundColor: primaryDarkPurple,
        iconTheme: const IconThemeData(color: accentPurple),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Esta pantalla carga datos predefinidos y estructurados a Firestore.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: textOnDarkSecondary),
              ),
              const SizedBox(height: 30),
              if (_isUploading)
                const Column(
                  children: [
                    CircularProgressIndicator(color: accentPurple),
                    SizedBox(height: 15),
                    Text("Cargando...", style: TextStyle(color: accentPurple)),
                  ],
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_upload_outlined, color: primaryDarkPurple),
                  label: const Text('Cargar Datos Estructurados', style: TextStyle(color: primaryDarkPurple, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onPressed: _uploadStructuredData, // Cambiado a la nueva función
                ),
              const SizedBox(height: 20),
              if (_uploadStatus.isNotEmpty && !_isUploading) 
                Text(
                  _uploadStatus, 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _uploadStatus.toLowerCase().contains('error') || _uploadStatus.toLowerCase().contains('advertencia') 
                           
                           ? Colors.orangeAccent 
                           : Colors.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),
              if (_uploadLog.isNotEmpty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: primaryDarkPurple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accentPurple.withOpacity(0.2)),
                    ),
                    child: ListView.builder(
                      itemCount: _uploadLog.length,
                      itemBuilder: (context, index) {
                                               final logEntry = _uploadLog[index];
                        Color logColor = textOnDarkSecondary.withOpacity(0.8);
                        if (logEntry.toLowerCase().contains('error')) {
                          logColor = Colors.redAccent.shade100;
                        } else if (logEntry.toLowerCase().contains('advertencia')) {
                          logColor = Colors.orangeAccent.shade100;
                        } else if (logEntry.toLowerCase().contains('completado') || logEntry.toLowerCase().contains('añadidos') || logEntry.toLowerCase().contains('info')) {
                           logColor = Colors.greenAccent.shade100;
                        }
                        return Text(
                          logEntry,
                          style: TextStyle(
                            color: logColor,
                            fontSize: 12,
                          ),
                        );
                      },
                                       ),
                  ),
                ),
            ],
          ),
               ),
      ),
    );
  }
}
