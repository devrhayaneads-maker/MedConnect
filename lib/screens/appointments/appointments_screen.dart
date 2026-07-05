import 'package:flutter/material.dart';

import '../../controllers/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/appointment.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/filter_pill_row.dart';
import '../../widgets/undo_banner.dart';

/// Tela Minhas Consultas (consultas.html): filtros
/// Todas / Futuras / Realizadas / Canceladas e lista de cards
/// com cancelamento (confirmação + desfazer).
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppScope scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.appointments,
      builder: (context, _) {
        final List<Appointment> appointments = scope.appointments.filtered;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Minhas Consultas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: FilterPillRow<AppointmentFilter>(
                options: AppointmentFilter.values,
                selected: scope.appointments.filter,
                labelOf: (f) => f.label,
                onSelected: scope.appointments.setFilter,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: appointments.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: appointments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final Appointment appointment = appointments[index];
                        return AppointmentCard(
                          appointment: appointment,
                          onCancel: () =>
                              _confirmCancel(context, scope, appointment),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    AppScope scope,
    Appointment appointment,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar consulta?'),
        content: Text(
          'Deseja cancelar a consulta com ${appointment.doctorName} em '
          '${Formatters.longDate(appointment.dateTime)} às '
          '${Formatters.time(appointment.dateTime)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusCanceled,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancelar consulta'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final previous = scope.appointments.cancel(appointment.id);
    if (previous == null) return;

    UndoBanner.show(
      context,
      message: 'Consulta cancelada.',
      actionLabel: 'Desfazer',
      onAction: () => scope.appointments.restore(appointment.id, previous),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 48,
            color: AppColors.textGray,
          ),
          SizedBox(height: 12),
          Text(
            'Nenhuma consulta neste filtro',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
