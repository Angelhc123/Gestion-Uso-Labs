import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class SubmitRequestButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const SubmitRequestButton({
    super.key,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return isSubmitting
        ? const Center(child: CircularProgressIndicator(color: accentPurple))
        : ElevatedButton.icon(
            icon: const Icon(Icons.send_outlined, color: primaryDarkPurple),
            label: const Text('Enviar Solicitud', style: TextStyle(fontSize: 18, color: primaryDarkPurple, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
            onPressed: onPressed,
          );
  }
}
