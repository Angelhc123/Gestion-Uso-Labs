import 'package:controlusolab/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart'; // Ajusta si tu estructura de colores es diferente

class AddSupportUserDialog extends StatefulWidget {
  final AuthService authService;

  const AddSupportUserDialog({super.key, required this.authService});

  @override
  State<AddSupportUserDialog> createState() => _AddSupportUserDialogState();
}

class _AddSupportUserDialogState extends State<AddSupportUserDialog> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _createSupportUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        await widget.authService.createSupportUser(_email, _password);
        if (mounted) {
          Navigator.of(context).pop(true); // Indicar éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario de soporte creado con éxito.', style: TextStyle(color: textOnDark)),
              backgroundColor: successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryDark,
      title: const Text('Crear Usuario de Soporte', style: TextStyle(color: accentPurple)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView( // Para evitar overflow si el teclado aparece
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                style: const TextStyle(color: textOnDark),
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: TextStyle(color: textOnDarkSecondary.withOpacity(0.8)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentPurple.withOpacity(0.5))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accentPurple)),
                  errorStyle: const TextStyle(color: errorColor),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingrese un correo.';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Ingrese un correo válido.';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                style: const TextStyle(color: textOnDark),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: textOnDarkSecondary.withOpacity(0.8)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: accentPurple.withOpacity(0.5))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accentPurple)),
                  errorStyle: const TextStyle(color: errorColor),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese una contraseña.';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: errorColor, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: accentPurple)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: accentPurple),
          onPressed: _isLoading ? null : _createSupportUser,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryDarkPurple))
              : const Text('Crear Usuario', style: TextStyle(color: primaryDarkPurple, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
