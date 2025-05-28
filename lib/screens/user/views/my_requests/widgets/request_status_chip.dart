import 'package:flutter/material.dart';
import '../../../../../utils/app_colors.dart';

class RequestStatusChip extends StatelessWidget {
  final String status;

  const RequestStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    String chipText = status.toUpperCase();

    switch (status.toLowerCase()) {
      case 'aprobado':
      case 'approved':
        chipColor = successColor.withOpacity(0.7);
        chipText = 'APROBADO';
        break;
      case 'rechazado':
      case 'rejected':
        chipColor = errorColor.withOpacity(0.7);
        chipText = 'RECHAZADO';
        break;
      case 'pendiente':
      case 'pending':
        chipColor = warningColor.withOpacity(0.7);
        chipText = 'PENDIENTE';
        break;
      default:
        chipColor = Colors.grey.shade600;
        chipText = status.toUpperCase();
    }

    return Chip(
      label: Text(chipText, style: const TextStyle(color: textOnDark, fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0), // Ajuste fino
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce el padding extra del tap
      visualDensity: VisualDensity.compact, // Hace el chip más compacto
    );
  }
}
