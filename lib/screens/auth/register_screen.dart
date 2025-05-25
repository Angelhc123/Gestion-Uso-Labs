import 'package:controlusolab/services/auth_service.dart';
import 'package:flutter/material.dart';

// Paleta de colores (consistente con LoginScreen)
const Color primaryDarkPurple = Color(0xFF381E72);
const Color secondaryDark = Color(0xFF1C1B1F);
const Color accentPurple = Color(0xFFD0BCFF);
const Color textOnDark = Colors.white;
const Color textOnDarkSecondary = Color(0xFFCAC4D0);
const Color errorColor = Colors.redAccent;


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  InputDecoration _inputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentPurple.withOpacity(0.8)),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: accentPurple.withOpacity(0.7), size: 20) : null,
      filled: true,
      fillColor: primaryDarkPurple.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: accentPurple.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: accentPurple, width: 1.5),
      ),
      errorStyle: const TextStyle(color: errorColor, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        final user = await _authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (user != null) {
          if (mounted) {
            // Mostrar mensaje de éxito y redirigir o pedir al usuario que inicie sesión
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro exitoso. Por favor, inicia sesión.', style: TextStyle(color: textOnDark)),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context); // Volver a la pantalla de login
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().replaceFirst("Exception: ", ""); // Limpiar mensaje de error
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryDark,
      appBar: AppBar(
        title: const Text('Crear Cuenta', style: TextStyle(color: textOnDark, fontWeight: FontWeight.bold)),
        backgroundColor: primaryDarkPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: accentPurple),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Icon(Icons.app_registration, size: 80, color: accentPurple),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('Correo Electrónico', prefixIcon: Icons.email_outlined),
                  style: const TextStyle(color: textOnDark),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, ingrese su correo';
                    if (!value.contains('@') || !value.contains('.')) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: _inputDecoration('Contraseña', prefixIcon: Icons.lock_outline),
                  obscureText: true,
                  style: const TextStyle(color: textOnDark),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, ingrese una contraseña';
                    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: _inputDecoration('Confirmar Contraseña', prefixIcon: Icons.lock_reset_outlined),
                  obscureText: true,
                  style: const TextStyle(color: textOnDark),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Por favor, confirme su contraseña';
                    if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: accentPurple))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: accentPurple,
                          foregroundColor: primaryDarkPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: _register,
                        child: const Text('REGISTRARSE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: errorColor, fontWeight: FontWeight.bold),
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
