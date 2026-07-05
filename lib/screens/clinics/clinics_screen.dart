import 'package:flutter/material.dart';

import '../../controllers/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/clinic.dart';
import '../../widgets/clinic_card.dart';
import 'booking_sheet.dart';

/// Tela Encontrar Clínica (clinicas.html): busca por nome ou
/// especialidade e cards com botão "Agendar Consulta". No protótipo
/// original o botão apenas redirecionava; aqui ele abre um fluxo real
/// de agendamento (especialidade + data + hora) que cria uma consulta
/// pendente na aba Consultas.
class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _book(BuildContext context, Clinic clinic) async {
    final AppScope scope = AppScope.of(context);

    final BookingResult? result = await showModalBottomSheet<BookingResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BookingSheet(clinic: clinic),
    );

    if (result == null || !context.mounted) return;

    scope.appointments.book(
      clinicName: clinic.name,
      specialty: result.specialty,
      dateTime: result.dateTime,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Solicitação enviada: ${result.specialty} em '
            '${Formatters.longDate(result.dateTime)} às '
            '${Formatters.time(result.dateTime)}. '
            'Aguardando confirmação da clínica.',
          ),
          action: SnackBarAction(
            label: 'Ver consultas',
            onPressed: () => scope.goToTab(1),
          ),
        ),
      );
  }

  Widget _buildResults(
    BuildContext context,
    AppScope scope,
    List<Clinic> clinics,
  ) {
    if (clinics.isEmpty) {
      return scope.clinics.isShowingFeatured
          ? const _SearchPromptState()
          : const _EmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: clinics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final Clinic clinic = clinics[index];
        return ClinicCard(
          clinic: clinic,
          onBook: () => _book(context, clinic),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppScope scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.clinics,
      builder: (context, _) {
        final List<Clinic> clinics = scope.clinics.filtered;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Encontrar clínica',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: scope.clinics.setQuery,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Buscar por clínica ou especialidade...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _buildResults(context, scope, clinics),
            ),
          ],
        );
      },
    );
  }
}

class _SearchPromptState extends StatelessWidget {
  const _SearchPromptState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48, color: AppColors.textGray),
          SizedBox(height: 12),
          Text(
            'Digite o nome ou especialidade da\nclínica que você procura',
            textAlign: TextAlign.center,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_outlined, size: 48, color: AppColors.textGray),
          SizedBox(height: 12),
          Text(
            'Nenhuma clínica encontrada',
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
