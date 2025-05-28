class ProfessorModel {
  final String id;
  final String name;
  final String? department; // Puede ser opcional

  ProfessorModel({
    required this.id,
    required this.name,
    this.department,
  });

  // Método para convertir un ProfessorModel a un Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'department': department,
    };
  }

  // Método para crear un ProfessorModel desde un Map de Firestore
  factory ProfessorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProfessorModel(
      id: documentId,
      name: map['name'] ?? '',
      department: map['department'] as String?,
    );
  }
}
