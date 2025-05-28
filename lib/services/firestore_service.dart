import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/models/occupied_slot_model.dart';
import 'package:controlusolab/models/professor_model.dart';
import 'package:controlusolab/models/user_model.dart' as model; // Alias para UserModel
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Métodos para Cursos
  Future<void> addCourse(CourseModel course) {
    return _db.collection('courses').add(course.toMap());
  }

  Future<bool> checkCourseExists(String courseName) async {
    final querySnapshot = await _db
        .collection('courses')
        .where('name', isEqualTo: courseName)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Stream<List<CourseModel>> getCoursesStream() { // Mantenemos el Stream para reactividad si es necesario en otros lugares
    return _db.collection('courses').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<List<CourseModel>> getCourses() { // Nuevo método para obtener una vez
    return _db.collection('courses').get().then((snapshot) => snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Métodos para Laboratorios
  Future<void> addLaboratory(LaboratoryModel laboratory) {
    return _db.collection('laboratories').add(laboratory.toMap());
  }

  Future<bool> checkLaboratoryExists(String labName) async {
    final querySnapshot = await _db
        .collection('laboratories')
        .where('name', isEqualTo: labName)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Stream<List<LaboratoryModel>> getLaboratoriesStream() { // Mantenemos el Stream
    return _db.collection('laboratories').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => LaboratoryModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<List<LaboratoryModel>> getLaboratories() { // Nuevo método para obtener una vez
    return _db.collection('laboratories').get().then((snapshot) =>
        snapshot.docs.map((doc) => LaboratoryModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Métodos para Profesores
  Future<void> addProfessor(ProfessorModel professor) {
    return _db.collection('professors').add(professor.toMap());
  }

  Future<bool> checkProfessorExists(String professorName) async {
    final querySnapshot = await _db
        .collection('professors')
        .where('name', isEqualTo: professorName)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Stream<List<ProfessorModel>> getProfessorsStream() {
    return _db.collection('professors').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => ProfessorModel.fromMap(doc.data(), doc.id))
        .toList());
  }
  
  // Métodos para Horarios Ocupados
  Future<void> addOccupiedSlot(OccupiedSlotModel slot) {
    return _db.collection('occupiedSlots').add(slot.toMap());
  }

  Future<bool> checkOccupiedSlotExists(String laboratoryId, String dayOfWeek, String startTime) async {
    final querySnapshot = await _db
        .collection('occupiedSlots')
        .where('laboratoryId', isEqualTo: laboratoryId)
        .where('dayOfWeek', isEqualTo: dayOfWeek)
        .where('startTime', isEqualTo: startTime)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Stream<List<OccupiedSlotModel>> getOccupiedSlotsStream() {
    return _db.collection('occupiedSlots').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => OccupiedSlotModel.fromMap(doc.data(), doc.id))
        .toList());
  }
  
  Stream<List<OccupiedSlotModel>> getOccupiedSlotsByLaboratoryAndDay(String laboratoryId, String dayOfWeek) { // Renombrado
    return _db
        .collection('occupiedSlots')
        .where('laboratoryId', isEqualTo: laboratoryId)
        .where('dayOfWeek', isEqualTo: dayOfWeek)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OccupiedSlotModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Métodos para Solicitudes de Laboratorio (LabRequestModel)
  Future<void> addLabRequest(LabRequestModel request) { // Acepta LabRequestModel
    return _db.collection('labRequests').add(request.toMap());
  }

  Stream<List<LabRequestModel>> getLabRequestsByLaboratoryId(String laboratoryId) {
    return _db
        .collection('labRequests')
        .where('laboratoryId', isEqualTo: laboratoryId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LabRequestModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<LabRequestModel>> getLabRequestsByLaboratoryAndDate(String laboratoryId, DateTime date) { // Acepta DateTime
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    Timestamp startTimestamp = Timestamp.fromDate(startOfDay);
    Timestamp endTimestamp = Timestamp.fromDate(endOfDay);

    return _db
        .collection('labRequests')
        .where('laboratoryId', isEqualTo: laboratoryId)
        .where('requestDate', isGreaterThanOrEqualTo: startTimestamp)
        .where('requestDate', isLessThanOrEqualTo: endTimestamp)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LabRequestModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<LabRequestModel>> getProcessedLabRequests() {
    return _db
        .collection('labRequests')
        .where('status', whereIn: ['APROBADO', 'RECHAZADO']) // Ajusta según tus estados
        .orderBy('processedTimestamp', descending: true) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LabRequestModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateLabRequestStatus(String requestId, String newStatus, String supportComment, String supportUserId) {
    return _db.collection('labRequests').doc(requestId).update({
      'status': newStatus,
      'supportComment': supportComment,
      'processedBySupportUserId': supportUserId,
      'processedTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<Map<DateTime, List<LabRequestModel>>> getGroupedAndSortedPendingLabRequests() {
    return _db
        .collection('labRequests')
        .where('status', isEqualTo: 'PENDIENTE') // Asegúrate que 'PENDIENTE' sea el estado correcto
        .orderBy('requestDate', descending: false) 
        .snapshots()
        .map((snapshot) {
      final Map<DateTime, List<LabRequestModel>> grouped = {};
      for (var doc in snapshot.docs) {
        final request = LabRequestModel.fromMap(doc.data(), doc.id);
        final dateKey = DateTime(request.requestDate.toDate().year, request.requestDate.toDate().month, request.requestDate.toDate().day);
        if (grouped[dateKey] == null) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(request);
      }
      grouped.forEach((date, requests) {
        requests.sort((a, b) => a.entryTime.compareTo(b.entryTime));
      });
      return grouped;
    });
  }

  // Métodos para Usuarios de Soporte
  Future<model.UserModel?> getSupportUserById(String uid) async { // MODIFICADO: UserModel a model.UserModel
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && (doc.data() as Map<String, dynamic>)['role'] == 'support') {
        return model.UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id); // MODIFICADO: UserModel a model.UserModel
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error en getSupportUserById: $e');
      }
      return null;
    }
  }

  // --- Gestión de Usuarios (General) ---
  Future<void> createUserDocument(model.UserModel user) async { // MODIFICADO: UserModel a model.UserModel
    try {
      await _db.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      // print("Error creando documento de usuario: $e");
      rethrow;
    }
  }

  Future<model.UserModel?> getUserDocument(String uid) async { // MODIFICADO: UserModel a model.UserModel
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return model.UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id); // MODIFICADO: UserModel a model.UserModel
      }
      return null;
    } catch (e) {
      // print("Error obteniendo documento de usuario: $e");
      rethrow;
    }
  }

  // --- Gestión de Usuarios de Soporte (Específico para Admin) ---
  Stream<List<model.UserModel>> getSupportUsers() { // MODIFICADO: UserModel a model.UserModel
    return _db
        .collection('users')
        .where('role', isEqualTo: 'support')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.UserModel.fromMap(doc.data(), doc.id)) // MODIFICADO: UserModel a model.UserModel
            .toList());
  }

  Future<void> updateUserSupportStatus(String userId, bool isActive) async {
    try {
      await _db.collection('users').doc(userId).update({'isActive': isActive});
    } catch (e) {
      // print("Error actualizando estado de usuario de soporte: $e");
      rethrow;
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _db.collection('users').doc(userId).update({'role': newRole});
    } catch (e) {
      // print("Error actualizando rol de usuario: $e");
      rethrow;
    }
  }


  // Nuevo método para obtener todas las solicitudes de un usuario
  Stream<List<LabRequestModel>> getLabRequestsByUserId(String userId) {
    return _db
        .collection('labRequests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true) // Más recientes primero
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LabRequestModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) 
            .toList());
  }

  // Método para obtener todos los usuarios (si aún no existe)
  Stream<List<model.UserModel>> getUsers() {
    return _db.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => model.UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList()); // MODIFICADO
  }

  // NUEVO MÉTODO: Obtener usuarios por rol
  Stream<List<model.UserModel>> getUsersByRole(String role) {
    return _db
        .collection('users')
        .where('role', isEqualTo: role.toLowerCase()) // Asegurar comparación en minúsculas
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)) // MODIFICADO
            .toList());
  }

  Future<void> addUser(model.UserModel user) {
    return _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> updateUser(model.UserModel user) {
    return _db.collection('users').doc(user.uid).update(user.toMap());
  }
}
