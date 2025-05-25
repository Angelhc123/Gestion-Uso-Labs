class UserModel {
  final String uid;
  final String code;
  final String firstName;
  final String lastName;
  final String role;
  final String email;
  bool isDisabled; // Nuevo campo para habilitar/deshabilitar

  UserModel({
    required this.uid,
    this.code = '', // Hacemos que no sea obligatorio para todos los roles
    this.firstName = '', // Hacemos que no sea obligatorio para todos los roles
    this.lastName = '', // Hacemos que no sea obligatorio para todos los roles
    required this.role,
    required this.email,
    this.isDisabled = false, // Por defecto, el usuario está habilitado
  });

  // Método para convertir un UserModel a un Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // uid también se guarda en el documento para facilitar consultas
      'code': code,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'email': email,
      'isDisabled': isDisabled, // Añadido al mapa
    };
  }

  // Método para crear un UserModel desde un Map de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId, // Usamos el ID del documento como uid principal
      code: map['code'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      role: map['role'] ?? 'user',
      email: map['email'] ?? '',
      isDisabled: map['isDisabled'] ?? false, // Leemos el nuevo campo
    );
  }
}
