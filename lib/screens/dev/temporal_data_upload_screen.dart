import 'package:controlusolab/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/models/occupied_slot_model.dart';

// Paleta de colores
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
        _uploadStatus = message; // Mostrar el último log como estado actual
      });
    }
  }

  Future<void> _uploadSampleData() async {
    if (!mounted) return;
    setState(() {
      _isUploading = true;
      _uploadLog.clear();
    });
    _log('Iniciando carga de datos de ejemplo...');

    try {
      // 1. Cargar Cursos
      _log('Procesando cursos...');
      final List<CourseModel> courses = [
        CourseModel(id: '', name: 'PROGRAMACIÓN ORIENTADA A OBJETOS', semester: 3),
        CourseModel(id: '', name: 'ESTRUCTURA DE DATOS', semester: 4),
        CourseModel(id: '', name: 'BASES DE DATOS I', semester: 5),
        CourseModel(id: '', name: 'INGENIERÍA DE SOFTWARE I', semester: 6),
        CourseModel(id: '', name: 'REDES DE COMPUTADORAS', semester: 7),
        CourseModel(id: '', name: 'SISTEMAS OPERATIVOS', semester: 5),
        CourseModel(id: '', name: 'INTELIGENCIA ARTIFICIAL', semester: 8),
        CourseModel(id: '', name: 'DESARROLLO DE APLICACIONES MÓVILES', semester: 7),
        CourseModel(id: '', name: 'SEGURIDAD INFORMÁTICA', semester: 8),
        CourseModel(id: '', name: 'PROYECTO DE GRADO I', semester: 9),
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

      // 2. Cargar Laboratorios
      _log('Procesando laboratorios...');
      final List<LaboratoryModel> laboratories = [
        LaboratoryModel(id: '', name: 'LABORATORIO A (Windows)', capacity: 30, resources: ['PCs Windows', 'Proyector', 'Pizarra']),
        LaboratoryModel(id: '', name: 'LABORATORIO B (Linux)', capacity: 25, resources: ['PCs Linux', 'Proyector']),
        LaboratoryModel(id: '', name: 'LABORATORIO C (Mac)', capacity: 20, resources: ['iMacs', 'Proyector', 'Pizarra Interactiva']),
        LaboratoryModel(id: '', name: 'LABORATORIO DE REDES', capacity: 20, resources: ['PCs', 'Routers', 'Switches', 'Proyector']),
        LaboratoryModel(id: '', name: 'LABORATORIO MULTIMEDIA', capacity: 15, resources: ['PCs Alta Gama', 'Tabletas Gráficas', 'Proyector 4K']),
      ];
      int labsAdded = 0;
      for (var lab in laboratories) {
        bool exists = await _firestoreService.checkLaboratoryExists(lab.name);
        if (!exists) {
          await _firestoreService.addLaboratory(lab);
          labsAdded++;
        }
      }
      _log('$labsAdded laboratorios nuevos añadidos.');

      // 3. Cargar Horarios Fijos (Occupied Slots)
      _log('Procesando horarios fijos...');
      final List<OccupiedSlotModel> occupiedSlots = [
        OccupiedSlotModel(slotId: '', laboratoryId: 'LABORATORIO_A_WINDOWS', dayOfWeek: 'LUNES', startTime: '08:00', endTime: '10:00', courseName: 'PROGRAMACIÓN ORIENTADA A OBJETOS', professorName: 'Dr. Alan Turing'),
        OccupiedSlotModel(slotId: '', laboratoryId: 'LABORATORIO_A_WINDOWS', dayOfWeek: 'LUNES', startTime: '10:00', endTime: '12:00', courseName: 'ESTRUCTURA DE DATOS', professorName: 'Dra. Ada Lovelace'),
        OccupiedSlotModel(slotId: '', laboratoryId: 'LABORATORIO_B_LINUX', dayOfWeek: 'MARTES', startTime: '14:00', endTime: '16:00', courseName: 'SISTEMAS OPERATIVOS', professorName: 'Prof. Linus Torvalds'),
        OccupiedSlotModel(slotId: '', laboratoryId: 'LABORATORIO_C_MAC', dayOfWeek: 'MIÉRCOLES', startTime: '09:00', endTime: '11:00', courseName: 'DESARROLLO DE APLICACIONES MÓVILES', professorName: 'Ing. Steve Wozniak'),
        OccupiedSlotModel(slotId: '', laboratoryId: 'LABORATORIO_A_WINDOWS', dayOfWeek: 'JUEVES', startTime: '16:00', endTime: '18:00', courseName: 'BASES DE DATOS I', professorName: 'Dr. Edgar Codd'),
        OccupiedSlotModel(slotId: '', laboratoryId: 'LABORATORIO_DE_REDES', dayOfWeek: 'VIERNES', startTime: '11:00', endTime: '13:00', courseName: 'REDES DE COMPUTADORAS', professorName: 'Prof. Vint Cerf'),
      ];
      int slotsAdded = 0;
      for (var slot in occupiedSlots) {
        bool exists = await _firestoreService.checkOccupiedSlotExists(slot.laboratoryId, slot.dayOfWeek, slot.startTime);
        if (!exists) {
          await _firestoreService.addOccupiedSlot(slot);
          slotsAdded++;
        }
      }
      _log('$slotsAdded horarios fijos nuevos añadidos.');

      _log('¡Proceso de carga de datos de ejemplo completado!');
    } catch (e) {
      _log('Error durante la carga: ${e.toString()}');
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
        title: const Text('Carga de Datos Temporales', style: TextStyle(color: textOnDark)),
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
                'Esta pantalla es para cargar datos iniciales/de ejemplo a Firestore.',
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
                  label: const Text('Cargar Datos de Ejemplo', style: TextStyle(color: primaryDarkPurple, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  onPressed: _uploadSampleData,
                ),
              const SizedBox(height: 20),
              if (_uploadStatus.isNotEmpty && !_isUploading) // Mostrar el estado final solo cuando no está cargando
                Text(
                  _uploadStatus, // El último mensaje del log se muestra aquí
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _uploadStatus.toLowerCase().contains('error') ? Colors.redAccent : Colors.greenAccent,
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
                        return Text(
                          logEntry,
                          style: TextStyle(
                            color: logEntry.toLowerCase().contains('error') ? Colors.redAccent.shade100 : textOnDarkSecondary.withOpacity(0.8),
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
