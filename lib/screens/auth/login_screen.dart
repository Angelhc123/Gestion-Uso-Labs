import 'package:controlusolab/screens/dev/temporal_data_upload_screen.dart'; // Asegúrate que la ruta sea correcta
import 'package:controlusolab/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Asegúrate de tener estas constantes o defínelas
const Color primaryDarkPurple = Color(0xFF381E72);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);
const Color secondaryDark = Color(0xFF1C1B1F);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (kDebugMode) print("LoginScreen: Attempting login...");
    FocusScope.of(context).unfocus(); // Ocultar teclado
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final user = await authService.signInWithEmailAndPassword(_email, _password);

        if (kDebugMode) {
          if (user != null) {
            print("LoginScreen: Login successful for user ${user.uid}. AuthWrapper should handle navigation.");
          } else {
            // Esto no debería ocurrir si signInWithEmailAndPassword lanza una excepción en caso de error.
            print("LoginScreen: Login returned null user without exception. This is unexpected.");
            _errorMessage = "Error desconocido. Intente de nuevo.";
          }
        }
        // No es necesario navegar aquí, AuthWrapper lo hará.
      } catch (e) {
        if (kDebugMode) print("LoginScreen: Login failed. Error: $e");
        setState(() {
          _errorMessage = e.toString().replaceFirst("Exception: ", ""); // Limpiar mensaje de error
        });
      } finally {
        if (mounted) { // Asegurar que el widget siga montado
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (kDebugMode) print("LoginScreen: Form validation failed.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(Icons.lock_outline, size: 80, color: accentPurple.withOpacity(0.8)),
                const SizedBox(height: 20),
                Text(
                  'Iniciar Sesión',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textOnDark.withOpacity(0.9)),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined, color: accentPurple.withOpacity(0.7)),
                    labelStyle: TextStyle(color: accentPurple.withOpacity(0.8)),
                    filled: true,
                    fillColor: primaryDarkPurple.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: accentPurple.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: accentPurple, width: 1.5),
                    ),
                  ),
                  style: const TextStyle(color: textOnDark),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Ingrese un correo válido' : null,
                  onSaved: (value) => _email = value!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_open_outlined, color: accentPurple.withOpacity(0.7)),
                    labelStyle: TextStyle(color: accentPurple.withOpacity(0.8)),
                    filled: true,
                    fillColor: primaryDarkPurple.withOpacity(0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: accentPurple.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: accentPurple, width: 1.5),
                    ),
                  ),
                  style: const TextStyle(color: textOnDark),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'La contraseña debe tener al menos 6 caracteres' : null,
                  onSaved: (value) => _password = value!,
                ),
                const SizedBox(height: 12),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: accentPurple),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPurple,
                        foregroundColor: primaryDarkPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _login,
                      child: const Text('Iniciar Sesión'),
                    ),
                  ),

                // BOTÓN PARA NAVEGAR A LA PANTALLA DE CARGA DE DATOS
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TemporalDataUploadScreen()),
                    );
                  },
                  child: const Text(
                    'Ir a Carga de Datos (DEV)',
                    style: TextStyle(color: accentPurple, decoration: TextDecoration.underline),
                  ),
                ),
                // FIN DEL BOTÓN DE CARGA DE DATOS

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Navegar a la pantalla de registro si existe
                    // Navigator.pushNamed(context, '/register');
                    if (kDebugMode) print("LoginScreen: Register button pressed. Navigation to register screen not implemented in this snippet.");
                  },
                  child: Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: accentPurple.withOpacity(0.9)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}