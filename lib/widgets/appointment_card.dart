import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/appointment.dart';
import 'initials_avatar.dart';
import 'status_badge.dart';

/// Card de consulta (`.consult-card` do CSS original): avatar do médico,
/// especialidade/clínica, badge de status, data, hora e botão "Cancelar".
class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
  });

  final Appointment appointment;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InitialsAvatar(
              name: appointment.doctorName,
              color: appointment.avatarColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${appointment.specialty} · '
                              '${appointment.clinicName}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Coluna da direita: badge de status e, logo abaixo
                      // dele (com um respiro), a ação "Cancelar".
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StatusBadge(status: appointment.status),
                          if (appointment.isCancelable &&
                              onCancel != null) ...[
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: onCancel,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.statusCanceled,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Base do card: data e hora lado a lado, alinhadas.
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_month_outlined,
                        imageAsset: appointment.calendarAsset,
                        label: Formatters.longDate(appointment.dateTime),
                      ),
                      const SizedBox(width: 14),
                      _InfoChip(
                        icon: Icons.schedule_outlined,
                        label: Formatters.time(appointment.dateTime),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.imageAsset});

  final IconData icon;
  final String label;

  /// PNG do protótipo original (mini-calendário); se nulo, usa o ícone.
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset!,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(icon, size: 17, color: AppColors.primary),
          )
        else
          Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
