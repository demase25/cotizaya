import 'package:flutter/material.dart';
import 'package:cotiza_ya/core/constants/colors.dart';
import 'package:cotiza_ya/core/constants/app_constants.dart';

class StatusChip extends StatelessWidget {
  final String status;
  
  const StatusChip({
    super.key,
    required this.status,
  });
  
  Color get _statusColor {
    switch (status) {
      case AppConstants.statusDraft:
        return AppColors.draft;
      case AppConstants.statusSent:
        return AppColors.sent;
      case AppConstants.statusAccepted:
        return AppColors.accepted;
      case AppConstants.statusRejected:
        return AppColors.rejected;
      default:
        return AppColors.draft;
    }
  }
  
  String get _statusLabel {
    switch (status) {
      case AppConstants.statusDraft:
        return 'Borrador';
      case AppConstants.statusSent:
        return 'Enviado';
      case AppConstants.statusAccepted:
        return 'Aceptado';
      case AppConstants.statusRejected:
        return 'Rechazado';
      default:
        return status;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor, width: 1),
      ),
      child: Text(
        _statusLabel,
        style: TextStyle(
          color: _statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
