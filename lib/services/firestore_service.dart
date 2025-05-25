import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:controlusolab/models/course_model.dart';
import 'package:controlusolab/models/lab_request_model.dart';
import 'package:controlusolab/models/laboratory_model.dart';
import 'package:controlusolab/models/occupied_slot_model.dart';
import 'package:controlusolab/models/user_model.dart' as model;
import 'package:flutter/foundation.dart'; // Para kDebugMode

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Métodos para Usuarios ---
  Future<model.UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return model.UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener usuario $uid: $e");
      }
    }
    return null;
  }

  Future<model.UserModel?> getSupportUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = model.UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        if (user.role == 'support') {
          return user;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener usuario de soporte $uid: $e");
      }
    }
    return null;
  }

  Stream<List<model.UserModel>> getSupportUsers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'support')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model.UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList())
        .handleError((error) {
      if (kDebugMode) {
        print("Error al obtener usuarios de soporte: $error");
      }
      return [];
    });
  }


  // --- Métodos para Cursos ---
  Future<void> addCourse(CourseModel course) async {
    try {
      await _db.collection('courses').add(course.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error al añadir curso: $e");
      }
      rethrow; // Re-lanzar para que la UI pueda manejarlo si es necesario
    }
  }

  Stream<List<CourseModel>> getCourses() {
    return _db.collection('courses').snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => CourseModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error al mapear cursos: $e");
        }
        return <CourseModel>[]; // Devolver lista vacía del tipo correcto
      }
    }).handleError((error) {
      if (kDebugMode) {
        print("Error en stream de cursos: $error");
      }
      return <CourseModel>[]; // Devolver lista vacía del tipo correcto
    });
  }

  Future<bool> checkCourseExists(String courseName) async {
    try {
      final querySnapshot = await _db
          .collection('courses')
          .where('name', isEqualTo: courseName)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error al verificar existencia de curso '$courseName': $e");
      }
      return false; // Asumir que no existe en caso de error para evitar bloqueos
    }
  }

  // --- Métodos para Laboratorios ---
  Future<void> addLaboratory(LaboratoryModel laboratory) async {
    try {
      await _db.collection('laboratories').add(laboratory.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error al añadir laboratorio: $e");
      }
      rethrow;
    }
  }

  Stream<List<LaboratoryModel>> getLaboratories() {
    return _db.collection('laboratories').snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => LaboratoryModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error al mapear laboratorios: $e");
        }
        return <LaboratoryModel>[]; // Devolver lista vacía del tipo correcto
      }
    }).handleError((error) {
      if (kDebugMode) {
        print("Error en stream de laboratorios: $error");
      }
      return <LaboratoryModel>[]; // Devolver lista vacía del tipo correcto
    });
  }

  Future<bool> checkLaboratoryExists(String labName) async {
    try {
      final querySnapshot = await _db
          .collection('laboratories')
          .where('name', isEqualTo: labName)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error al verificar existencia de laboratorio '$labName': $e");
      }
      return false;
    }
  }

  // --- Métodos para Horarios Fijos (Occupied Slots) ---
  Future<void> addOccupiedSlot(OccupiedSlotModel slot) async {
    try {
      await _db.collection('occupiedSlots').add(slot.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error al añadir horario fijo: $e");
      }
      rethrow;
    }
  }

  Stream<List<OccupiedSlotModel>> getOccupiedSlotsByLaboratoryAndDay(String laboratoryId, String dayOfWeek) {
    return _db
        .collection('occupiedSlots')
        .where('laboratoryId', isEqualTo: laboratoryId)
        .where('dayOfWeek', isEqualTo: dayOfWeek)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => OccupiedSlotModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error al mapear horarios fijos para $laboratoryId, $dayOfWeek: $e");
        }
        return <OccupiedSlotModel>[]; // Devolver lista vacía del tipo correcto
      }
    }).handleError((error) {
      if (kDebugMode) {
        print("Error en stream de horarios fijos para $laboratoryId, $dayOfWeek: $error");
      }
      return <OccupiedSlotModel>[]; // Devolver lista vacía del tipo correcto
    });
  }
  
  Future<bool> checkOccupiedSlotExists(String laboratoryId, String dayOfWeek, String startTime) async {
    try {
      final querySnapshot = await _db
          .collection('occupiedSlots')
          .where('laboratoryId', isEqualTo: laboratoryId)
          .where('dayOfWeek', isEqualTo: dayOfWeek)
          .where('startTime', isEqualTo: startTime)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error al verificar existencia de horario fijo para '$laboratoryId', '$dayOfWeek', '$startTime': $e");
      }
      return false;
    }
  }

  // --- Métodos para Solicitudes de Laboratorio (Lab Requests) ---
  Future<void> addLabRequest(LabRequestModel request) async {
    try {
      await _db.collection('labRequests').add(request.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error al añadir solicitud de laboratorio: $e");
      }
      rethrow;
    }
  }

  Stream<List<LabRequestModel>> getLabRequests() {
    return _db.collection('labRequests').orderBy('requestTime', descending: true).snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => LabRequestModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error al mapear solicitudes de laboratorio: $e");
        }
        return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
      }
    }).handleError((error) {
      if (kDebugMode) {
        print("Error en stream de solicitudes de laboratorio: $error");
      }
      return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
    });
  }

  Stream<List<LabRequestModel>> getPendingLabRequests() {
    return _db
        .collection('labRequests')
        .where('status', isEqualTo: 'pending')
        .orderBy('requestTime')
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => LabRequestModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error al mapear solicitudes pendientes: $e");
        }
        return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
      }
    }).handleError((error) {
      if (kDebugMode) {
        print("Error en stream de solicitudes pendientes: $error");
      }
      return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
    });
  }
  
  Stream<Map<DateTime, List<LabRequestModel>>> getGroupedAndSortedPendingLabRequests() {
    return getPendingLabRequests().map((requests) {
      final Map<DateTime, List<LabRequestModel>> grouped = {};
      for (var request in requests) {
        // Normalizar la fecha a medianoche para agrupar por día
        final dateKey = DateTime(request.entryTime.year, request.entryTime.month, request.entryTime.day);
        if (grouped[dateKey] == null) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(request);
      }
      // Ordenar las solicitudes dentro de cada día por hora de entrada
      grouped.forEach((key, dayRequests) {
        dayRequests.sort((a, b) => a.entryTime.compareTo(b.entryTime));
      });
      return grouped;
    }).handleError((error) {
      if (kDebugMode) {
        print("Error al agrupar solicitudes pendientes: $error");
      }
      return {};
    });
  }

  Stream<List<LabRequestModel>> getLabRequestsByLaboratoryAndDate(String laboratoryId, DateTime date) {
    // Obtener el inicio y fin del día para la consulta
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _db
        .collection('labRequests')
        .where('laboratoryId', isEqualTo: laboratoryId)
        .where('entryTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('entryTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        // .where('status', whereIn: ['pending', 'approved']) // Opcional: filtrar por estado
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => LabRequestModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error al mapear solicitudes por lab y fecha: $e");
        }
        return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
      }
    }).handleError((error) {
      if (kDebugMode) {
        print("Error en stream de solicitudes por lab y fecha: $error");
      }
      return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
    });
  }

  Stream<List<LabRequestModel>> getLabRequestsByLaboratoryId(String laboratoryId) {
     return _db
        .collection('labRequests')
        .where('laboratoryId', isEqualTo: laboratoryId)
        // .where('status', isEqualTo: 'approved') // Opcional: si solo quieres las aprobadas para el horario
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => LabRequestModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error al mapear solicitudes por ID de laboratorio: $e");
        }
        return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
      }
    }).handleError((error) {
      if (kDebugMode) {
        print("Error en stream de solicitudes por ID de laboratorio: $error");
      }
      return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
    });
  }
  
  Stream<List<LabRequestModel>> getProcessedLabRequests() {
    return _db
        .collection('labRequests')
        .where('status', whereIn: ['approved', 'rejected'])
        .orderBy('actionTimestamp', descending: true) // Ordenar por la fecha de acción
        .limit(50) // Limitar para no cargar demasiado historial de golpe
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => LabRequestModel.fromMap(doc.data(), doc.id)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error al mapear solicitudes procesadas: $e");
        }
        return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
      }
    }).handleError((error) {
      if (kDebugMode) {
        print("Error en stream de solicitudes procesadas: $error");
      }
      return <LabRequestModel>[]; // Devolver lista vacía del tipo correcto
    });
  }

  Future<void> updateLabRequestStatus(String requestId, String newStatus, String supportComment, String supportUserId) async {
    try {
      await _db.collection('labRequests').doc(requestId).update({
        'status': newStatus,
        'supportComment': supportComment,
        'processedBySupportUserId': supportUserId,
        'actionTimestamp': Timestamp.now(), // Registrar cuándo se tomó la acción
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error al actualizar estado de solicitud $requestId: $e");
      }
      rethrow;
    }
  }
}
