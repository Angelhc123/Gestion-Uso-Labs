import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode y ChangeNotifier
import 'package:controlusolab/models/user_model.dart' as model;

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<String?> get userRoleStream {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        if (kDebugMode) print("AuthService/userRoleStream: No user authenticated, role is null.");
        return null;
      }
      try {
        if (kDebugMode) print("AuthService/userRoleStream: User ${user.uid} authenticated. Fetching role...");
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('role') && data['role'] != null) {
            String role = data['role'] as String;
            if (kDebugMode) print("AuthService/userRoleStream: User ${user.uid} - Role from Firestore: '$role'");
            // Normalizar el rol a minúsculas para evitar problemas de mayúsculas/minúsculas
            role = role.toLowerCase();
            if (role == "admin" || role == "support" || role == "user") {
               return role;
            } else {
              if (kDebugMode) print("AuthService/userRoleStream: User ${user.uid} - Unknown role '$role' found. Defaulting to 'user'.");
              return 'user'; // O manejar como un error/rol inválido
            }
          } else {
            if (kDebugMode) print("AuthService/userRoleStream: User ${user.uid} document exists but 'role' field is missing or null. Defaulting to 'user' and updating Firestore.");
            await _firestore.collection('users').doc(user.uid).set({'role': 'user'}, SetOptions(merge: true));
            return 'user';
          }
        } else {
          // El documento del usuario no existe. Esto es para nuevos usuarios.
          // Un admin/support debería tener su documento creado previamente.
          if (kDebugMode) print("AuthService/userRoleStream: Document for ${user.uid} does not exist. Creating with role 'user'.");
          model.UserModel newUser = model.UserModel(
            uid: user.uid,
            email: user.email ?? 'N/A', // Proporcionar un valor predeterminado si el correo es nulo
            role: 'user',
            // CORREGIDO: Usar isActive
            isActive: true, 
          );
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
          return 'user';
        }
      } catch (e) {
        if (kDebugMode) {
          print("AuthService/userRoleStream: Error fetching role for ${user.uid}: $e. Defaulting to 'user'.");
        }
        return 'user';
      }
    }); // Cierre del asyncMap
  } // Cierre del getter userRoleStream

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners(); 
      return result.user;
    } on FirebaseAuthException catch (e) { 
      throw Exception(e.message); 
    } catch (e) {
      throw Exception("Ocurrió un error desconocido durante el inicio de sesión.");
    }
  }

  // CORREGIDO: Asegurar que displayName sea un parámetro nombrado y el tipo de retorno sea User?
  // El parámetro 'role' se mantiene en la firma si lo necesitas para lógica externa,
  // pero no se usa directamente aquí para la creación del usuario en Firebase Auth.
  Future<User?> createUserWithEmailAndPassword(String email, String password, {String? displayName, String role = 'user'}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user; // user puede ser null
      if (user != null) { // Siempre verificar si user no es null antes de usarlo
        if (displayName != null && displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
          await user.reload(); // Recargar para obtener el displayName actualizado
          // Asignar el usuario actualizado de Firebase Auth, que debería tener el displayName
          user = _auth.currentUser; 
        }
      }
      return user; // Retorna User?
    } on FirebaseAuthException catch (e) {
      // Manejar errores específicos si es necesario, ej: email-already-in-use
      throw e;
    }
  }

  Future<String> createSupportUser(String email, String password) async {
    try {
      // Primero, verifica si el correo ya existe para evitar errores de Firebase Auth si es posible
      // Esta es una verificación adicional, Firebase Auth también lo hará.
      var existingUser = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
      if (existingUser.docs.isNotEmpty) {
          throw Exception('El correo electrónico ya está registrado en la base de datos de usuarios.');
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? supportUser = result.user;

      if (supportUser != null) {
        model.UserModel newUserDoc = model.UserModel(
          uid: supportUser.uid,
          email: supportUser.email ?? '',
          role: 'support', 
          // CORREGIDO: Usar isActive
          isActive: true, 
        );
        await _firestore.collection('users').doc(supportUser.uid).set(newUserDoc.toMap());
        
        notifyListeners(); 
        return supportUser.uid;
      } else {
        throw Exception('No se pudo crear el usuario de soporte en Firebase Auth.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('El correo electrónico ya está en uso por otra cuenta de autenticación.');
      } else if (e.code == 'weak-password') {
        throw Exception('La contraseña es demasiado débil.');
      }
      throw Exception(e.message ?? 'Error al crear usuario de soporte.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // CORREGIDO: El método ahora se llama setUserActiveStatus y opera sobre 'isActive'
  Future<void> setUserActiveStatus(String uid, bool newIsActiveStatus) async {
    try {
      await _firestore.collection('users').doc(uid).update({'isActive': newIsActiveStatus});
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error al actualizar estado de activo para $uid: $e");
      }
      throw Exception("Error al actualizar el estado del usuario.");
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners(); 
    } catch (e) {
      if (kDebugMode) {
        print("Error al cerrar sesión: $e");
      }
      // No es necesario lanzar una excepción aquí a menos que quieras manejarla específicamente en la UI.
      // El AuthWrapper se encargará de redirigir a LoginScreen.
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('role') && data['role'] != null) {
          return (data['role'] as String).toLowerCase(); 
        }
      }
      if (kDebugMode) print("AuthService/getUserRole: No role found for $uid or document doesn't exist.");
      return null; 
    } catch (e) {
      if (kDebugMode) {
        print("Error al obtener rol del usuario $uid: $e");
      }
      return null; 
    }
  }
} // Cierre de la clase AuthService
