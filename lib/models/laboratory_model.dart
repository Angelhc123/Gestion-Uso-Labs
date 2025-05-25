class LaboratoryModel {
  final String id;
  final String name;
  final int? capacity; // Hacerlo opcional o requerido
  final List<String>? resources; // Hacerlo opcional o requerido

  LaboratoryModel({
    required this.id,
    required this.name,
    this.capacity, // Añadir capacity
    this.resources, // Añadir resources
  });

  // Método para convertir un LaboratoryModel a un Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'capacity': capacity,
      'resources': resources,
    };
  }

  // Método para crear un LaboratoryModel desde un Map (de Firestore)
  factory LaboratoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LaboratoryModel(
      id: documentId,
      name: map['name'] ?? '',
      capacity: map['capacity'] as int?,
      resources: map['resources'] != null ? List<String>.from(map['resources']) : null,
    );
  }
}
