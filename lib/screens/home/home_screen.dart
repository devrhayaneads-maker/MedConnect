import 'package:flutter/material.dart';

import '../../controllers/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock_data.dart';
import '../../models/appointment.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/undo_banner.dart';

/// Tela Início (index.html): banner de boas-vindas, grade de ações
/// rápidas e card "Próxima consulta" com cancelamento.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppScope scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.appointments,
      builder: (context, _) {
        final int count = scope.appointments.upcomingCount;
        final Appointment? next = scope.appointments.nextAppointment;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            // ===== Banner de boas-vindas =====
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33009879),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.greeting(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '${MockData.userName} 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count == 0
                        ? 'Você não tem consultas agendadas'
                        : count == 1
                            ? 'Você tem 1 consulta agendada'
                            : 'Você tem $count consultas agendadas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== Ações rápidas =====
            Text(
              'Ações rápidas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    imageAsset: 'assets/icons/agendar-consulta.png',
                    label: 'Agendar consulta',
                    aspectRatio: 348 / 176,
                    onTap: () => scope.goToTab(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionCard(
                    imageAsset: 'assets/icons/minhas-consultas.png',
                    label: 'Minhas consultas',
                    aspectRatio: 348 / 176,
                    onTap: () => scope.goToTab(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    imageAsset: 'assets/icons/mensagens.png',
                    label: 'Mensagens',
                    aspectRatio: 356 / 168,
                    onTap: () => scope.goToTab(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionCard(
                    imageAsset: 'assets/icons/documentos.png',
                    label: 'Documentos',
                    aspectRatio: 348 / 168,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Documentos: em desenvolvimento.'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== Próxima consulta =====
            Text(
              'Próxima consulta',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (next == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.event_available_outlined,
                        size: 40,
                        color: AppColors.textGray,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Nenhuma consulta agendada',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => scope.goToTab(3),
                        child: const Text('Agendar agora'),
                      ),
                    ],
                  ),
                ),
              )
            else
              AppointmentCard(
                appointment: next,
                onCancel: () => _confirmCancel(context, scope, next),
              ),
          ],
        );
      },
    );
  }

  /// O protótipo original cancelava sem confirmação; aqui adicionamos
  /// um diálogo de confirmação e a opção "Desfazer" na Snackbar.
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
