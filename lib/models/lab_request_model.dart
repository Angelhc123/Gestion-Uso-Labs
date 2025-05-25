import 'package:cloud_firestore/cloud_firestore.dart';

class LabRequestModel {
  final String id;
  final String userId;
  final String cycle;
  final String courseOrTheme;
  final String laboratory; // Nombre del laboratorio
  final String? laboratoryId; // ID del laboratorio, opcional por retrocompatibilidad
  final DateTime entryTime;
  final DateTime exitTime;
  final DateTime requestTime;
  final String status; // 'pending', 'approved', 'rejected'
  final String? supportComment; // Nuevo: Comentario del soporte
  final DateTime? actionTimestamp; // Nuevo: Hora de aprobación/rechazo
  final String? processedBySupportUserId; // Nuevo: ID del usuario de soporte que procesó

  LabRequestModel({
    required this.id,
    required this.userId,
    required this.cycle,
    required this.courseOrTheme,
    required this.laboratory,
    this.laboratoryId, // Añadido
    required this.entryTime,
    required this.exitTime,
    required this.requestTime,
    required this.status,
    this.supportComment,
    this.actionTimestamp,
    this.processedBySupportUserId,
  });

  // Método para convertir un LabRequestModel a un Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cycle': cycle,
      'courseOrTheme': courseOrTheme,
      'laboratory': laboratory,
      'laboratoryId': laboratoryId, // Añadido
      'entryTime': Timestamp.fromDate(entryTime),
      'exitTime': Timestamp.fromDate(exitTime),
      'requestTime': Timestamp.fromDate(requestTime),
      'status': status,
      'supportComment': supportComment, // Añadido
      'actionTimestamp': actionTimestamp != null ? Timestamp.fromDate(actionTimestamp!) : null, // Añadido
      'processedBySupportUserId': processedBySupportUserId, // Añadido
    };
  }

  // Método para crear un LabRequestModel desde un Map de Firestore
  factory LabRequestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LabRequestModel(
      id: documentId,
      userId: map['userId'] ?? '',
      cycle: map['cycle'] ?? '',
      courseOrTheme: map['courseOrTheme'] ?? '',
      laboratory: map['laboratory'] ?? '',
      laboratoryId: map['laboratoryId'], // Añadido
      entryTime: (map['entryTime'] as Timestamp).toDate(),
      exitTime: (map['exitTime'] as Timestamp).toDate(),
      requestTime: (map['requestTime'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      supportComment: map['supportComment'], // Añadido
      actionTimestamp: map['actionTimestamp'] != null ? (map['actionTimestamp'] as Timestamp).toDate() : null, // Añadido
      processedBySupportUserId: map['processedBySupportUserId'], // Añadido
    );
  }
}
