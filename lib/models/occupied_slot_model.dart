class OccupiedSlotModel {
  final String slotId;
  final String laboratoryId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? courseName;
  final String? professorName; // Añadir professorName

  OccupiedSlotModel({
    required this.slotId,
    required this.laboratoryId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.courseName,
    this.professorName, // Añadir professorName aquí
  });

  factory OccupiedSlotModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OccupiedSlotModel(
      slotId: documentId,
      laboratoryId: data['laboratoryId'] ?? '',
      dayOfWeek: data['dayOfWeek'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      courseName: data['courseName'] as String?,
      professorName: data['professorName'] as String?, // Añadir professorName aquí
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'laboratoryId': laboratoryId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'courseName': courseName,
      'professorName': professorName, // Añadir professorName aquí
    };
  }
}
