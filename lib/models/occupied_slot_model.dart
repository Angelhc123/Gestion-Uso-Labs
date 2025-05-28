class OccupiedSlotModel {
  final String id; // Añadido
  final String laboratoryId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? courseName;
  final String? professorName;

  // Constructor para crear nuevas instancias (ej. antes de subir a Firestore)
  // slotId se inicializa internamente, ya que Firestore generará el ID del documento.
  OccupiedSlotModel({
    required this.id, // Añadido
    required this.laboratoryId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.courseName,
    this.professorName,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id' no se guarda usualmente en el mapa si es el ID del documento, Firestore lo maneja.
      // Si 'id' es un campo diferente, entonces sí inclúyelo.
      // Para este caso, asumimos que 'id' es el ID del documento y no se incluye en toMap.
      'laboratoryId': laboratoryId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'courseName': courseName,
      'professorName': professorName,
    };
  }

  factory OccupiedSlotModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OccupiedSlotModel(
      id: documentId, // Usar el ID del documento
      laboratoryId: map['laboratoryId'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      courseName: map['courseName'],
      professorName: map['professorName'],
    );
  }
}
