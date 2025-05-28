import 'package:cloud_firestore/cloud_firestore.dart';

class LabRequestModel {
  final String id;
  final String userId;
  final String? userName;
  final String cycle;
  final String courseOrTheme;
  final String laboratoryId;
  final String laboratoryName;
  final Timestamp entryTime;
  final Timestamp exitTime;
  final Timestamp requestDate;
  final String status; // PENDIENTE, APROBADO, RECHAZADO
  final String? professorName;
  final Timestamp? createdAt;
  final String? processedBySupportUserId;
  final Timestamp? processedTimestamp;
  final String? supportComment;
  final String? justification; // NUEVO CAMPO

  LabRequestModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.cycle,
    required this.courseOrTheme,
    required this.laboratoryId,
    required this.laboratoryName,
    required this.entryTime,
    required this.exitTime,
    required this.requestDate,
    required this.status,
    this.professorName,
    this.createdAt,
    this.processedBySupportUserId,
    this.processedTimestamp,
    this.supportComment,
    this.justification, // AÑADIDO AL CONSTRUCTOR
  });

  LabRequestModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? cycle,
    String? courseOrTheme,
    String? laboratoryId,
    String? laboratoryName,
    Timestamp? entryTime,
    Timestamp? exitTime,
    Timestamp? requestDate,
    String? status,
    String? professorName,
    Timestamp? createdAt,
    String? processedBySupportUserId,
    Timestamp? processedTimestamp,
    String? supportComment,
    String? justification, // AÑADIDO A COPYWITH
  }) {
    return LabRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      cycle: cycle ?? this.cycle,
      courseOrTheme: courseOrTheme ?? this.courseOrTheme,
      laboratoryId: laboratoryId ?? this.laboratoryId,
      laboratoryName: laboratoryName ?? this.laboratoryName,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      professorName: professorName ?? this.professorName,
      createdAt: createdAt ?? this.createdAt,
      processedBySupportUserId: processedBySupportUserId ?? this.processedBySupportUserId,
      processedTimestamp: processedTimestamp ?? this.processedTimestamp,
      supportComment: supportComment ?? this.supportComment,
      justification: justification ?? this.justification, // AÑADIDO
    );
  }

  factory LabRequestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LabRequestModel(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'],
      cycle: map['cycle'] ?? '',
      courseOrTheme: map['courseOrTheme'] ?? '',
      laboratoryId: map['laboratoryId'] ?? '',
      laboratoryName: map['laboratoryName'] ?? '',
      entryTime: map['entryTime'] ?? Timestamp.now(),
      exitTime: map['exitTime'] ?? Timestamp.now(),
      requestDate: map['requestDate'] ?? Timestamp.now(),
      status: map['status'] ?? 'PENDIENTE',
      professorName: map['professorName'],
      createdAt: map['createdAt'],
      processedBySupportUserId: map['processedBySupportUserId'],
      processedTimestamp: map['processedTimestamp'],
      supportComment: map['supportComment'],
      justification: map['justification'], // AÑADIDO A FROMMAP
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'cycle': cycle,
      'courseOrTheme': courseOrTheme,
      'laboratoryId': laboratoryId,
      'laboratoryName': laboratoryName,
      'entryTime': entryTime,
      'exitTime': exitTime,
      'requestDate': requestDate,
      'status': status,
      'professorName': professorName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'processedBySupportUserId': processedBySupportUserId,
      'processedTimestamp': processedTimestamp,
      'supportComment': supportComment,
      'justification': justification, // AÑADIDO A TOMAP
    };
  }
}
