class CourseModel {
  final String id;
  final String name;
  final int? semester; // Hacerlo opcional o requerido según tu necesidad

  CourseModel({
    required this.id,
    required this.name,
    this.semester, // Añadir semester aquí
  });

  factory CourseModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CourseModel(
      id: documentId,
      name: data['name'] ?? '',
      semester: data['semester'] as int?, // Castear a int?
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'semester': semester, // Añadir semester aquí
    };
  }
}
